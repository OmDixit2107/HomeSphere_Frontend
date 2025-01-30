import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:homesphere/services/functions/authFunctions.dart';
import 'package:homesphere/utils/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
              ),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText('Welcome!',
                      textStyle: const TextStyle(
                        color: Colors.red,
                        fontSize: 30,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Times New Roman',
                        fontWeight: FontWeight.w500,
                      ),
                      speed: const Duration(milliseconds: 450)),
                ],
                onTap: () {
                  debugPrint("Welcome back!");
                },
                isRepeatingAnimation: true,
                totalRepeatCount: 2,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.email),
                        hintText: 'Enter Your Email',
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.lock),
                        hintText: 'Enter Your Password',
                        labelText: 'Password',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () async {
                        String s= await AuthFunctions.loginUser(
                          _emailController.text,
                          _passwordController.text,
                        );
                        if(s=='User'){
                          Navigator.pushNamed(context, MyRoutes.userHome);
                        }
                        else if(s=='Property Owner'){
                          Navigator.pushNamed(context, MyRoutes.propertyOwnerHome);
                        }
                      },
                      icon: const Icon(Icons.login),
                      label: Container(
                        alignment: Alignment.center,
                        width: 150,
                        height: 35,
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Don\'t have an account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, MyRoutes.signUp);
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
