import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'camera_page.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<File> _galleryImages = [];

  Future<void> _loadImagesFromGallery() async {
    final List<XFile> images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _galleryImages = images.map((image) => File(image.path)).toList();
      });
    }
  }

  void _viewFullScreenImage(File image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImagePage(image: image),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadImagesFromGallery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);  // Navigate back to the previous page
          },
        ),
      ),
      body: SingleChildScrollView(  // Wrap the entire body in a SingleChildScrollView
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _loadImagesFromGallery,
                    child: const Text('📂 Load Images'),
                  ),
                  const SizedBox(width: 10),  // เว้นระยะระหว่างปุ่ม
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CameraPage()),
                      );
                    },
                    child: const Text('📸 Open Camera'),
                  ),
                ],
              ),
            ),
            _galleryImages.isNotEmpty
                ? GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _galleryImages.length,
                    shrinkWrap: true,  // Ensure the grid takes up only the necessary space
                    physics: const NeverScrollableScrollPhysics(),  // Disable grid scrolling since we're using the outer scroll view
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _viewFullScreenImage(_galleryImages[index]),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 10,  // Space at the top for Polaroid style
                                color: Colors.white,
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.black, width: 0.25),  // Thicker border
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _galleryImages[index],
                                      fit: BoxFit.cover,  // Ensure the image fits inside the border
                                      width: double.infinity,  // Fixed width for Polaroid effect
                                      height: double.infinity,  // Fixed height for Polaroid effect
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                height: 40,
                                // Add Polaroid-style text here if necessary
                                child: const Center(
                                  child: Text(
                                    'Polaroid by pathipat',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text('No images available')),
          ],
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final File image;

  const FullScreenImagePage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Full Screen View', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Image.file(
            image,
            fit: BoxFit.contain,  // Use BoxFit.contain to fit image without cropping
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}