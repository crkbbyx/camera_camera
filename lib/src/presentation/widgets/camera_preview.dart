import 'package:camera_camera/src/presentation/controller/camera_camera_controller.dart';
import 'package:camera_camera/src/presentation/controller/camera_camera_status.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:io';

import 'package:jobsitemobile/screens/app_detail_screen.dart';


class CameraCameraPreview extends StatefulWidget {
  final void Function(String value)? onFile;
  final CameraCameraController controller;
  final bool enableZoom;

  CameraCameraPreview({
    Key? key,
    this.onFile,
    required this.controller,
    required this.enableZoom,
  }) : super(key: key);

  @override
  _CameraCameraPreviewState createState() => _CameraCameraPreviewState();
}

class _CameraCameraPreviewState extends State<CameraCameraPreview> {

  @override
  void initState() {
    widget.controller.init();
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;

    final List<String> imgList = [
      'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
      'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
      'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
      'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
      'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
      'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
    ];

    return ValueListenableBuilder<CameraCameraStatus>(
      valueListenable: widget.controller.statusNotifier,
      builder: (_, status, __) =>
          status.when(
              success: (camera) =>
                  GestureDetector(
                    onScaleUpdate: (details) {
                      widget.controller.setZoomLevel(details.scale);
                    },
                    child: Stack(
                      children: [
                        Center(child: widget.controller.buildPreview()),

                        SafeArea(child: Column(children: [
                          SizedBox(
                            height: 55.0,
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: Icon(FontAwesomeIcons.checkDouble),
                              label: Text('Done Taking Photos'),
                              onPressed: () {
                                Navigator.popUntil(context, ModalRoute.withName('/app-detail-screen'));
                              },
                              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(0.0),
                                  topLeft: Radius.circular(0.0),
                                  bottomRight: Radius.circular(0.0),
                                  bottomLeft: Radius.circular(0.0),
                                ),
                              ), padding: EdgeInsets.fromLTRB(0.0, 0, 0, 0), elevation: 0.0),
                            ),),

                          // Place to Preview images just took?
                          Container(
                            height: 55.0,
                            width: size.width,
                            child: CarouselSlider.builder(
                              options: CarouselOptions(
                                //aspectRatio: 2.0,
                                enlargeCenterPage: false,
                                viewportFraction: .25,
                              ),
                              itemCount: imgList.length,
                              itemBuilder: (context, index, realIdx) {
                                //final int first = index * 2;
                                //final int second = first + 1;
                                return Container(
                                  height: 55.0,
                                  width: 50.0,
                                  //margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Image.network(imgList[index], fit: BoxFit.fitHeight, height: 50.0,),
                                );
                              },
                            ),
                          ),
                        ],),),


                        if (widget.enableZoom)
                          Positioned(
                            bottom: 105,
                            left: 0.0,
                            right: 0.0,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.black.withOpacity(0.6),
                              child: IconButton(
                                icon: Center(
                                  child: Text(
                                    "${camera.zoom.toStringAsFixed(1)}x",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                onPressed: () {
                                  widget.controller.zoomChange();
                                },
                              ),
                            ),
                          ),
                        if (widget.controller.flashModes.length > 1)
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(32.0, 0.0, 0.0, 32.0),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.black.withOpacity(0.6),
                                child: IconButton(
                                  onPressed: () {
                                    widget.controller.changeFlashMode();
                                  },
                                  icon: Icon(
                                    camera.flashModeIcon,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 32.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      widget.controller.takePhoto();
                                    },
                                    child: CircleAvatar(
                                      child: FaIcon(
                                        FontAwesomeIcons.camera,
                                        size: 24.0,
                                      ),
                                      radius: 30,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),

                                ],
                              )
                          ),
                        ),

                      ],
                    ),
                  ),
              failure: (message, _) =>
                  Container(
                    color: Colors.black,
                    child: Text(message),
                  ),
              orElse: () =>
                  Container(
                    color: Colors.black,
                  )),
    );
  }
}
