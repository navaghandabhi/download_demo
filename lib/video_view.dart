import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  final String path;

  const VideoView({super.key, required this.path});

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late VideoPlayerController controller;
  late ChewieController chewieController;

  @override
  initState() {
    super.initState();
    controller = VideoPlayerController.file(File(widget.path));
    videoInit();
  }
  videoInit() {
    // controller.initialize();
    chewieController = ChewieController(
      autoInitialize: false,
      videoPlayerController: controller,
      allowFullScreen: false,
      autoPlay: true,
      looping: false,
      fullScreenByDefault: true,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    chewieController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Player"),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height-62,
        child: Chewie(
          controller: chewieController,
        ),
      ),
    );
  }
}
