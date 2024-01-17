import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'home_screen.dart';


class SetPasswordView extends StatefulWidget {
  const SetPasswordView({super.key});

  @override
   createState()  => SetPasswordViewState();
}

class SetPasswordViewState extends State<SetPasswordView>{
  bool success = false;
  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );
  late FlutterSecureStorage storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
  final TextEditingController _controller = TextEditingController();
  late String? myPass;


  void validatePassword(String inputPassword)  {
    if(inputPassword.length == 4 && int.tryParse(inputPassword) != null) {
      setState(() {
        checkPass = true;
      });
    } else {
      setState(() {
        checkPass = false;
      });
    }
  }

  bool checkPass = false;
  void savePassword() async {
    String password = _controller.text;
    if (checkPass) {
      await storage.write(key: 'user_password', value: password);
      setState(() {
        success = true;
      });
    }
  }

  Future<String?> readPassword() async {
    myPass = await storage.read(key: 'user_password');
    return myPass;
  }

  @override
  initState() {
    super.initState();
    readPassword();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Password"),
      ),
      body: Column(
        children: [
          FutureBuilder(
              future: readPassword(),
              builder: ( context, snapshot){
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return Text('Şifre: ${snapshot.data}');
                    } else {
                        return const Text('Şifre bulunamadı');
                    }} else {
                    return const CircularProgressIndicator();
                    }

              }),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: '4 Haneli Şifre',
                hintText: '1234',
                border: OutlineInputBorder(),
                // Doğrulama sonucuna göre kenarlık rengini değiştir
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: checkPass == true ? Colors.green : Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: checkPass == true ? Colors.green : Colors.red),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: checkPass == false ? Colors.red : Colors.grey),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: checkPass == false ? Colors.red : Colors.blue),
                ),
              ),
              onChanged: validatePassword,
            ),
          ),
          ElevatedButton(onPressed: () {
            savePassword();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) {
              return const HomeScreen();
            }));
          }, child: const Text('Save'))
        ],
      ),
    );
  }
}