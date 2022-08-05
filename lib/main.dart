import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panorama/panorama.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: Text('Image Files')), body: FilePick()),
    );
  }
}

class FilePick extends StatefulWidget {
  const FilePick({Key? key}) : super(key: key);

  @override
  State<FilePick> createState() => _FilePickState();
}

class _FilePickState extends State<FilePick> {
  File? image;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    final status;
    if (Platform.isIOS) {
      status = await Permission.photos.status;
    } else if (Platform.isAndroid) {
      status = await Permission.storage.status;
    } else {
      status = "error";
    }
    setState(() => _permissionStatus = status);
  }

  Future pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;
    final imageTemporary = File(image.path);
    print(image.path);
    setState(() {
      this.image = imageTemporary;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionStatus == PermissionStatus.granted) {
      return Scaffold(
          body: Container(
              child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextButton(
            onPressed: () {
              pickImage();
            },
            child: Text("PICK FROM GALLERY"),
          ),
          image != null ? ImageWidget(myFile: image!) : Container()
        ],
      )));
    } else {
      return Container(
        child: TextButton(
          child: Text("Grant Permission"),
          onPressed: () => requestPermission(
              Platform.isIOS ? Permission.photos : Permission.storage),
        ),
      );
    }
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }
}

class PanoramaWidget extends StatelessWidget {
  File myFile;
  PanoramaWidget({Key? key, required this.myFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: Panorama(
        child: Image.file(myFile),
      )),
    );
  }
}

class ImageWidget extends StatelessWidget {
  File myFile;
  ImageWidget({Key? key, required this.myFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PanoramaWidget(myFile: myFile)));
              print("changed to new screen");
            },
            child: Image.file(myFile)),
        SizedBox(
          height: 20,
        ),
        Text(
          "Tap for 360 View",
          style: TextStyle(fontSize: 20, color: Colors.black54),
        )
      ],
    );
  }
}
