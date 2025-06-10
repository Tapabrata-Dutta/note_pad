import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_pad/Pages/Test/todoPage.dart';
import 'package:note_pad/Pages/login.dart';
import 'package:note_pad/Pages/notes_page.dart';
import 'package:note_pad/Pages/todo.dart';

import 'Pages/Test/model.dart';

class wrapper extends StatefulWidget {
  @override
  State<wrapper> createState() => _wrapperState();
}

class _wrapperState extends State<wrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading spinner while checking authentication
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          // return MyHomePage(user: snapshot.data!);
          return Todoo();
        }
        // }
        else {
          return login();
        }
      },
    );
  }
}
