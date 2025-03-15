import 'package:beeuzine/home_page.dart';
import 'package:beeuzine/login.dart';
import 'package:beeuzine/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GenreSelectionPage extends StatefulWidget {
  final String penName;
  final String email;
  final String phoneNumber;
  final String password;

  const GenreSelectionPage({
    super.key,
    required this.penName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  @override
  _GenreSelectionPageState createState() => _GenreSelectionPageState();
}

class _GenreSelectionPageState extends State<GenreSelectionPage> {
  final List<String> genres = [
    "Nature",
    "Tech",
    "Fashion",
    "Travel",
    "Health",
    "Culinary",
    "Wellness",
    "Arts",
    "Culture",
    "Science",
    "Pop",
    "Business",
    "Sports",
    "Garden",
    "Music",
    "Film",
    "Social",
    "Trends",
  ];

  final Set<String> selectedGenres = {};

  void toggleSelection(String genre) {
    setState(() {
      if (selectedGenres.contains(genre)) {
        selectedGenres.remove(genre);
      } else {
        selectedGenres.add(genre);
      }
    });
  }

Future<void> registerUser() async {
  final supabase = Supabase.instance.client;

  try {
    // Step 1: Register the user with email and password using Supabase Auth
    final authResponse = await supabase.auth.signUp(
      email: widget.email,
      password: widget.password,
    );

    if (authResponse.user == null) {
      throw Exception('Failed to register user with email and password.');
    }

    // Step 2: Insert additional user data into the "users" table
    final response = await supabase.from('users').insert({
      'pen_name': widget.penName,
      'email': widget.email,
      'phone_number': widget.phoneNumber,
      'genres': selectedGenres.toList(),
    });



    // Step 3: Navigate to the next page (e.g., HomePage)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signed Up Successfully")),
        );
      }
  } catch (e) {
    // Handle errors (e.g., show a snackbar)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error registering user: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff5f5f5),
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Padding(
          padding: const EdgeInsets.only(top: 1, right: 20, left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Tell us what you're into",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 7.0,
                  ),
                  itemCount: genres.length,
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    final isSelected = selectedGenres.contains(genre);
                    return GestureDetector(
                      onTap: () => toggleSelection(genre),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(0xffffd85b)
                              : Color(0xffffd85b),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Colors.black,
                                  width: 2.0,
                                )
                              : Border.all(
                                  color: Color(0xffffd85b),
                                  width: 1.0,
                                ), // Add border when selected
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          genre,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: ElevatedButton(
                  onPressed: registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Select Genres",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}