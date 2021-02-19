import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'authenticationService.dart';
import 'package:provider/provider.dart';

class SignIn extends StatelessWidget {
  final TextEditingController email = new TextEditingController();
  final TextEditingController password = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: AssetImage('images/cover.png'),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
                child: Text(
                  'Routes',
                  style: TextStyle(fontSize: 56.0, color: Colors.deepPurple),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(80.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: email,
                        decoration: InputDecoration(
                            hintText: 'Email',
                            border: InputBorder.none,
                            fillColor: Colors.white,
                            filled: true),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: password,
                        decoration: InputDecoration(
                            hintText: 'Password',
                            border: InputBorder.none,
                            fillColor: Colors.white,
                            filled: true),
                        enableSuggestions: false,
                        obscureText: true,
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      RaisedButton(
                        onPressed: () {
                          context.read<AuthenticationService>().signIn(
                                email: email.text.trim(),
                                password: password.text.trim(),
                              );
                        },
                        color: Colors.red,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Text('Sign in'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
