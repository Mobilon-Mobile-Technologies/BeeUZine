import 'package:beeuzine/create_post_page.dart';
import 'package:beeuzine/home_page.dart';
import 'package:beeuzine/romance.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    CreatePostPage(),
    TopPicksScreen(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Create'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bubble_chart), label: 'Featured'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(255, 204, 40, 1),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final double coverHeight = 180;
  final double profileHeight = 144;
  bool isFollowing = false;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _userPosts = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      // Fetch user data from the users table
      final data = await supabase
          .from('users')
          .select('*')
          .eq('email', user.email!)
          .single();

      setState(() {
        _userData = data;
      });

      // Now fetch user's posts
      await _fetchUserPosts();
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserPosts() async {
    if (_userData == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      final userId = _userData!['id'];

      // Fetch posts with genre information
      final response = await supabase
          .from('post')
          .select('*, genres:genres_id(name)')
          .eq('users_id', userId)
          .order('post_id', ascending: false);

      setState(() {
        _userPosts = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildRandomImages(int index, bool hasImage, String? imageUrl) {
    if (hasImage && imageUrl != null) {
      return Image.network(
        imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // On error, show random image
          return Image.network(
            'https://picsum.photos/800/${600 + (index * 100 % 400)}',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[200],
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.grey[400],
                  size: 40,
                ),
              ),
            ),
          );
        },
      );
    } else {
      // No image, use random image
      return Image.network(
        'https://picsum.photos/800/${600 + (index * 100 % 400)}',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey[200],
          child: Center(
            child: Icon(
              Icons.image,
              color: Colors.grey[400],
              size: 40,
            ),
          ),
        ),
      );
    }
  }

  void _showPostDetail(Map<String, dynamic> post) {
    final hasImage = post['image_url'] != null;
    final userName =
        _userData != null ? _userData!['pen_name'] ?? 'Anonymous' : 'Anonymous';
    final genreName = post['genres'] != null
        ? post['genres']['name'] ?? 'Uncategorized'
        : 'Uncategorized';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: controller,
            children: [
              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Post title at the top in bold
                  Expanded(
                    child: Text(
                      post['post_title'] ?? 'Untitled Post',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Post Image
              if (hasImage)
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      post['image_url'],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    ),
                  ),
                ),

              // Post metadata
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Author info
                    Row(
                      children: [
                        // Show profile image if available
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: _userData != null &&
                                  _userData!['profile_pic'] != null
                              ? NetworkImage(_userData!['profile_pic'])
                              : const AssetImage('assests/images/profile1.png')
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // Genre tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD85B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        genreName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Post stats
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${post['likes'] ?? 0} likes',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      post['created_at'] != null
                          ? _formatDate(post['created_at'].toString())
                          : 'Unknown date',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Divider(color: Colors.grey[300], thickness: 1),

              // Content title - if different from post title
              const SizedBox(height: 12),
              const Text(
                'Content',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Content
              if (post['content'] != null &&
                  post['content'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    post['content'],
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No content available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              const SizedBox(height: 80), // Extra space at bottom
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} year(s) ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} month(s) ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day(s) ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour(s) ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute(s) ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFD85B),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchUserData,
              color: const Color(0xFFFFD85B),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  buildTop(),
                  const SizedBox(height: 8),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 26, left: 30, top: 58),
                    child: Text(
                      _userData != null && _userData!['pen_name'] != null
                          ? _userData!['pen_name']
                          : 'Anonymous',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(right: 26, left: 30),
                    child: Text(
                      _userData != null && _userData!['email'] != null
                          ? _userData!['email']
                          : 'No email',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildAboutSection(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: buildFollowButton(),
                  ),
                  const SizedBox(height: 20),
                  buildStatsSection(),
                  const SizedBox(height: 16),
                  buildPostSection(),
                  buildUserPosts(),
                ],
              ),
            ),
    );
  }

  Widget buildTop() => Stack(
        clipBehavior: Clip.none,
        children: [
          buildCoverImage(),
          Positioned(
            top: coverHeight - profileHeight / 2,
            left: 16,
            child: buildProfileImage(),
          ),
        ],
      );

  Widget buildCoverImage() => SizedBox(
        height: coverHeight,
        child: ClipPath(
          clipper: BottomCurveClipper(),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assests/images/back.png'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              border: Border.all(color: Color(0xffffd85b), width: 2),
            ),
          ),
        ),
      );

  Widget buildProfileImage() => Container(
        width: profileHeight,
        height: profileHeight,
        decoration: BoxDecoration(
          image: _userData != null && _userData!['profile_pic'] != null
              ? DecorationImage(
                  image: NetworkImage(_userData!['profile_pic']),
                  fit: BoxFit.cover,
                )
              : const DecorationImage(
                  image: AssetImage('assests/images/profile1.png'),
                  fit: BoxFit.cover,
                ),
          color: Colors.grey.shade800,
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xffffd85b), width: 4),
        ),
      );

  Widget buildAboutSection() => Padding(
        padding: const EdgeInsets.only(right: 26, left: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About Me',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _userData != null && _userData!['bio'] != null
                  ? _userData!['bio']
                  : 'No bio available',
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Could expand bio or navigate to full bio page
              },
              child: const Text(
                'Read More>',
                style: TextStyle(
                  color: Color(0xff4a4a4a),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );

  Widget buildFollowButton() => GestureDetector(
        onTap: () {
          setState(() {
            isFollowing = !isFollowing;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.transparent : const Color(0xffffd85b),
            border: Border.all(color: const Color.fromRGBO(255, 204, 40, 1)),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            isFollowing ? 'Unfollow' : 'Follow',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  Widget buildStatsSection() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildStatItem('Followers', '50+'),
            buildStatItem('Following', '50+'),
            buildStatItem('Posts', _userPosts.length.toString()),
          ],
        ),
      );

  Widget buildStatItem(String label, String count) => GestureDetector(
        onTap: () {
          print('$label button tapped');
        },
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  Widget buildPostSection() => Padding(
        padding: const EdgeInsets.only(right: 26, left: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Posts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Refresh posts
                _fetchUserPosts();
              },
              child: const Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff4a4a4a),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

  Widget buildUserPosts() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_userPosts.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.post_add, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No posts yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your posts will appear here',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(
                _userPosts.length > 3 ? 3 : _userPosts.length,
                (index) {
                  final post = _userPosts[index];
                  final hasImage = post['image_url'] != null;
                  final genreName = post['genres'] != null
                      ? post['genres']['name'] ?? 'Uncategorized'
                      : 'Uncategorized';

                  return GestureDetector(
                    onTap: () => _showPostDetail(post),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 2),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Post image or random image
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: hasImage
                                ? Image.network(
                                    post['image_url'],
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      // On error, show random image
                                      return Image.network(
                                        'https://picsum.photos/800/${600 + (index * 100 % 400)}',
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 180,
                                          width: double.infinity,
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey[400],
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Image.network(
                                    'https://picsum.photos/800/${600 + (index * 100 % 400)}',
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 180,
                                      width: double.infinity,
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.grey[400],
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),

                          // Post details
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post['post_title'] ?? 'Untitled Post',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                if (post['content'] != null &&
                                    post['content'].toString().isNotEmpty)
                                  Text(
                                    post['content'].toString().length > 100
                                        ? '${post['content'].toString().substring(0, 100)}...'
                                        : post['content'].toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.favorite,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${post['likes'] ?? 0}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(Icons.calendar_today,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          post['created_at'] != null
                                              ? _formatDate(
                                                  post['created_at'].toString())
                                              : 'Unknown date',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD85B),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        genreName,
                                        style: const TextStyle(
                                          fontSize: 10,
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
                  );
                },
              ),
            if (_userPosts.length > 3)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      // Navigate to All Posts screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllUserPostsScreen(
                            posts: _userPosts,
                            onRefresh: () async {
                              await _fetchUserPosts();
                              setState(() {});
                            },
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'View All Posts (${_userPosts.length})',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () => _signOut(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                  foregroundColor: Colors.red[800],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 2, size.height - 50, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class AllUserPostsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> posts;
  final Function onRefresh;

  const AllUserPostsScreen({
    super.key,
    required this.posts,
    required this.onRefresh,
  });

  void _showPostDetail(BuildContext context, Map<String, dynamic> post) {
    final hasImage = post['image_url'] != null;
    final genreName = post['genres'] != null
        ? post['genres']['name'] ?? 'Uncategorized'
        : 'Uncategorized';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: controller,
            children: [
              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Post title at the top in bold
                  Expanded(
                    child: Text(
                      post['post_title'] ?? 'Untitled Post',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Post Image
              if (hasImage)
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      post['image_url'],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    ),
                  ),
                ),

              // Genre tag
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD85B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        genreName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Post stats
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${post['likes'] ?? 0} likes',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      post['created_at'] != null
                          ? _formatDate(post['created_at'].toString())
                          : 'Unknown date',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Divider(color: Colors.grey[300], thickness: 1),

              // Content title - if different from post title
              const SizedBox(height: 12),
              const Text(
                'Content',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Content
              if (post['content'] != null &&
                  post['content'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    post['content'],
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No content available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              const SizedBox(height: 80), // Extra space at bottom
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} year(s) ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} month(s) ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day(s) ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour(s) ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute(s) ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All My Posts'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await onRefresh();
        },
        color: const Color(0xFFFFD85B),
        child: posts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.post_add, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No posts yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final hasImage = post['image_url'] != null;
                  final genreName = post['genres'] != null
                      ? post['genres']['name'] ?? 'Uncategorized'
                      : 'Uncategorized';

                  return GestureDetector(
                    onTap: () => _showPostDetail(context, post),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 2),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Post image or placeholder
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: hasImage
                                ? Image.network(
                                    post['image_url'],
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Image.network(
                                      'https://picsum.photos/800/${600 + (index * 100 % 400)}',
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 200,
                                        width: double.infinity,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey[400],
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Image.network(
                                    'https://picsum.photos/800/${600 + (index * 100 % 400)}',
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.grey[400],
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
