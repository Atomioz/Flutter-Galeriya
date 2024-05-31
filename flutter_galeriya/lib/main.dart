import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'theme_notifier.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: FlutterGaleriyaApp(),
    ),
  );
}

class FlutterGaleriyaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Flutter-Galeriya',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: themeNotifier.themeMode,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<GalleryScreenState> _galleryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          GalleryScreen(key: _galleryKey),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class GalleryScreen extends StatefulWidget {
  GalleryScreen({Key? key}) : super(key: key);

  @override
  GalleryScreenState createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen> {
  List<dynamic> _images = [];

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

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            SwitchListTile(
              title: Text('Dark Mode'),
              value: themeNotifier.themeMode == ThemeMode.dark,
              onChanged: (bool value) {
                themeNotifier.toggleTheme(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
