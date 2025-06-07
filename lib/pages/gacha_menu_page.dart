import 'package:flutter/material.dart';
import 'package:gachafigo/pages/gacha_page.dart';
import 'package:gachafigo/pages/event_game_page.dart';
import 'package:gachafigo/pages/profile_page.dart';
import 'package:gachafigo/pages/topup_page.dart';
import 'package:gachafigo/pages/accelerometer_game.dart';

class HomeMenu extends StatelessWidget {
  final VoidCallback onGachaPressed;
  final String username;
  final int credit;

  const HomeMenu({
    Key? key,
    required this.onGachaPressed,
    required this.username,
    required this.credit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUserInfoCard(context),
          const SizedBox(height: 20),
          _buildGachaButton(context),
          const SizedBox(height: 20),
          _buildFeatureGrid(context),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundImage: NetworkImage(
                    'https://static.atlasacademy.io/NA/CharaGraph/9400030/9400030a.png',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $username',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Credit: $credit',
                        style: TextStyle(fontSize: 16, color: Colors.blue[800]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGachaButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onGachaPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[400],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
      ),
      child: const Text(
        'GACHA NOW (150 Credit)',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildFeatureItem(
          context,
          Icons.person_2_sharp,
          'Profile',
          Colors.amber,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
        _buildFeatureItem(
          context,
          Icons.attach_money,
          'Top Up',
          Colors.green,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TopUpPage()),
            );
          },
        ),
        _buildFeatureItem(
          context,
          Icons.sports_basketball,
          'Game One Ball',
          Colors.purple,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventGamePage()),
            );
          },
        ),
        _buildFeatureItem(
          context,
          Icons.sports_baseball,
          'Game Two Ball',
          Colors.blue,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccelerometerGame()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
