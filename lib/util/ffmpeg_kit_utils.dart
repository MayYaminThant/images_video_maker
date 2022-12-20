import 'dart:developer';

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

  static String getImagesLoop2(List<Media> images) {
    String string = '';
    for (var i = 0; i < images.length; i++) {
      string += "-i \"${images[i].path}\" ";
    }
    return string;
  }

  static String getImagesFile(List<Media> images) {
    String string = '';
    for (var i = 0; i < images.length; i++) {
      string += "-i \"${images[i].path}\" ";
    }
    return string;
  }

  static String getImagesFile2(List<Media> images) {
    String string = '-i "concat:';
    String imags = "";
    for (var i = 0; i < images.length; i++) {
      if (imags.isNotEmpty) {
        imags += "|";
      }
      imags += "\"${images[i].path}\"";
    }
    string += "$imags\"";
    return string;
  }

  static String getImagesFile3(List<Media> images) {
    String string = '<(cat <<EOF';
    for (var i = 0; i < images.length; i++) {
      string += "file \"${images[i].path}\" duration 0.5 ";
    }
    return "${string}EOF)";
  }

  static String getImagesFile4(List<Media> images) {
    String string = '';
    for (var i = 0; i < images.length; i++) {
      string +=
          "-f image2 -loop 1 -thread_queue_size 4096 -framerate 30 -t 0.5 -i \"${images[i].path}\" ";
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

    // final command = "${getImagesLoop(images)}-filter_complex " +
    //     "\"[0][1]xfade=transition=circlecrop:duration=0.5:offset=2.5[f0]; " +
    //     "[f0][2]xfade=transition=smoothleft:duration=0.5:offset=5[f1]; " +
    //     "[f1][3]xfade=transition=pixelize:duration=0.5:offset=7.5[f2]; " +
    //     "[f2][4]xfade=transition=hblur:duration=0.5:offset=10[f3]\" " +
    //     "-map \"[f3]\" -r 25 -pix_fmt yuv420p -vcodec libx264 $outputFilePath";

    // final command = "${getImagesLoop(images)}" +
    //     "\"[0][1]xfade=transition=circlecrop:duration=0.5:offset=2.5[f0]; " +
    //     "[f0][2]xfade=transition=smoothleft:duration=0.5:offset=5[f1]; " +
    //     "[f1][3]xfade=transition=pixelize:duration=0.5:offset=7.5[f2]; " +
    //     "[f2][4]xfade=transition=hblur:duration=0.5:offset=10[f3]\" " +
    //     "-map \"[f3]\" -r 25 -pix_fmt -vcodec $outputFilePath";

    final command =
        // "-framerate 2 ${getImagesLoop(images)}-c:v libx264 -t 15 -pix_fmt yuv420p -vf scale=320:240 $outputFilePath";
        // "-framerate 20 -i ${images[0].path} $outputFilePath";
        // "-i ${images[0].path} -c:v libx264 -r 30 $outputFilePath";
        // "-loop 1 -i ${images[0].path} -c:v libx264 -t 15 -pix_fmt yuv420p $outputFilePath";
        // "${getImagesLoop(images)}-vf \"zoompan=z='if(lte(zoom,1.0),1.5,max(1.001,zoom-0.0015))':d=125\" -c:v libx264 -t 30 -s \"800x450\" $outputFilePath";
        "-framerate 1/4 -start_number 1 ${getImagesFile4(images)}-filter_complex 'concat=n=${images.length}:v=1 [vmerged]' -map '[vmerged]'-vf \"zoompan=z='if(lte(zoom,1.0),1.5,max(1.001,zoom-0.0015))':d=125\" -c:v libx264 -t 30 -s \"800x450\" $outputFilePath";

    // final command =
    //     "${getImagesLoop(images)}-filter_complex '[0:v]trim=duration=3,fade=t=out:st=2.5:d=0.5[v0];[1:v]trim=duration=3,fade=t=in:st=0:d=0.5,fade=t=out:st=2.5:d=0.5[v1];[2:v]trim=duration=3,fade=t=in:st=0:d=0.5,fade=t=out:st=2.5:d=0.5[v2];[3:v]trim=duration=3,fade=t=in:st=0:d=0.5,fade=t=out:st=2.5:d=0.5[v3];[v0][v1][v2][v3]concat=n=4:v=1:a=0,format=yuv420p[v]' -map [v] -preset ultrafast $outputFilePath";

    // final command = "-framerate 5 ${getImagesLoop2(images)}$outputFilePath";

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
