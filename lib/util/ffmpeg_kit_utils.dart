import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/log.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/log_callback.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/statistics_callback.dart';
import 'package:images_picker/images_picker.dart';

const _tag = 'UtilsFFmpegKit';

class UtilsFFmpegKit {
  /// [startDuration], [endDuration] sample format is "00:00:00"
  ///
  static String getImagesLoop(
    List<Media> images, {
    String betweenSecond = '1 -t 3',
  }) {
    String string = '';
    for (var i = 0; i < images.length; i++) {
      string += "-loop $betweenSecond -i \"${images[i].path}\" ";
    }
    return string;
  }

  static String getOutputFilePath({required final Media file}) {
    List<String> inputPathList = file.path.split('/');
    inputPathList.removeAt(inputPathList.length - 1);

    return "${inputPathList.join('/')}/MAKE_VIDEO_OUTPUT_${DateTime.now().microsecondsSinceEpoch}.mp4";
  }

  static Future<void> makeVideoWithSwipe({
    required final List<Media> images,
    required Function(String outputPath) onSuccess,
    final Function()? onCancelled,
    final Function()? onError,
    final LogCallback? logCallback,
    final StatisticsCallback? statisticsCallback,
  }) async {
    final String outputFilePath = getOutputFilePath(file: images[0]);
    final String methodName = 'makeVideoWithSwipe';

    final command = "${getImagesLoop(images)}-filter_complex " +
        "\"[0][1]xfade=transition=circlecrop:duration=0.5:offset=2.5[f0]; " +
        "[f0][2]xfade=transition=smoothleft:duration=0.5:offset=5[f1]; " +
        "[f1][3]xfade=transition=pixelize:duration=0.5:offset=7.5[f2]; " +
        "[f2][4]xfade=transition=hblur:duration=0.5:offset=10[f3]\" " +
        "-map \"[f3]\" -r 25 -pix_fmt yuv420p -vcodec libx264 $outputFilePath";

    log(
      '$_tag: $methodName():'
      '\noutputFilePath: $outputFilePath'
      '\ncommand: $command',
    );

    FFmpegKit.executeAsync(
      command,
      (FFmpegSession session) async {
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          log('$_tag: $methodName(): status: SUCCESS');

          onSuccess(outputFilePath);
        } else if (ReturnCode.isCancel(returnCode)) {
          log('$_tag: $methodName(): status: CANCELLED');

          onCancelled?.call();
        } else {
          log('$_tag: $methodName(): status: ERROR');

          onError?.call();
        }
      },
      (Log logmsg) {
        log('$_tag: $methodName(): logmsg: ${logmsg.getMessage()}');

        logCallback?.call(logmsg);
      },
      statisticsCallback,
    );
  }
}
