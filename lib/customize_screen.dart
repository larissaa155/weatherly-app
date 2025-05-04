import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomizeScreen extends StatefulWidget {
  @override
  _CustomizeScreenState createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  Color _selectedColor = Colors.blue;
  File? _backgroundImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _backgroundImage = File(image.path));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('background_image', image.path);
    }
  }

  Future<void> _saveColorPreference(Color color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_color', color.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customize')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Choose a Theme Color', style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 10,
              children: Colors.primaries
                  .take(8)
                  .map((color) => GestureDetector(
                        onTap: () {
                          setState(() => _selectedColor = color);
                          _saveColorPreference(color);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: _selectedColor == color
                                ? Border.all(width: 3, color: Colors.black)
                                : null,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            Text('Upload Custom Background Image',
                style: TextStyle(fontSize: 18)),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick from Gallery'),
            ),
            if (_backgroundImage != null) ...[
              SizedBox(height: 20),
              Image.file(_backgroundImage!, height: 200),
            ]
          ],
        ),
      ),
    );
  }
}
