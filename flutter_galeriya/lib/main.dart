import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(FlutterGaleriyaApp());
}

class FlutterGaleriyaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter-Galeriya',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GalleryScreen(),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<dynamic> _images = [];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedImages = await picker.pickMultiImage();
    if (pickedImages != null) {
      setState(() {
        if (kIsWeb) {
          _images.addAll(pickedImages.map((image) => image.path));
        } else {
          _images.addAll(pickedImages.map((image) => File(image.path)));
        }
      });
    }
  }

  void _openFullScreen(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenViewer(
          images: _images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter-Galeriya'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _openFullScreen(index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: kIsWeb
                    ? Image.network(_images[index], fit: BoxFit.cover)
                    : Image.file(_images[index], fit: BoxFit.cover),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImages,
        tooltip: 'Pick Images',
        child: Icon(Icons.add),
      ),
    );
  }
}

class FullScreenViewer extends StatelessWidget {
  final List<dynamic> images;
  final int initialIndex;

  FullScreenViewer({required this.images, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: CarouselSlider.builder(
        itemCount: images.length,
        options: CarouselOptions(
          initialPage: initialIndex,
          enableInfiniteScroll: false,
          enlargeCenterPage: true,
          height: double.infinity,
        ),
        itemBuilder: (context, index, realIndex) {
          return Center(
            child: kIsWeb
                ? Image.network(images[index], fit: BoxFit.contain)
                : Image.file(images[index], fit: BoxFit.contain),
          );
        },
      ),
    );
  }
}
