import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'bottom_navigation.dart';

class CropDocumentPicture extends StatefulWidget {
  final File picture;
  final Function(File document, Rect? selectedArea, BuildContext dialogContext)
      nextStep;
  final Function() backStep;
  final List<Widget>? children;
  final Rect? initialArea;
  final Widget? loadingWidgetWhenCropPicture;

  const CropDocumentPicture({
    Key? key,
    required this.picture,
    required this.nextStep,
    required this.backStep,
    this.children,
    this.initialArea,
    this.loadingWidgetWhenCropPicture,
  }) : super(key: key);

  @override
  _CropDocumentPictureState createState() => _CropDocumentPictureState();
}

class _CropDocumentPictureState extends State<CropDocumentPicture> {
  final _cropController = CropController();
  late Rect initialArea = Rect.fromLTWH(
    MediaQuery.of(context).size.width * 0.5,
    MediaQuery.of(context).size.height * 0.2,
    MediaQuery.of(context).size.width - 10,
    MediaQuery.of(context).size.height - 10,
  );
  Rect? newArea;
  late BuildContext dialogContext;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialArea != null) {
      initialArea = Rect.fromLTWH(
        widget.initialArea!.left * 1.8,
        widget.initialArea!.top * 1.8,
        widget.initialArea!.width * 1.84,
        widget.initialArea!.height * 1.84,
      );
    }

    return WillPopScope(
      onWillPop: () async {
        widget.backStep();
        return false;
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Crop(
              controller: _cropController,
              image: widget.picture.readAsBytesSync(),
              onMoved: (Rect rect) {
                newArea = rect;
              },
              initialArea: initialArea,
              onCropped: (Uint8List bytes) async {
                imageCache!.clear();
                final appDir = await getTemporaryDirectory();
                File file = File('${appDir.path}/document.jpg');
                await file.writeAsBytes(bytes);

                print("=================================================");
                print(newArea);
                print("=================================================");

                widget.nextStep(file, newArea, dialogContext);
              },
            ),
            BottomNavigation(
              onBack: () {
                widget.backStep();
              },
              onNext: _cropDocument,
            ),

            // Image.file(
            //   widget.picture,
            //   fit: BoxFit.contain,
            // ),
            if (widget.children != null) ...widget.children!
          ],
        ),
      ),
    );
  }

  void _cropDocument() async {
    loadingModal(context: context);
    _cropController.crop();
  }

  void loadingModal({
    required BuildContext context,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        dialogContext = context;
        if (widget.loadingWidgetWhenCropPicture != null) {
          return widget.loadingWidgetWhenCropPicture!;
        }

        return AlertDialog(
          title: Text(
            "Cropping picture",
          ),
        );
      },
    );
  }
}