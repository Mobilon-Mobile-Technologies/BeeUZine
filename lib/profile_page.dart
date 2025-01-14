import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('Home Page', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Search Page', style: TextStyle(fontSize: 24))),
    const Center(
        child: Text('Create New Post Page', style: TextStyle(fontSize: 24))),
    const Center(
        child: Text('Saved Items Page', style: TextStyle(fontSize: 24))),
    const ProfilePage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
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

  @override
  Widget build(BuildContext context) {
    final top = coverHeight - profileHeight / 2;
    final bottom = profileHeight / 2;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            buildCoverImage(),
            Positioned(
              top: top,
              left: 16,
              child: buildProfileImage(),
            ),
          ],
        ),
        SizedBox(height: bottom + 16),
        buildAuthorSection(),
        const Divider(color: Colors.grey, thickness: 0.3),
        buildAboutSection(),
        const Divider(color: Colors.grey, thickness: 0.3),
        buildStatsSection(),
        const Divider(color: Colors.grey, thickness: 0.3),
        buildPostSection(),
        const Divider(color: Colors.grey, thickness: 0.3),
        buildUserPosts(),
      ],
    );
  }

  Widget buildCoverImage() => SizedBox(
        height: coverHeight,
        child: ClipPath(
          clipper: BottomCurveClipper(),
          child: Container(
            decoration:  BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage('assests/images/back.png'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              border: Border.all(color: Color(0xffffd85b), width:2),
            ),
          ),
        ),
      );

  Widget buildProfileImage() => Container(
        width: profileHeight,
        height: profileHeight,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assests/images/profile1.png'),
            fit: BoxFit.cover,
          ),
          color: Colors.grey.shade800,
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xffffd85b), width: 4),
        ),
      );

  Widget buildAuthorSection() => Padding(
        padding: const EdgeInsets.only(right: 26,left: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'the_writer09',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Aruhi Dixit',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            buildFollowButton(),
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
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
          decoration: BoxDecoration(
            color: isFollowing
                ? Colors.transparent
                : const Color(0xffffd85b),
            border: Border.all(color: const Color.fromRGBO(255, 204, 40, 1)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isFollowing ? 'Unfollow' : 'Follow',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  Widget buildAboutSection() => const Padding(
        padding: EdgeInsets.only(right: 26,left: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Me',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has dbhwdhag bsghwv abbsghgx abhh......',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
            Text(
              'Read More>',
              style: TextStyle(
                color: Color(0xff4a4a4a),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      );

  Widget buildStatsSection() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildStatItem('Followers', '50+'),
            buildStatItem('Following', '50+'),
            buildStatItem('Posts', '6'),
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
        padding: const EdgeInsets.only(right: 26,left: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                print('View All tapped');
              },
              child: const Text(
                'View All >',
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

  Widget buildUserPosts() => Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            image: const DecorationImage(
              image: AssetImage('assests/images/user1.png'), // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            image: const DecorationImage(
              image: AssetImage('assests/images/user2.png'), // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );

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
