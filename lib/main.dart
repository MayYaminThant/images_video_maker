import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:images_picker/images_picker.dart';
import 'package:images_video_maker/controller/transaction_effect_controller.dart';
import 'package:images_video_maker/util/ffmpeg_kit_utils.dart';
import 'package:images_video_maker/widget/video_player_item.dart';
import 'package:provider/provider.dart';

import 'controller/video_state_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoStateController()),
        ChangeNotifierProvider(create: (_) => TransactionEffectController()),
      ],
      child: const MaterialApp(
          debugShowCheckedModeBanner: false, home: HomeScreen()),
    );
  }
}

List<String> list = [
  'swipe',
  'multiple different',
  'shortest slideshow',
  'fade in-out',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Media> images = [];
  String? videoUrl;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBar(),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: videoUrl != null && videoUrl!.isNotEmpty
                  ? VideoPlayerItem(videoUrl: videoUrl)
                  : Container(
                      color: Colors.red,
                    ),
            ),
            _transactionEffectsUI(),
          ],
        ),
      ),
    );
  }

  SizedBox _transactionEffectsUI() {
    return SizedBox(
      // width: 500,
      height: 100,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: list.length,
          itemBuilder: (context, index) {
            return Consumer<TransactionEffectController>(
              builder: (_, transactionEffectController, __) => Container(
                margin: const EdgeInsets.all(5),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: index == transactionEffectController.selectIndex
                      ? Border.all(color: Colors.white)
                      : null,
                ),
                child: Center(
                  child: Text(
                    list[index],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  AppBar _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        TextButton(
          onPressed: () async {
            images = await ImagesPicker.pick(count: 4) ?? [];
            UtilsFFmpegKit.makeVideoWithSwipe(
                images: images,
                onSuccess: (outputPath) {
                  videoUrl = outputPath;
                  setState(() {});
                });
            log('success');
          },
          child: const Text(
            'Pick',
            style: TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }
}
