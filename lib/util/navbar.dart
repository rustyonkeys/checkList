import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class LiquidGlassNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  LiquidGlassNavbar({required this.selectedIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0, bottom: 24.0), // Added bottom padding
      child: Row(
        children: [
          // Main Navbar with 3 icons
          GlassmorphicContainer(
            width: MediaQuery.of(context).size.width * 0.65, // Reduced length to 65% of screen width
            height: 65,
            borderRadius: 30,
            blur: 15,
            alignment: Alignment.center,
            border: 1.5,
            linearGradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderGradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1)
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16), // Reduced horizontal padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed to spaceBetween for tighter spacing
                children: [
                  // Home Icon
                  _buildNavIcon(
                    icon: Icons.home_rounded,
                    index: 0,
                    label: 'Home',
                  ),

                  // Notification Icon
                  _buildNavIcon(
                    icon: Icons.analytics,
                    index: 2,
                    label: 'Notifications',
                  ),

                  // Notification Icon
                  _buildNavIcon(
                    icon: Icons.notifications_rounded,
                    index: 2,
                    label: 'Notifications',
                  ),

                  // Profile Icon
                  _buildNavIcon(
                    icon: Icons.person_rounded,
                    index: 3,
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 12), // Space between navbar and add button

          // Separate Add Button
          _buildSeparateAddButton(),
        ],
      ),
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(8),
        child: Icon(
          icon,
          color: isSelected ? Color(0xFF5B8DEE) : Colors.white.withOpacity(0.6),
          size: 40,
        ),
      ),
    );
  }

  Widget _buildSeparateAddButton() {
    final isSelected = selectedIndex == 4;
    return GestureDetector(
      onTap: () => onTabSelected(4),
      child: GlassmorphicContainer(
        width: 65,
        height: 65,
        borderRadius: 40,
        blur: 15,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1)
          ],
        ),
        child: Icon(
          Icons.add_rounded,
          color: isSelected ? Color(0xFF5B8DEE) : Colors.white.withOpacity(0.6),
          size: 30,
        ),
      ),
    );
  }
}