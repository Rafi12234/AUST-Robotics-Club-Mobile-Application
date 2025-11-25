import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EducationalProgramsPage extends StatelessWidget {
  const EducationalProgramsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Programs'),
        backgroundColor: const Color(0xFF1B5E20),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('All_Data')
            .doc('Educational_Programs_Page')
            .collection('All_Educational_Programs')
            .orderBy('Order')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No educational programs yet.'));
          }
          final programs = snapshot.data!.docs;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.80
            ),
            itemCount: programs.length,
            itemBuilder: (ctx, i) {
              final data = programs[i].data() as Map<String, dynamic>;
              final title = data['Program_Name'] ?? '';
              final imageUrl = data['image1'] ?? '';
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProgramDetailPage(programData: data)),
                ),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Expanded(
                        child: imageUrl.isNotEmpty
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.menu_book, size: 50))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---- See program detail page ----
class ProgramDetailPage extends StatelessWidget {
  final Map<String, dynamic> programData;
  const ProgramDetailPage({Key? key, required this.programData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> images = [];
    for (int i = 1; ; i++) {
      final url = programData['image$i'];
      if (url == null || url.toString().isEmpty) break;
      images.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Image.network(url, fit: BoxFit.contain),
      ));
    }
    final description = programData['Description'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(programData['Program_Name'] ?? 'Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...images,
            if (images.isNotEmpty) const SizedBox(height: 16),
            if (description.isNotEmpty) ...[
              const Divider(height: 32),
              Text(description, style: const TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }
}
