import 'package:beeuzine/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    // Clear any previous errors
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    // Basic validation
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Email and password cannot be empty';
        isLoading = false;
      });
      return;
    }

    try {
      final supabase = Supabase.instance.client;

      // Authenticate the user with email and password
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.user == null) {
        setState(() {
          errorMessage = 'Login failed. Please check your credentials.';
          isLoading = false;
        });
        return;
      }

      // Navigate to the HomePage on successful login
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
          (route) => false,
        );
      }
    } catch (e) {
      // Show error message
      setState(() {
        errorMessage = 'Error: ${e.toString().split(':').last.trim()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top Yellow Arc
            CustomPaint(
              size: Size(double.infinity, 150),
              painter: TopArcPainter(),
            ),
            const SizedBox(height: 20),
            // Page Title
            const Text(
              "Login to your Account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Input Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  _buildTextField("Enter Your Email", emailController),
                  const SizedBox(height: 15),
                  _buildTextField("Enter Your Password", passwordController,
                      isPassword: true),

                  // Display error message if any
                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red[700], size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(
                                  color: Colors.red[700], fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Don't Have an Account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to Sign Up Page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateAccountPage(),
                            ),
                          );
                        },
                        child: const Text(
                          " Sign Up",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Bottom Yellow Arc
            CustomPaint(
              size: Size(double.infinity, 150),
              painter: BottomArcPainter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// Custom Painter for the Top Arc
class TopArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.yellow[600]!;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, -50), radius: 200),
      0,
      3.14,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom Painter for the Bottom Arc
class BottomArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.yellow[600]!;
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height + 50), radius: 200),
      3.14,
      3.14,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
