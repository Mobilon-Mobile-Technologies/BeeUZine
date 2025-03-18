import 'package:beeuzine/login.dart';
import 'package:beeuzine/wildlife.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  // Track which posts the user has liked
  final Set<int> _likedPosts = {};
  final Set<int> _reportedPosts = {};

  @override
  void initState() {
    _tabController = TabController(
      length: 1, // Change from 2 to 1 to match the number of tabs
      vsync: this,
    );
    _fetchPosts();
    _loadUserLikedPosts();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load user's liked posts from the post table
  Future<void> _loadUserLikedPosts() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      // Get user record from users table
      final userData = await supabase
          .from('users')
          .select('id')
          .eq('email', user.email!)
          .single();

      if (userData == null) return;

      // Instead of querying a user_likes table, check which posts have been liked by this user
      // This is a temporary solution until you create a user_likes table
      // In the future, you should create a proper user_likes table for tracking likes

      setState(() {
        _likedPosts.clear();
        _reportedPosts.clear();
      });
    } catch (e) {
      print('Error loading user liked posts: $e');
    }
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // Fetch posts with genre information
      final response = await supabase
          .from('post')
          .select(
              '*, users:users_id(pen_name, profile_pic), genres:genres_id(name)')
          .order('post_id', ascending: false);

      setState(() {
        _posts.clear();
        _posts.addAll(response);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle like post action
  Future<void> _likePost(Map<String, dynamic> post) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final postId = post['post_id'];

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to like posts')),
      );
      return;
    }

    // Determine if the post is already liked by this user
    final isLiked = _likedPosts.contains(postId);
    print('Post $postId is liked: $isLiked'); // Debug log

    try {
      // Get user ID from users table
      final userData = await supabase
          .from('users')
          .select('id')
          .eq('email', user.email!)
          .single();

      final userId = userData['id'];

      // If already liked, unlike the post
      if (isLiked) {
        print('Unliking post $postId'); // Debug log

        // Only decrement if likes is greater than 0
        final currentLikes = post['likes'] ?? 0;
        if (currentLikes > 0) {
          // Decrement likes count in database
          await supabase
              .from('post')
              .update({'likes': currentLikes - 1}).eq('post_id', postId);
        }

        // Since we don't have a user_likes table, we just need to update our local tracking
        setState(() {
          _likedPosts.remove(postId);
          // Update the post in our local list
          final index = _posts.indexWhere((p) => p['post_id'] == postId);
          if (index != -1) {
            _posts[index]['likes'] = currentLikes > 0 ? currentLikes - 1 : 0;
          }
        });
      } else {
        print('Liking post $postId'); // Debug log

        // Current like count
        final currentLikes = post['likes'] ?? 0;

        // Increment likes count in database
        await supabase
            .from('post')
            .update({'likes': currentLikes + 1}).eq('post_id', postId);

        // Since we don't have a user_likes table, we just need to update our local tracking
        setState(() {
          _likedPosts.add(postId);
          // Update the post in our local list
          final index = _posts.indexWhere((p) => p['post_id'] == postId);
          if (index != -1) {
            _posts[index]['likes'] = currentLikes + 1;
          }
        });
      }
    } catch (e) {
      print('Error updating like: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating post: $e')),
      );
    }
  }

  // Handle report post action
  Future<void> _reportPost(Map<String, dynamic> post) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to report posts')),
      );
      return;
    }

    final postId = post['post_id'];

    // If already reported, return
    if (_reportedPosts.contains(postId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already reported this post')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get user ID from users table
      final userData = await supabase
          .from('users')
          .select('id')
          .eq('email', user.email!)
          .single();

      final userId = userData['id'];

      // Increment report count
      await supabase
          .from('post')
          .update({'report': (post['report'] ?? 0) + 1}).eq('post_id', postId);

      // Since we don't have a user_reports table, we just track locally
      setState(() {
        _reportedPosts.add(postId);

        // Update the post in the local list
        final index = _posts.indexWhere((p) => p['post_id'] == postId);
        if (index != -1) {
          _posts[index]['report'] = (_posts[index]['report'] ?? 0) + 1;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post reported')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reporting post: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPostDetail(Map<String, dynamic> post) {
    final hasImage = post['image_url'] != null;
    final userName = post['users'] != null
        ? post['users']['pen_name'] ?? 'Anonymous'
        : 'Anonymous';
    final genreName = post['genres'] != null
        ? post['genres']['name'] ?? 'Uncategorized'
        : 'Uncategorized';
    final postId = post['post_id'];
    bool isLiked = _likedPosts.contains(postId);
    final isReported = _reportedPosts.contains(postId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDetailState) => DraggableScrollableSheet(
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
                        getPostTitle(post),
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: post['image_url'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: 'https://picsum.photos/800/600',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                  ),

                // Like and Report buttons directly below the image
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Like button
                      InkWell(
                        onTap: () async {
                          // Don't update UI here
                          await _likePost(post);

                          // After database operation is complete, update detail view UI
                          setDetailState(() {
                            isLiked = _likedPosts.contains(postId);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey[700],
                                size: 24,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                post['likes']?.toString() ?? '0',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Comment button (placeholder)
                      InkWell(
                        onTap: () {
                          // Add comment functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Comments coming soon!')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.comment_outlined,
                                color: Colors.grey[700],
                                size: 24,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '0',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Report button
                      InkWell(
                        onTap: isReported
                            ? null
                            : () async {
                                await _reportPost(post);
                                Navigator.pop(context);
                              },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isReported
                                    ? Icons.report
                                    : Icons.report_outlined,
                                color: isReported
                                    ? Colors.orange
                                    : Colors.grey[700],
                                size: 24,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                post['report']?.toString() ?? '0',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Author name - centered
                Center(
                  child: Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Genre tag - centered
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                ),

                const SizedBox(height: 24),

                // Content - centered text
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      getContentWithoutFirstLine(post['content']),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: size.width * 0.33,
          height: size.height * 0.17,
          child: Image(image: AssetImage("assests/images/logo.png")),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bubble_chart,
              size: size.width * 0.08,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WildlifeScreen(),
                  ));
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFFFD85B)))
                      : _posts.isEmpty
                          ? const Center(child: Text('No posts found'))
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: RefreshIndicator(
                                onRefresh: _fetchPosts,
                                color: const Color(0xFFFFD85B),
                                child: MasonryGridView.count(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  itemCount: _posts.length,
                                  itemBuilder: (context, index) {
                                    final post = _posts[index];
                                    final hasImage = post['image_url'] != null;
                                    final userName = post['users'] != null
                                        ? post['users']['pen_name'] ??
                                            'Anonymous'
                                        : 'Anonymous';
                                    final genreName = post['genres'] != null
                                        ? post['genres']['name'] ??
                                            'Uncategorized'
                                        : 'Uncategorized';
                                    final postId = post['post_id'];
                                    final isLiked =
                                        _likedPosts.contains(postId);
                                    final isReported =
                                        _reportedPosts.contains(postId);

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            _showPostDetail(post);
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: hasImage
                                                ? CachedNetworkImage(
                                                    imageUrl: post['image_url'],
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            AspectRatio(
                                                      aspectRatio: 1,
                                                      child: Container(
                                                        color: Colors.grey[300],
                                                      ),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            AspectRatio(
                                                      aspectRatio: 1,
                                                      child: Container(
                                                        color: Colors.grey[300],
                                                        child: const Icon(
                                                            Icons.error),
                                                      ),
                                                    ),
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl:
                                                        'https://picsum.photos/800/${600 + (index * 100 % 400)}',
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            AspectRatio(
                                                      aspectRatio: 1,
                                                      child: Container(
                                                        color: Colors.grey[300],
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        // Like and Report buttons under the image
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Row(
                                            children: [
                                              _buildLikeButton(post, isLiked),
                                              const SizedBox(width: 4),
                                              Text(
                                                post['likes']?.toString() ??
                                                    '0',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              const Spacer(),
                                              InkWell(
                                                onTap: isReported
                                                    ? null
                                                    : () => _reportPost(post),
                                                child: Icon(
                                                  isReported
                                                      ? Icons.report
                                                      : Icons.report_outlined,
                                                  size: 18,
                                                  color: isReported
                                                      ? Colors.orange
                                                      : Colors.grey[700],
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                post['report']?.toString() ??
                                                    '0',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4.0,
                                              right: 4.0,
                                              bottom: 4.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post['post_title'] != null &&
                                                        post['post_title']
                                                            .toString()
                                                            .isNotEmpty
                                                    ? post['post_title']
                                                                .toString()
                                                                .length >
                                                            50
                                                        ? post['post_title']
                                                                .toString()
                                                                .substring(
                                                                    0, 50) +
                                                            '...'
                                                        : post['post_title']
                                                    : post['content'] != null &&
                                                            post['content']
                                                                .toString()
                                                                .isNotEmpty
                                                        ? post['content'].toString().substring(
                                                                0,
                                                                post['content']
                                                                            .toString()
                                                                            .length >
                                                                        50
                                                                    ? 50
                                                                    : post['content']
                                                                        .toString()
                                                                        .length) +
                                                            '...'
                                                        : 'No content',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    userName,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFFFD85B),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Text(
                                                      genreName,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Update the grid item UI to handle unlike functionality
  Widget _buildLikeButton(Map<String, dynamic> post, bool isLiked) {
    final postId = post['post_id'];

    return InkWell(
      onTap: () {
        // Don't update UI here, let _likePost handle everything
        _likePost(post);
      },
      child: Icon(
        _likedPosts.contains(postId) ? Icons.favorite : Icons.favorite_outline,
        size: 18,
        color: _likedPosts.contains(postId) ? Colors.red : Colors.grey[700],
      ),
    );
  }

  String getContentWithoutFirstLine(String? content) {
    if (content == null || content.isEmpty) {
      return '';
    }
    final lines = content.split('\n');
    if (lines.length > 1) {
      return lines.sublist(1).join('\n');
    }
    return content;
  }

  String getPostTitle(Map<String, dynamic> post) {
    if (post['post_title'] != null &&
        post['post_title'].toString().isNotEmpty) {
      return post['post_title'];
    }
    if (post['content'] != null && post['content'].toString().isNotEmpty) {
      final lines = post['content'].toString().split('\n');
      if (lines.isNotEmpty) {
        return lines[0];
      }
    }
    return 'Untitled Post';
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        // Navigate to login page after signing out
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
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
