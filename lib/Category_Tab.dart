import 'package:beeuzine/romance.dart';
import 'package:beeuzine/wildlife.dart';
import 'package:flutter/material.dart';



class CategoryTabs extends StatelessWidget {
  final String activeCategory;
  final Function(String) onCategoryTap;

  const CategoryTabs({
    Key? key,
    required this.activeCategory,
    required this.onCategoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CategoryTab(
            label: 'Romance',
            isActive: activeCategory == 'Romance',
            onTap: () {
              // Navigate to WildlifeScreen when the Wildlife tab is clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TopPicksScreen()),
              );
            },
          ),
          CategoryTab(
            label: 'Wildlife',
            isActive: activeCategory == 'Wildlife',
            onTap: () {
              // Navigate to WildlifeScreen when the Wildlife tab is clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WildlifeScreen()),
              );
            },
          ),
          CategoryTab(
            label: 'World Affairs',
            isActive: activeCategory == 'World Affairs',
            onTap: () => onCategoryTap('World Affairs'),
          ),
          CategoryTab(
            label: 'Anime',
            isActive: activeCategory == 'Anime',
            onTap: () => onCategoryTap('Anime'),
          ),
          CategoryTab(
            label: 'Nature',
            isActive: activeCategory == 'Nature',
            onTap: () => onCategoryTap('Nature'),
          ),
        ],
      ),
    );
  }
}

class CategoryTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const CategoryTab({
    Key? key,
    required this.label,
    this.isActive = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 50,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}
