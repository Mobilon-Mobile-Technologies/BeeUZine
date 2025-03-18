import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  // Add a static method to fetch posts for a user
  static Future<List<Map<String, dynamic>>> fetchUserPosts(int userId) async {
    final supabase = Supabase.instance.client;
    try {
      final posts = await supabase
          .from('post')
          .select('*, genres:genres_id(*)')
          .eq('users_id', userId)
          .order('post_id', ascending: false);

      return posts;
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  // Add a static method to delete a post
  static Future<bool> deletePost(int postId) async {
    final supabase = Supabase.instance.client;
    try {
      // First get the post to get the image URL
      final post = await supabase
          .from('post')
          .select('image_url')
          .eq('post_id', postId)
          .single();

      if (post != null && post['image_url'] != null) {
        // Parse the URL to get the storage path
        final imageUrl = post['image_url'] as String;
        final storagePathIndex = imageUrl.indexOf('post_images/');

        if (storagePathIndex != -1) {
          final storagePath = imageUrl.substring(storagePathIndex);
          // Delete the image from storage if possible
          try {
            await supabase.storage.from('post_images').remove([storagePath]);
          } catch (e) {
            // Continue even if image deletion fails
            print('Failed to delete image: $e');
          }
        }
      }

      // Delete the post
      await supabase.from('post').delete().eq('post_id', postId);
      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedGenre;
  File? _imageFile;
  bool _isLoading = false;

  // List of genres from GenreSelectionPage
  final List<String> _genres = [
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _createPost() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGenre == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a genre")),
        );
        return;
      }

      if (_titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a title for your post")),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;

        if (user == null) {
          throw Exception('User not logged in');
        }

        if (user.email == null) {
          throw Exception('User email is not available');
        }

        // Get the user ID from the users table based on the authenticated user's email
        final userData = await supabase
            .from('users')
            .select('id')
            .eq('email', user.email!)
            .single();

        if (userData == null) {
          throw Exception('User not found in database');
        }

        final userId = userData['id'];

        // Initialize post data
        final Map<String, dynamic> postData = {
          'users_id': userId, // This is the id from users table
          'post_title': _titleController.text.trim(), // Add the post title
          'content': _contentController.text,
          'likes': 0,
          'report': 0,
        };

        // Handle genre
        int genreId = 1; // Default to genre ID 1
        if (_selectedGenre != null) {
          // We need to convert _selectedGenre to an integer ID
          // This is a simplified mapping and should be replaced with real DB data
          switch (_selectedGenre) {
            case "Nature":
              genreId = 1;
              break;
            case "Tech":
              genreId = 2;
              break;
            case "Fashion":
              genreId = 3;
              break;
            case "Travel":
              genreId = 4;
              break;
            case "Health":
              genreId = 5;
              break;
            default:
              genreId = 1; // Default value
          }
        }
        postData['genres_id'] = genreId;

        // Only upload image if one was selected
        if (_imageFile != null) {
          // Upload image to storage
          final fileName =
              'post_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final filePath = 'posts/${user.id}/$fileName';

          await supabase.storage.from('post_images').upload(
                filePath,
                _imageFile!,
                fileOptions:
                    const FileOptions(cacheControl: '3600', upsert: false),
              );

          // Get the public URL of the uploaded image
          final imageUrl =
              supabase.storage.from('post_images').getPublicUrl(filePath);

          // Add image URL to post data
          postData['image_url'] = imageUrl;
        }

        // Create post in the database with the correct field names from the schema
        await supabase.from('post').insert(postData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Post created successfully!")),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating post: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text("Create Post"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD85B)))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image Selection
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 50,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "Add Cover Image (Optional)",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: "Post Title (Required)",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Genre Dropdown
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              hintText: "Select Genre",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            value: _selectedGenre,
                            items: _genres.map((String genre) {
                              return DropdownMenuItem<String>(
                                value: genre,
                                child: Text(genre),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedGenre = newValue;
                              });
                            },
                            icon: const Icon(Icons.arrow_drop_down_circle,
                                color: Color(0xFFFFD85B)),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Content Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _contentController,
                            maxLines: 10,
                            decoration: InputDecoration(
                              hintText: "Write your content here...",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some content';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Submit Button
                        ElevatedButton(
                          onPressed: _createPost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD85B),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            "Publish Post",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
