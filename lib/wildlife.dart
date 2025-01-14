import 'dart:ui';

import 'package:beeuzine/Category_Tab.dart';
import 'package:flutter/material.dart';
// Import CategoryTabs to keep consistency

class WildlifeScreen extends StatefulWidget {
  const WildlifeScreen({Key? key}) : super(key: key);

  @override
  _WildlifeScreenState createState() => _WildlifeScreenState();
}

class _WildlifeScreenState extends State<WildlifeScreen> {
  String activeCategory = 'Wildlife'; // You can change the active category here if needed
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
         Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assests/images/wild.png'), // Use a background image for wildlife
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
              child: Container(
                color: Colors.black.withOpacity(0), // Adjust the opacity as needed
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 65),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_back, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      'Top Picks of This Week',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                CategoryTabs(
                  activeCategory: activeCategory,
                  onCategoryTap: (category) {
                    setState(() {
                      activeCategory = category;
                    });
                  },
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'The Wild Adventures',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage('assests/images/Ellipse1.png'), // You can use a different profile image
                            radius: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'wildlife_explorer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: isExpanded
                                    ? 'Wildlife is an essential part of nature, and exploring the diverse species around the world opens up new understanding of ecosystems. Conservation efforts are crucial to protecting endangered species.'
                                    : 'Wildlife is an essential part of nature... Read more for more exciting facts!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              WidgetSpan(
                                child: SizedBox(width: 10), // Horizontal space
                              ),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isExpanded = !isExpanded;
                                    });
                                  },
                                  child: Text(
                                    isExpanded ? ' Show Less' : ' Read More >',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
