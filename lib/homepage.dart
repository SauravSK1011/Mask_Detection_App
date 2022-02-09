import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  late File _imagefile;
  final imagepicker = ImagePicker();
  List _pridiction = [];
  @override
  void initState() {
    super.initState();
    loadmodal();
  }

  loadmodal() async {
    await Tflite.loadModel(
        model: "assets/model_unquant.tflite", labels: "assets/labels.txt");
  }

  detect_mask(File image) async {
    var pridection = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      _loading = false;
      _pridiction = pridection!;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _imageformgallery() async {
    var image = await imagepicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _imagefile = File(image.path);
    }
    detect_mask(_imagefile);
  }

  _imageformcamara() async {
    var image = await imagepicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _imagefile = File(image.path);
    }
    detect_mask(_imagefile);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Center(
          child: Text(
            "Mask Detection App",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ),
      body: Container(
        height: height,
        width: width,
        child: Column(
          children: [
            Container(
              width: 270.0,
              height: 225.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage("assets/mask.png"),
                ),
              ),
            ),
            // const Padding(
            //   padding: EdgeInsets.only(top: 12),
            //   child: Text(
            //     "Mask Detection App",
            //     style: TextStyle(
            //         color: Colors.blue,
            //         fontWeight: FontWeight.bold,
            //         fontSize: 15),
            //   ),
            // ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 170,
                child: RaisedButton(
                  onPressed: () {
                    _imageformcamara();
                  },
                  color: Colors.blue,
                  child: const Text(
                    "Camera",
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 170,
                child: RaisedButton(
                  onPressed: () {
                    _imageformgallery();
                  },
                  color: Colors.blue,
                  child: const Text(
                    "Gallery ",
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            _loading == false
                ? Column(
                    children: [
                      Container(
                        height: 200,
                        width: 200,
                        child: Image.file(_imagefile),
                      ),
                      Text(_pridiction[0]["label"] != null
                          ? _pridiction[0]["label"]
                              .toString()
                              .substring(2)
                              .toUpperCase()
                          : "Retry"),
                      Text("Probability - " +
                          (_pridiction[0]["confidence"] != null
                              ? (_pridiction[0]["confidence"]
                                      .toString()
                                      .substring(2, 4) +
                                  "%")
                              : "retry"))
                    ],
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
