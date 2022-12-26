import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [],
          ),
          ButtonWidget(
            title: 'FORMAT TEXT',
            onTap: () async {
              // bool runInShell = Platform.isWindows;
              final clipboardData =
                  await Clipboard.getData(Clipboard.kTextPlain);
              final text = clipboardData?.text;

              final indentedText2 =
                  text?.split('\n').asMap().entries.map((entry) {
                final index = entry.key;
                final line = entry.value;
                if (index % 2 == 0) {
                  return '   \n\n$line';
                }
                return line;
              }).join('');

              final useful = ClipboardData(text: indentedText2);

              // Copy the indented text to the clipboard
              await Clipboard.setData(useful).then((value) =>
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Text Formatted'))));
            },
          ),
          ButtonWidget(
            title: 'FORMAT IMAGE',
            onTap: () async {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => DragDropPage()));
            },
          ),
        ],
      ),
    ));
  }
}

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    Key? key,
    this.onTap,
    required this.title,
  }) : super(key: key);

  final VoidCallback? onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(24),
        height: 50,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class DragDropPage extends StatefulWidget {
  DragDropPage({Key? key}) : super(key: key);

  @override
  State<DragDropPage> createState() => _DragDropPageState();
}

class _DragDropPageState extends State<DragDropPage> {
  bool _dragging = false;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> image = ValueNotifier(null);
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: DropTarget(
        onDragDone: (detail) async {
          setState(() {
            image.value = detail.files.first.path;

            // _list.addAll(detail.files);
          });

          isLoading.value = true;

          final screenShot = await screenshotController.captureFromWidget(
            ImageExportWidget(
              image: image,
              width: 640,
              height: 360,
            ),
            pixelRatio: 3,
          );

          await saveFile(screenShot, 'png')
              .then((value) => isLoading.value = false);
        },
        onDragEntered: (detail) {
          setState(() {
            _dragging = true;
          });
        },
        onDragExited: (detail) {
          setState(() {
            _dragging = false;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(),
            image.value != null
                ? SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Drag and Drop Image Here',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        'OR',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      ValueListenableBuilder(
                          valueListenable: isLoading,
                          builder: (context, value, child) {
                            if (value) {
                              return Center(child: CircularProgressIndicator());
                            } else {
                              return ButtonWidget(
                                title: 'Select Image',
                                onTap: () async {
                                  try {
                                    image.value =
                                        await getImage.then((value) async {
                                      isLoading.value = true;
                                      final screenShot =
                                          await screenshotController
                                              .captureFromWidget(
                                        ImageExportWidget(
                                          image: image,
                                          width: 640,
                                          height: 360,
                                        ),
                                        pixelRatio: 3,
                                      );

                                      await saveFile(screenShot, 'png').then(
                                          (value) => isLoading.value = false);
                                    });
                                    isLoading.value = false;
                                  } catch (e) {
                                  } finally {
                                    isLoading.value = false;
                                  }
                                },
                              );
                            }
                          }),
                    ],
                  ),
            image.value == null
                ? SizedBox()
                : Stack(
                    children: [
                      ImageExportWidget(
                        image: image,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height - 100,
                      ),
                      ValueListenableBuilder(
                          valueListenable: isLoading,
                          builder: (context, value, child) {
                            if (value) {
                              return Positioned.fill(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Saving...',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Center(
                                      child: CircularProgressIndicator(
                                    color: Colors.black,
                                  )),
                                ],
                              ));
                            }
                            return SizedBox();
                          })
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class ImagePage extends StatefulWidget {
  ImagePage({Key? key}) : super(key: key);

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  final ValueNotifier<String?> image = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading.value = true;
    onOpen();
  }

  onOpen() async {
    image.value = await getImage;

    final screenShot = await screenshotController.captureFromWidget(
      ImageExportWidget(
        image: image,
        width: 640,
        height: 360,
      ),
      pixelRatio: 3,
    );

    await saveFile(screenShot, 'png').then((value) => isLoading.value = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ValueListenableBuilder(
              valueListenable: isLoading,
              builder: (context, value, child) {
                if (value == true) {
                  return Center(child: CircularProgressIndicator());
                }
                return ImageExportWidget(
                  image: image,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height - 100,
                );
              }),
        ],
      ),
    );
  }
}

class ImageExportWidget extends StatelessWidget {
  const ImageExportWidget({
    Key? key,
    required this.image,
    this.width = 1600,
    this.height = 900,
  }) : super(key: key);
  final double width;
  final double height;

  final ValueNotifier<String?> image;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: image,
        builder: (context, value, child) {
          return Stack(
            children: [
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  image: value != null
                      ? DecorationImage(
                          image: FileImage(
                            File(value!),
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    decoration:
                        BoxDecoration(color: Colors.white.withOpacity(0.0)),
                  ),
                ),
              ),
              Container(
                child: value != null
                    ? Image.file(
                        File(value!),
                        height: height,
                        width: width,
                        // color: Colors.red,
                      )
                    : const Text('Get Image'),
              ),
            ],
          );
        });
  }
}

Future<String> get getImage async {
  final completer = Completer<String>();
  if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
    final file = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (file != null) {
      final filePath = file.files.single.path;
      log(filePath.toString());

      final bytes = filePath == null
          ? file.files.first.bytes
          : File(filePath).readAsBytesSync();
      completer.complete(filePath);
      //
      // if (bytes != null) {
      //   completer.complete(filePath);
      // } else {
      //   completer.completeError('No image selected');
      // }
    }
  } else {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      completer.complete(
        image.path,
      );
    } else {
      completer.completeError('No image selected');
    }
  }

  return completer.future;
}

Future<void> saveFile(Uint8List bytes, String extension) async {
  // if (kIsWeb) {
  //   html.AnchorElement()
  //     ..href = '${Uri.dataFromBytes(bytes, mimeType: 'image/$extension')}'
  //     ..download =
  //         'FlutterLetsDraw-${DateTime.now().toIso8601String()}.$extension'
  //     ..style.display = 'none'
  //     ..click();
  // } else {
  await FileSaver.instance.saveFile(
    'easyOptions-${DateTime.now().toIso8601String()}.$extension',
    bytes,
    extension,
    mimeType: extension == 'png' ? MimeType.PNG : MimeType.JPEG,
  );
  // }
}
