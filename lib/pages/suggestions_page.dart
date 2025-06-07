import 'package:flutter/material.dart';

class SuggestionsPage extends StatelessWidget {
  final Color _primaryColor = Color.fromARGB(179, 205, 194, 255);
  final Color _accentColor = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saran dan Kesan',
          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _primaryColor.withOpacity(0.1),
              _primaryColor.withOpacity(0.3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      'Overall Experience',
                      Icons.star,
                      'Memorable',
                      Colors.amber,
                    ),
                    _buildSection(
                      context,
                      'Keterangan Tambahan',
                      Icons.note,
                      'Hidup menantang penuh dengan kopi , enak',
                      _accentColor,
                    ),
                    _buildSection(
                      context,
                      'Saran untuk Pengembangan',
                      Icons.lightbulb,
                      'Cih kurang menantang, hmmmpph !!\n'
                          'Harusnya buat app untuk Smartwatch, need more cafeiine',

                      Colors.red,
                    ),
                    SizedBox(height: 30),
                    _buildThankYouSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    String content,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(content, style: TextStyle(fontSize: 16, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildThankYouSection() {
    return Center(
      child: Column(
        children: [
          Text(
            'Terima kasih atas pengajarannya!',
            style: TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: _accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
