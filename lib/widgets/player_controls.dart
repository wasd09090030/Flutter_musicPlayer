import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

// 完整播放控制
class PlayerControls extends StatelessWidget {
  const PlayerControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 上一首
        IconButton(
          icon: const Icon(Icons.skip_previous, size: 40),
          onPressed: () => audioProvider.playPrevious(),
        ),
        const SizedBox(width: 16),
        
        // 播放/暂停
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: IconButton(
            icon: Icon(
              audioProvider.playerState == PlayerState.playing
                  ? Icons.pause
                  : Icons.play_arrow,
              size: 40,
              color: Colors.white,
            ),
            onPressed: () => audioProvider.togglePlay(),
          ),
        ),
        const SizedBox(width: 16),
        
        // 下一首
        IconButton(
          icon: const Icon(Icons.skip_next, size: 40),
          onPressed: () => audioProvider.playNext(),
        ),
      ],
    );
  }
}

// 迷你播放控制（用于主屏幕底部）
class MiniPlayerControls extends StatelessWidget {
  const MiniPlayerControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white),
          onPressed: () => audioProvider.playPrevious(),
        ),
        IconButton(
          icon: Icon(
            audioProvider.playerState == PlayerState.playing
                ? Icons.pause
                : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: () => audioProvider.togglePlay(),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white),
          onPressed: () => audioProvider.playNext(),
        ),
      ],
    );
  }
}
