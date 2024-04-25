import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'image_view.dart';
import 'pdf_view.dart';
import 'video_view.dart';

void main() {
  runApp(const MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<FileSystemEntity> _folders = [];
  bool isDownloading = false;
  String downloadedPer = "";
  TextEditingController urlController = TextEditingController();
  final _globalKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getDir();
  }

  Future<String> createFolderInAppDocDir(String folderName) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory appDocDirFolder = Directory('${appDocDir.path}/$folderName/');

    if (await appDocDirFolder.exists()) {
      return appDocDirFolder.path; // Folder already exists
    } else {
      final Directory appDocDirNewFolder = await appDocDirFolder.create(recursive: true);
      return appDocDirNewFolder.path; // Created a new folder
    }
  }

  Future<void> getDir() async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = directory.path;
    final myDir = Directory('$dir/');

    setState(() {
      _folders = myDir.listSync(recursive: true, followLinks: false);
    });

    // print("Folders: $_folders"); // Display the list of files and folders
  }

  Future<bool> checkAvailability() async {
    Directory directory = await getApplicationDocumentsDirectory();
    // print("Directory: ${directory.path}");
    File file = File("${directory.path}banner.png");
    bool exists = await file.exists();
    // print("exists : $exists");
    return file.exists();
  }

  Future<void> saveImage() async {
    try {
      final PermissionStatus status = await Permission.manageExternalStorage.request();
      // print(status);
      if (status.isGranted) {
        isDownloading = true;
        var dir = await getApplicationDocumentsDirectory();
        // print("Directory: ${dir.path}");
        String saveName = urlController.text.split("/").last;
        String savePath = "${dir.path}/$saveName";
        // print(savePath);
        //output:  /storage/emulated/0/Download/banner.png
        try {
          await Dio().download(urlController.text, savePath, onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() {
                downloadedPer = "${(received / total * 100).toStringAsFixed(0)}%";
                // print(downloadedPer);
              });
              //you can build progressbar feature too
            }
          });
          // print("File is saved to download folder.");
          setState(() {
            downloadedPer = "";
            isDownloading = false;
            urlController = TextEditingController();
          });
        } catch (e) {
          print("Error in downloading file. $e");
        }
      } else {
        print("No permission to read and write.");
      }
    } catch (e) {
      print("ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Download from URL"),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Form(
                key: _globalKey,
                child: TextFormField(
                  controller: urlController,
                  decoration: InputDecoration(
                    hintText: "Enter URL",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          urlController = TextEditingController();
                        });
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter URL";
                    } else if (urlController.text.contains("https://") || urlController.text.contains("http://")) {
                      return null;
                    } else {
                      return "Enter Valid URL";
                    }
                  },
                ),
              ),
              downloadedPer == ""
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (urlController.text.isNotEmpty) {
                            await saveImage();
                            getDir();
                          }
                        },
                        child: const Text("Save File on Secure Folder ."),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        downloadedPer,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _folders.length,
                  itemBuilder: (context, index) {
                    final fileType = lookupMimeType(_folders[index].path);
                    print(fileType);
                    if (!_folders[index].path.split("/").last.contains(".") || _folders[index].path.split("/").last.contains("bin")) {
                      return Container();
                    } else {
                      return ListTile(
                        onTap: () {
                          if (fileType.contains("video")) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => VideoView(path: _folders[index].path)));
                          } else if (fileType.contains("image")) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ImageView(path: _folders[index].path)));
                          } else if (fileType.contains("pdf")) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PdfView(path: _folders[index].path)));
                          }
                        },
                        title: Text(_folders[index].path.split("/").last),
                        subtitle: Text(fileType ?? ""),
                        leading: fileType!.contains("video")
                            ? const Icon(Icons.video_file, color: Colors.blue)
                            : fileType.contains("pdf")
                                ? const Icon(Icons.picture_as_pdf)
                                : fileType.contains("image")
                                    ? Image.file(File(_folders[index].path), height: 32, width: 30)
                                    : const Icon(Icons.folder),
                        trailing: IconButton(
                            onPressed: () {
                              _folders[index].deleteSync(recursive: true);
                              getDir();
                            },
                            icon: const Icon(Icons.delete, color: Colors.red)),
                      );
                    }
                  },
                ),
              ),
              const Text("This app is just a demo."),
              const Text(
                "This App supports only images and videos and pdf files.",
                style: TextStyle(fontSize: 11),
              )
            ],
          ),
        ));
  }
}
