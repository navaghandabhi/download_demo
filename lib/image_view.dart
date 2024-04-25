import 'dart:io';
import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  final String path;
  const ImageView({super.key,required this.path});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: const Text("Image View"),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.file(File(path),width: MediaQuery.of(context).size.width,),
      ),
    );
  }
}
