import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _loading = true;
  File? _image;
  final imagepiker = ImagePicker();
  List _predictions = [];

  Future detect_image(File image) async {
    var prediction = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _loading = false;
      _predictions = prediction!;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadmodel();
  }

  loadmodel() async {
    //Tflite.close();
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite',
        labels: 'assets/labels.txt',
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _loadimage_gallery() async {
    var image = await imagepiker.getImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );

    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }

    //_loading = false;
    detect_image(_image!);
  }

  Future _loadimage_camera() async {
    var image = await imagepiker.getImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detect_image(_image!);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: ExactAssetImage("assets/maskimg.jpg"),
                  fit: BoxFit.cover)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.0),
              ),
            ),
          ),
        ),
        Scaffold(
            appBar: AppBar(
              centerTitle: true,
              shape: StadiumBorder(
                  side: BorderSide(color: Color.fromARGB(255, 247, 245, 245))),
              title: Text(
                'Face Mask Detection',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            body: Column(
              children: [
                FlipCard(
                  direction: FlipDirection.HORIZONTAL,
                  front: Container(
                    height: MediaQuery.of(context).size.height * .4,
                    width: MediaQuery.of(context).size.width * .9,
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(width: 1, color: Colors.white)),
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "Click To Choose Image From Camera",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 28),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: (() {
                              _loadimage_camera();
                            }),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.white),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                'Camera',
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            "Tap on card to choose image from Gallery",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  back: Container(
                    height: MediaQuery.of(context).size.height * .4,
                    width: MediaQuery.of(context).size.width * .9,
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(width: 1, color: Colors.white)),
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "Click To Choose Image From gallery",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: (() {
                              _loadimage_gallery();
                            }),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.white),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                'Gallery',
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            "Tap on card to choose image from Camera",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _loading == false
                    ? Container(
                        child: Column(
                          children: [
                            Container(
                              // width: 150,
                              // height: 150,
                              height: MediaQuery.of(context).size.height * .2,
                              width: MediaQuery.of(context).size.width * .5,
                              padding: EdgeInsets.all(5),
                              child: Image.file(_image!),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.white,
                                  )),
                            ),
                            Text(_predictions[0]['label']
                                .toString()
                                .substring(2)),
                            Text(_predictions[0]['Confidance'].toString())
                          ],
                        ),
                      )
                    : Container(),
              ],
            )),
      ],
    );
  }
}
