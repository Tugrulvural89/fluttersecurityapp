import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tuple/tuple.dart';


class ApiService {
  final Dio _dio = Dio();

  // Api Base Url
  final String baseUrl = 'http://192.168.1.56:3000';

  late String userId;
  late String userPass;
  // generate random user id and pass
  // these values will be using for web location query
  // store these values via
  String generateRandomString(int length) {
    const characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  // POST request for creating account
  Future<Response> createAccount() async {
    await dotenv.load(fileName: ".env"); // .env
    String? secretKey = dotenv.env['SECRET_KEY']; // get Key

    String url = '$baseUrl/createAccount';

    // Header'ları ayarla
    Map<String, dynamic> headers = {
      'UserId': userId,
      'UserPass': userPass,
      'SecretKey': secretKey, // Secret Key
    };

    // İsteği yap
    try {
      Response response = await _dio.post(url, options: Options(headers: headers));
      return response;
    } on DioException catch (e) {
      // Hata durumunda işlem
      print(e.toString());
      throw e;
    }
  }

  // check user exist on database
  Future<bool> checkUserExists() async {
    await dotenv.load(fileName: ".env"); // .env
    String? secretKey = dotenv.env['SECRET_KEY']; // get Key

    String url = '$baseUrl/checkUserExists';

    // Header'ları ayarla
    Map<String, dynamic> headers = {
      'SecretKey': secretKey, // Secret Key
    };

    bool result = false;
    try {
      Response response = await _dio.post(url, options: Options(headers: headers), data: {'userId': userId});
      bool responseData = response.data['exists'];
      if (responseData) {
        result = true;
        return result;
      } else {
        return result;
      }
    } on DioException catch (e) {
      // Hata durumunda işlem
      print(e.toString());
      return result;
    }
  }


  Future<Tuple2<String, String>> generateLocationPassword() async {
    // Function to get Android options
    AndroidOptions getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

    // Initialize FlutterSecureStorage with Android options
    final FlutterSecureStorage secureStorage = FlutterSecureStorage(
      aOptions: getAndroidOptions(),
    );
    // Try to read existing values from secure storage
    userId = await secureStorage.read(key: 'user_password_loc_id') ?? generateRandomString(9);
    userPass = await secureStorage.read(key: 'user_password_loc_pass') ?? generateRandomString(20);
    await secureStorage.write(key: 'user_password_loc_id', value: userId);
    await secureStorage.write(key: 'user_password_loc_pass', value: userPass);
    return Tuple2(userId, userPass);
  }

  Future<bool> checkAndCreate() async {
    // create backend account for tracking location
    // set userid and userpass created from storage
    // if userid is null or not first check id is available or already create
    try {
      // check user response true / false exists var in body
      bool userExists = await checkUserExists();
      if (userExists) {
        print('Kullanıcı zaten var.');
        return true;
      } else {
        print('Kullanıcı mevcut değil, hesap oluşturulabilir.');
        Response response = await createAccount();
        print('Response: ${response.data}');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

}
