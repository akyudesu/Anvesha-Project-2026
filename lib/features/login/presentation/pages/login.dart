import 'package:fire_evacuation_app/features/login/presentation/widgets/login_container.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55)),
          child: const SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: LoginCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
