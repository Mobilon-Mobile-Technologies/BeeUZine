import 'package:flutter/material.dart';


class CreateAccountPage extends StatelessWidget {
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
            SizedBox(height: 20),
            // Page Title
            Text(
              "Create an account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 20),
            // Input Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  _buildTextField("Enter Your PenName"),
                  SizedBox(height: 15),
                  _buildTextField("Enter Your Email"),
                  SizedBox(height: 15),
                  _buildTextField("Enter Your Phone Number"),
                  SizedBox(height: 15),
                  _buildTextField("Create Your Password", isPassword: true),
                  SizedBox(height: 30),
                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Already Have an Account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to Login Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
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

  Widget _buildTextField(String hintText, {bool isPassword = false}) {
    return TextField(
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

// Placeholder LoginPage
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
        backgroundColor: Colors.yellow[600],
      ),
      body: Center(
        child: Text(
          "This is the Login Page",
          style: TextStyle(fontSize: 18),
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
