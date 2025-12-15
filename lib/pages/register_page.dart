import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geofence/components/my_button.dart';
import 'package:geofence/components/my_textfield.dart';
import 'package:geofence/helper/helper_functions.dart';

class RegisterPage extends StatefulWidget{

  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController userNameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();

  void register() async {
    showDialog(
        context: context,
        builder: (context){
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    if(passwordController.text != confirmPasswordController.text){
      Navigator.pop(context);
      
      showMsgToUser("Passwords don't match", context);

    }
    else{
      try {
        // create the user
        UserCredential? userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // pop loading circle
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        // pop loading circle
        Navigator.pop(context);

        // display error message to user
        showMsgToUser(e.code, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/bg.png', // update path if different
            fit: BoxFit.cover,
          ),
          // Dark overlay for contrast
          Container(color: Colors.black.withOpacity(0.55)),

          // Centered register card
          Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.person,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(.9),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Create your account',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // your existing fields unchanged
                        myTextfield(
                          hintText: "Username",
                          obscureText: false,
                          controller: userNameController,
                        ),
                        const SizedBox(height: 12),
                        myTextfield(
                          hintText: "Email",
                          obscureText: false,
                          controller: emailController,
                        ),
                        const SizedBox(height: 12),
                        myTextfield(
                          hintText: "Password",
                          obscureText: true,
                          controller: passwordController,
                        ),
                        const SizedBox(height: 12),
                        myTextfield(
                          hintText: "Confirm Password",
                          obscureText: true,
                          controller: confirmPasswordController,
                        ),

                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Spacer(),
                            Text(
                              "forgot password?",
                              style: TextStyle(color: theme.colorScheme.primary),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: MyButton(text: "Register", onTap: register),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?"),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: const Text(
                                "Login Here",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}