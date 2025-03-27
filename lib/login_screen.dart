import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wear/landing_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _onSubmit() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState!.save();
      await _requestForLogin();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestForLogin() async {
    try {
      var response = await http.post(
        Uri.parse('https://dummyjson.com/user/login'),
        body: {
          'username': _userNameController.text,
          'password': _passwordController.text,
          'expiresInMins': '30', // Convert integer to string
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => LandingScreen(
              responseValue: response.body,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Login Failed'),
        ));
      }
    } catch (e) {
      print("login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Login Failed - Parse Error'),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _userNameController,
                decoration: InputDecoration(hintText: 'Username'),
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    return null;
                  } else {
                    return 'This field is required';
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(hintText: 'Password'),
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    return null;
                  } else {
                    return 'This field is required';
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () => _onSubmit(),
                      child: Text('Login'),
                    ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
