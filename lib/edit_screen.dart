import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditScreen extends StatefulWidget {
  final bool edit;
  final bool add;
  final String? noteId;
  final String? title;
  final String? content;
  const EditScreen(
      {super.key,
      this.noteId,
      this.title,
      this.content,
      required this.edit,
      required this.add});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    contentController = TextEditingController(text: widget.content);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> updateNote() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(widget.noteId)
          .update({
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating note: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addNote() async {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (titleController.text.trim().isEmpty &&
        contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title or content')),
      );
      return;
    }


    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('notes').add({
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
        'uid': uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note added successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding note: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String getAppBarTitle() {
    if (widget.edit == true) return 'Edit Notes';
    if (widget.add == true) return 'Add Notes';
    return 'View Notes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          getAppBarTitle(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        actions: [
          if (widget.edit == true)
            IconButton(
              icon: const Icon(Icons.check, size: 30, color: Colors.white),
              onPressed: isLoading ? null : updateNote,
            ),
          if (widget.add == true)
            IconButton(
              icon: const Icon(Icons.check, size: 30, color: Colors.white),
              onPressed: isLoading ? null : addNote,
            ),
          IconButton(
            icon: const Icon(Icons.cancel, size: 30, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (widget.add == false)
              TextField(
                controller: titleController,
                readOnly: widget.edit == true ? false : true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            if (widget.edit == false && widget.add == false) const Divider(),
            if (widget.edit == true) const SizedBox(height: 16),
            if (widget.add == false)
              TextField(
                controller: contentController,
                readOnly: widget.edit == true ? false : true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                maxLines: 8,
              ),
            if (widget.add == true)
              TextField(
                controller: titleController,
                decoration:
                    const InputDecoration(hintText: 'Type the title here'),
              ),
            if (widget.add == true) const SizedBox(height: 16),
            if (widget.add == true)
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  hintText: 'Type the description',
                  border: InputBorder.none,
                ),
                maxLines: 10,
              ),
          ],
        ),
      ),
    );
  }
}
