import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_camera/src/core/camera_bloc.dart';
import 'package:camera_camera/src/core/camera_service.dart';
import 'package:camera_camera/src/core/camera_status.dart';
import 'package:camera_camera/src/presentation/widgets/camera_preview.dart';
import 'package:camera_camera/src/shared/entities/camera_side.dart';
import 'package:flutter/material.dart';

class CameraCamera extends StatefulWidget {
  ///Define your prefer resolution
  final ResolutionPreset resolutionPreset;

  ///CallBack function returns File your photo taken
  final void Function(File file) onFile;

  ///Define types of camera side is enabled
  final CameraSide cameraSide;

  ///Define your accepted [FlashMode]s
  final List<FlashMode> flashModes;

  ///Enable zoom camera ( default = true )
  final bool enableZoom;

  ///Whether to allow audio recording. This can remove the microphone
  ///permission on Android
  final bool enableAudio;

  final int? appt_server_id;
  final bool? returns;
  
  CameraCamera({
    Key? key,
    this.resolutionPreset = ResolutionPreset.ultraHigh,
    required this.onFile,
    this.cameraSide = CameraSide.all,
    this.flashModes = FlashMode.values,
    this.enableZoom = true,
    this.enableAudio = false,
    this.appt_server_id,
    this.returns,
  }) : super(key: key);

  @override
  _CameraCameraState createState() => _CameraCameraState();
}

class _CameraCameraState extends State<CameraCamera> {
  late CameraBloc bloc;
  late StreamSubscription _subscription;
  @override
  void initState() {
    bloc = CameraBloc(
      flashModes: widget.flashModes,
      service: CameraServiceImpl(),
      onPath: (path) => widget.onFile(File(path)),
      cameraSide: widget.cameraSide,
      enableAudio: widget.enableAudio,
    );
    bloc.init();
    _subscription = bloc.statusStream.listen((state) {
      return state.when(
          orElse: () {},
          selected: (camera) async {
            bloc.startPreview(widget.resolutionPreset);
          });
    });
    super.initState();
  }

  @override
  void dispose() {
    bloc.dispose();
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: StreamBuilder<CameraStatus>(
        stream: bloc.statusStream,
        initialData: CameraStatusEmpty(),
        builder: (_, snapshot) => snapshot.data!.when(
            preview: (controller) => Stack(
                  children: [
                    CameraCameraPreview(
                      enableZoom: widget.enableZoom,
                      key: UniqueKey(),
                      controller: controller,
                      appt_server_id: widget.appt_server_id,
                      returns: widget.returns,
                    ),
                    if (bloc.status.preview.cameras.length > 1)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 32.0, 64.0),
                          child: InkWell(
                            onTap: () {
                              bloc.changeCamera();
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.black.withOpacity(0.6),
                              child: Icon(
                                Platform.isAndroid
                                    ? Icons.flip_camera_android
                                    : Icons.flip_camera_ios,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
            failure: (message, _) => Container(
                  color: Colors.black,
                  child: Text(message),
                ),
            orElse: () => Container(
                  color: Colors.black,
                )),
      ),
    );
  }
}
