import 'dart:io';

import 'package:arca/views/pages/lg_settings.dart';
import 'package:flutter/material.dart';
import 'package:arca/utils/constants.dart';
import 'package:arca/services/lg_service.dart';
import 'package:ssh2/ssh2.dart';

class GalleryScreen extends StatefulWidget {
  final SSHClient? sshClient;
  GalleryScreen({Key? key, this.sshClient}) : super(key: key);

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final List<String> _images = [];
  LGService? lgService;

  void loadImages() {
    const String folderPath = 'assets/gallery/vineyard';

    Directory(folderPath).listSync().forEach((FileSystemEntity entity) {
      if (entity is File && entity.path.endsWith('.jpg') ||
          entity.path.endsWith('.png')) {
        final String relativePath = Uri.file(entity.path).path;
        _images.add(relativePath);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    lgService = widget.sshClient != null
        ? LGSettings.createLGService(widget.sshClient)
        : null;
  }

  bool isAscending = true;
  bool isShowingFullImage = false;
  String selectedImage = '';

  @override
  Widget build(BuildContext context) {
    loadImages();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text(
          'Gallery',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          splashRadius: 24,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.photo,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: isShowingFullImage ? buildFullImage() : buildImageGrid(),
    );
  }

  Widget buildImageGrid() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              isAscending = !isAscending;
              if (isAscending) {
                _images.sort();
              } else {
                _images.sort((a, b) => b.compareTo(a));
              }
            });
          },
          child: Text(isAscending ? 'Order A-Z' : 'Order Z-A'),
        ),
      ),
      Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.only(
              left: defaultPadding * 3, right: defaultPadding * 3),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: defaultPadding,
            mainAxisSpacing: defaultPadding,
          ),
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedImage = _images[index];
                  isShowingFullImage = true;
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  _images[index],
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      )
    ]);
  }

  Widget buildFullImage() {
    return Stack(
      children: [
        Center(
          child: Image.asset(
            selectedImage,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          top: 40,
          right: 16,
          child: IconButton(
            icon: const Icon(
              Icons.close,
              size: 50,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isShowingFullImage = false;
              });
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          alignment: Alignment.bottomCenter,
          child: ElevatedButton(
            onPressed: () {
              lgService?.sendKMLToLastScreen(selectedImage);
            },
            child: const Text('Send KML'),
          ),
        ),
      ],
    );
  }
}
