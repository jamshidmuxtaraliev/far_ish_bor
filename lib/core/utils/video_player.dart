import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FileVideoPlayer extends StatefulWidget {
  final File videoFile;

  const FileVideoPlayer({super.key, required this.videoFile});

  @override
  State<FileVideoPlayer> createState() => _FileVideoPlayerState();
}

class _FileVideoPlayerState extends State<FileVideoPlayer> {
  VideoPlayerController? _controller;
  bool isVideoEnded = false;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.file(widget.videoFile)
          ..initialize().then((_) {
            if (mounted) {
              setState(() {});
              _controller?.play();
            }
          })
          ..addListener(_videoListener);
  }

  void _videoListener() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    final ended = c.value.position >= c.value.duration && !c.value.isPlaying;
    if (ended != isVideoEnded) setState(() => isVideoEnded = ended);
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    final c = _controller;
    if (c == null) return;
    if (isVideoEnded) {
      await c.seekTo(Duration.zero);
      await c.play();
      setState(() => isVideoEnded = false);
      return;
    }
    c.value.isPlaying ? await c.pause() : await c.play();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child:
              c.value.isInitialized
                  ? AspectRatio(
                    aspectRatio: c.value.aspectRatio,
                    child: FittedBox(
                      fit: BoxFit.contain, // ⚙️ keeps natural video ratio
                      child: SizedBox(width: c.value.size.width, height: c.value.size.height, child: VideoPlayer(c)),
                    ),
                  )
                  : const CircularProgressIndicator(color: Colors.white),
        ),
      ),
      floatingActionButton:
          c.value.isInitialized
              ? FloatingActionButton(
                backgroundColor: Colors.black54,
                onPressed: _togglePlayPause,
                child: Icon(isVideoEnded ? Icons.replay : (c.value.isPlaying ? Icons.pause : Icons.play_arrow)),
              )
              : null,
    );
  }
}
