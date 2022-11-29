import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../controller/video_state_controller.dart';
import '../util/screen_size_utils.dart';
import 'video_control_overlay.dart';

class VideoPlayerItem extends StatefulWidget {
  const VideoPlayerItem({
    super.key,
    required this.videoUrl,
    this.height,
  }) : assert(videoUrl != null);
  final String? videoUrl;
  final double? height;

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController videoController;

  @override
  void initState() {
    super.initState();
    final VideoStateController videoStateController =
        context.read<VideoStateController>();

    videoController = VideoPlayerController.file(File(widget.videoUrl!));

    videoController.addListener(() {
      setState(() {});
    });

    videoController.setLooping(true);
    videoController.initialize().then((_) => setState(() {}));
    videoController.play();

    videoStateController.addListener(() {
      videoController.pause();
    });
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? ScreenSizeUtil.screenHeight(context),
      width: ScreenSizeUtil.screenWidth(context),
      child: AspectRatio(
        aspectRatio: videoController.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            VideoPlayer(videoController),
            ControlsOverlay(controller: videoController),
            VideoProgressIndicator(
              videoController,
              allowScrubbing: true,
              colors: const VideoProgressColors(playedColor: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  destroyVideoController() {
    videoController.dispose();
  }
}
