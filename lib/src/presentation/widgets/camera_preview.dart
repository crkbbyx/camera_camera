import 'package:camera_camera/src/presentation/controller/camera_camera_controller.dart';
import 'package:camera_camera/src/presentation/controller/camera_camera_status.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path/path.dart' as photoPath;
import 'package:flutter/services.dart';
import 'dart:async';

// Data
import 'package:jobsitemobile/providers/appt_file.dart';
import 'package:jobsitemobile/providers/captured_photos.dart';

// Screens
import 'package:jobsitemobile/screens/app_image_viewer_screen.dart';
import 'package:jobsitemobile/screens/app_detail_screen.dart';
import 'package:jobsitemobile/screens/app_techphotos_screen.dart';

// Helpers
import 'package:jobsitemobile/helpers/functionality_helper.dart';
import 'package:jobsitemobile/helpers/shared_pref_management.dart';

class CameraCameraPreview extends StatefulWidget {
  final void Function(String value)? onFile;
  final CameraCameraController controller;
  final bool enableZoom;
  final int? appt_server_id;
  final bool? returns;

  CameraCameraPreview({
    Key? key,
    this.onFile,
    required this.controller,
    required this.enableZoom,
    this.appt_server_id,
    this.returns,
  }) : super(key: key);

  @override
  _CameraCameraPreviewState createState() => _CameraCameraPreviewState();
}

class _CameraCameraPreviewState extends State<CameraCameraPreview> {

  bool doneDataFetchOnce = false;
  int? appt_server_id;
  bool? returns;

  Future<List<String>>? futureList;
  List<String> itemList = [];
  List<String> itemListDone = [];

  Future<List<String>>? fetchList() async {
    //ApptFile().dummyThing();
    SharedPrefManagement prefs = SharedPrefManagement();
    await prefs.getCapturedPhotos().then((processCapturedPhotos) async {
      if(processCapturedPhotos != null) {
        processCapturedPhotos.forEach((myfile) async {
          itemList.remove(myfile.toString());
          itemList.add(myfile.toString());
        });
      }
    });
    return itemList;
  }

  void addItem() {
    itemList.add('anotherItem');
  }

  @override
  void initState() {
    widget.controller.init();
    futureList = fetchList();
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

    CapturedPhotos dummyProvider = Provider.of<CapturedPhotos>(context, listen: true);

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

                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            padding: EdgeInsets.all(0.0),
                            color: Colors.black38,
                            width: size.width,
                            child: SizedBox(
                              height: 60.0,
                              width: double.infinity,
                              child: FutureBuilder(
                                future: fetchList(),
                                builder: (context, AsyncSnapshot<List<String>> snapshot) {
                                  if(snapshot.hasData) {
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data?.length,
                                      itemBuilder: (context, index) {
                                        return
                                          Card(
                                            elevation: 4.0,
                                            semanticContainer: true,
                                            clipBehavior: Clip.antiAliasWithSaveLayer,
                                            child: Stack(
                                              children: [
                                                Image.file(File(itemList[index].toString())),
                                                Positioned(
                                                  top: 0.0,
                                                  right: 0.0,
                                                  child: FaIcon(FontAwesomeIcons.check, size: 9.0, color: Colors.green),
                                                ),
                                              ],),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4.0),
                                            ),
                                          );
                                      },
                                    );
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),


                        SafeArea(child: SizedBox(
                          height: 65.0,
                          width: double.infinity,
                          child: ElevatedButton.icon(

                            icon: Icon(FontAwesomeIcons.checkDouble),
                            label: Text('Done Taking Photos'),
                            onPressed: () {
                              Navigator.of(context).popAndPushNamed(
                                AppTechPhotosScreen.routeName,
                                arguments: {
                                  'appt_server_id': widget.appt_server_id,
                                  'returns': widget.returns,
                                },
                              );
                              // Navigator.popUntil(context, ModalRoute.withName('/app-detail-screen'));
                            },
                            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(0.0),
                                topLeft: Radius.circular(0.0),
                                bottomRight: Radius.circular(0.0),
                                bottomLeft: Radius.circular(0.0),
                              ),
                            ), padding: EdgeInsets.fromLTRB(0.0, 0, 0, 0), elevation: 0.0),
                          ),),),
                        if (widget.controller.flashModes.length > 1)
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(32.0, 0.0, 0.0, 64.0),
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
                              padding: const EdgeInsets.only(bottom: 64.0),
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
