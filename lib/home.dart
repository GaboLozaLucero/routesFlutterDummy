import 'package:flutter/material.dart';
import 'authenticationService.dart';
import 'package:provider/provider.dart';
import 'transitions.dart';
import 'map.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text('Home'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.map),
                onPressed: () {
                  Navigator.push(context, ScaleRoute(page: Map()));
                }),
            IconButton(icon: Icon(Icons.saved_search), onPressed: () {}),
            IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  context.read<AuthenticationService>().signOut();
                })
          ],
        ),
        body: Center(
          child: Text('You are in home page'),
        ),
      ),
    );
  }
}
