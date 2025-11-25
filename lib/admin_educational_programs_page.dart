import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEducationalProgramsPage extends StatelessWidget {
  const AdminEducationalProgramsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Programs (Admin)'),
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
              final doc = programs[i];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['Program_Name'] ?? '';
              final imageUrl = data['image1'] ?? '';
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: imageUrl.isNotEmpty
                                ? Image.network(imageUrl, fit: BoxFit.cover)
                                : Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.menu_book, size: 50))),
                          ),
                          Positioned(
                            top: 2, right: 2,
                            child: Row(
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => EditProgramForm(docId: doc.id, oldData: data)
                                        ),
                                      );
                                    }
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Delete?'),
                                        content: const Text('Really delete this program?'),
                                        actions: [
                                          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context, false)),
                                          TextButton(child: const Text('Delete'), onPressed: () => Navigator.pop(context, true)),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await doc.reference.delete();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1B5E20))),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddProgramForm())
        ),
      ),
    );
  }
}

// ---- ADD PROGRAM FORM ----
class AddProgramForm extends StatefulWidget {
  const AddProgramForm({Key? key}) : super(key: key);

  @override
  State<AddProgramForm> createState() => _AddProgramFormState();
}

class _AddProgramFormState extends State<AddProgramForm> {
  final _titleController = TextEditingController();
  final List<TextEditingController> _imageControllers = [TextEditingController()];
  final _descController = TextEditingController();
  bool _loading = false;

  void _addImageField() => setState(() => _imageControllers.add(TextEditingController()));

  Future<void> _saveProgram() async {
    setState(() => _loading = true);
    Map<String, String> imageMap = {
      for (int i = 0; i < _imageControllers.length; i++)
        'image${i+1}': _imageControllers[i].text.trim(),
    };

    await FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Educational_Programs_Page')
        .collection('All_Educational_Programs')
        .add({
      'Program_Name': _titleController.text.trim(),
      ...imageMap,
      'Description': _descController.text.trim(),
      'Order': DateTime.now().millisecondsSinceEpoch,
    });
    setState(() => _loading = false);
    if(mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var c in _imageControllers) { c.dispose(); }
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Educational Program")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Program Title"),
            ),
            const SizedBox(height: 14),
            const Text("Image URLs"),
            ..._imageControllers.asMap().entries.map((entry) => Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: entry.value,
                    decoration: InputDecoration(labelText: "Image ${entry.key + 1}", hintText: "Paste image URL"),
                  ),
                ),
                if (entry.key == _imageControllers.length - 1)
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate),
                    onPressed: _addImageField,
                    tooltip: "Add Another Image",
                  ),
              ],
            )),
            const SizedBox(height: 14),
            const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _descController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Describe the program...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save Program"),
                onPressed: _saveProgram,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- EDIT PROGRAM FORM ----
class EditProgramForm extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> oldData;
  const EditProgramForm({Key? key, required this.docId, required this.oldData}) : super(key: key);

  @override
  State<EditProgramForm> createState() => _EditProgramFormState();
}

class _EditProgramFormState extends State<EditProgramForm> {
  late TextEditingController _titleController;
  late List<TextEditingController> _imageControllers;
  late TextEditingController _descController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.oldData['Program_Name'] ?? '');
    _imageControllers = [];
    int i = 1;
    while (widget.oldData.containsKey('image$i')) {
      _imageControllers.add(TextEditingController(text: widget.oldData['image$i'] ?? ''));
      i++;
    }
    if (_imageControllers.isEmpty) {
      _imageControllers.add(TextEditingController());
    }
    _descController = TextEditingController(text: widget.oldData['Description'] ?? "");
  }

  void _addImageField() => setState(() => _imageControllers.add(TextEditingController()));

  Future<void> _updateProgram() async {
    setState(() => _loading = true);

    Map<String, String> imageMap = {
      for (int i = 0; i < _imageControllers.length; i++)
        'image${i+1}': _imageControllers[i].text.trim(),
    };

    await FirebaseFirestore.instance
        .collection('All_Data')
        .doc('Educational_Programs_Page')
        .collection('All_Educational_Programs')
        .doc(widget.docId)
        .update({
      'Program_Name': _titleController.text.trim(),
      ...imageMap,
      'Description': _descController.text.trim(),
    });
    setState(() => _loading = false);
    if(mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var c in _imageControllers) { c.dispose(); }
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Program")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Program Title")),
            const SizedBox(height: 14),
            const Text("Image URLs"),
            ..._imageControllers.asMap().entries.map((entry) => Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: entry.value,
                    decoration: InputDecoration(labelText: "Image ${entry.key + 1}", hintText: "Paste image URL"),
                  ),
                ),
                if (entry.key == _imageControllers.length - 1)
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate),
                    onPressed: _addImageField,
                    tooltip: "Add Another Image",
                  ),
              ],
            )),
            const SizedBox(height: 14),
            const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _descController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Describe the program...",
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Update Program"),
                onPressed: _updateProgram,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
