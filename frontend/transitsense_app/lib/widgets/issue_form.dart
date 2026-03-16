import 'package:flutter/material.dart';

class IssueForm extends StatefulWidget {
  const IssueForm({super.key});

  @override
  State<IssueForm> createState() => _IssueFormState();
}

class _IssueFormState extends State<IssueForm> {

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  void submitIssue() {
    final description = descriptionController.text;
    final location = locationController.text;

    if (description.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Issue submitted successfully")),
    );

    descriptionController.clear();
    locationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: "Issue Description",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),

        const SizedBox(height: 16),

        TextField(
          controller: locationController,
          decoration: const InputDecoration(
            labelText: "Location",
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: submitIssue,
            child: const Text("Submit Issue"),
          ),
        ),
      ],
    );
  }
}