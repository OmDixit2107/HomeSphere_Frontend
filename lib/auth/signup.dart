import 'package:flutter/material.dart';
import 'package:homesphere/services/functions/authFunctions.dart';
import 'package:homesphere/utils/routes.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Role selection
  String? role; // Can be 'User' or 'Property Owner'

  void _handleSignUp() async {
    final name = nameController.text;
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phone.isEmpty ||
        role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all fields and select a role')),
      );
      return;
    }

    final success =
        await Authfunctions.signupUser(name, email, password, phone, role!);

    if (success) {
      Navigator.pushNamed(context, MyRoutes.loginScreen);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-up Done. Please now sign in.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-up failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/images/signup.png',
                fit: BoxFit.cover,
                height: 300,
                width: 350,
              ),
              const SizedBox(height: 20),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Courier',
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: 'Enter Your Full Name',
                        labelText: 'Full Name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.email),
                        hintText: 'Enter Your Email',
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.lock),
                        hintText: 'Enter Your Password',
                        labelText: 'Password',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.phone),
                        hintText: 'Enter Your Phone Number',
                        labelText: 'Phone Number',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Dropdown for Role Selection
                    DropdownButtonFormField<String>(
                      value: role,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.account_circle),
                        labelText: 'Select Role',
                      ),
                      items: ['User', 'Property Owner'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          role = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    TextButton.icon(
                      onPressed: _handleSignUp,
                      icon: const Icon(Icons.create),
                      label: Container(
                        alignment: Alignment.center,
                        width: 150,
                        height: 35,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, MyRoutes.loginScreen);
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'By signing up you agree to our terms, conditions, and privacy policy.',
                      style: TextStyle(fontSize: 13),
                      textAlign: TextAlign.center,
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
