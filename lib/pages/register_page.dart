import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gachafigo/models/user.dart';
import 'package:uuid/uuid.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final usersBox = Hive.box<User>('users');
      final username = _usernameController.text.trim();

      // Check if username already exists
      final userExists = usersBox.values.any(
        (user) => user.username == username,
      );
      if (userExists) {
        Fluttertoast.showToast(
          msg: "Username already exists",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        Fluttertoast.showToast(
          msg: "Passwords do not match",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      final newUser = User(
        id: Uuid().v4(),
        username: username,
        password: _hashPassword(_passwordController.text),
      );

      await usersBox.add(newUser);

      Fluttertoast.showToast(
        msg: "Registration successful! Please login.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _register, child: Text('Register')),
            ],
          ),
        ),
      ),
    );
  }
}
