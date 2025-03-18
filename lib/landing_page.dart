import 'package:beeuzine/sign_up.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final imageHeight = screenSize.height * 0.35; // 35% of screen height

    return Scaffold(
      backgroundColor: Color(0xFFFFD700),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    screenSize.height - MediaQuery.of(context).padding.vertical,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  Image.asset(
                    'assests/images/typewriter.png',
                    height: imageHeight,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Welcome to BeeU-Zine',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '"Bennett Beyond Textbooks"',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SecondPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Next',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/main',
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Skip',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final imageHeight = screenSize.height * 0.3; // 30% of screen height

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    screenSize.height - MediaQuery.of(context).padding.vertical,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  Text(
                    'Share your stories\nand Explore ours',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'at BeeU-Zine connect, share\nand read seamlessly.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Image.asset(
                    'assests/images/reading.png',
                    height: imageHeight,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateAccountPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
