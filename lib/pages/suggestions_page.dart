import 'package:flutter/material.dart';

class SuggestionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saran dan Kesan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Overall', 'Biasa'),
            _buildSection(
              'Keterangan Tambahan',
              'Hidup seperti sugab seungguh memorable dan berotak senku',
            ),
            _buildSection(
              'Saran',
              'Jangan terlalu memaksakan, project terlalu sulit',
            ),
            Spacer(),
            Center(
              child: Text(
                'Terima kasih atas pengajarannya!',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 16)),
          Divider(color: Colors.grey),
        ],
      ),
    );
  }
}
