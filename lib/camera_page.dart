import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'gallery_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool isFrontCamera = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _setupCamera();
  }

  void _setupCamera() {
    if (_cameras == null || _cameras!.isEmpty) return;

    CameraDescription selectedCamera = isFrontCamera
        ? _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras!.first,
          )
        : _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () => _cameras!.first,
          );

    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
    );

    _controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    }).catchError((e) {
      print("Error initializing camera: $e");
    });
  }

  void _toggleCamera() {
    setState(() {
      isFrontCamera = !isFrontCamera;
      _setupCamera();
    });
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile image = await _controller!.takePicture();
      final File file = File(image.path);
      await Gal.putImage(file.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Saved to gallery!")),
      );
      setState(() {});
    } catch (e) {
      print("Error taking photo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double previewHeight = screenWidth * (4 / 3);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        backgroundColor: Colors.black87,
        centerTitle: true,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),  // Change the color of the back button here
          onPressed: () {
            Navigator.pop(context);  // Navigate back to the previous page
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 50, 52, 56), Color.fromARGB(255, 170, 165, 171)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _controller != null && _controller!.value.isInitialized
                  ? Container(
                      width: screenWidth,
                      height: previewHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: CameraPreview(_controller!),
                        ),
                      ),
                    )
                  : const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space the buttons evenly
                children: [
                  // Gallery Button (left)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GalleryPage()),  // Navigate to gallery page
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    child: const Text('Gallery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  // Take Photo Button (middle)
                  ElevatedButton(
                    onPressed: _takePhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    child: Text(
                      isFrontCamera ? '📸 Front Camera' : '📸 Rear Camera',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Switch Camera Button (right)
                  ElevatedButton(
                    onPressed: _toggleCamera,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    child: const Text('🔄 Switch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}