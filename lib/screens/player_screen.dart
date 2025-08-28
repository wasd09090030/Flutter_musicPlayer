import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/player_controls.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final currentSong = audioProvider.currentSong;
    
    if (currentSong == null) {
      return const Scaffold(
        body: Center(
          child: Text('没有正在播放的歌曲'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('正在播放'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 封面
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: currentSong.albumArt != null
                          ? Image.memory(
                              currentSong.albumArt!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAlbumArt();
                              },
                            )
                          : _buildDefaultAlbumArt(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // 歌曲信息
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          currentSong.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${currentSong.artist} • ${currentSong.album}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 进度条
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: StreamBuilder<Duration>(
              stream: audioProvider.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = audioProvider.duration;
                
                // 确保position不超过duration，避免Slider范围错误
                final safePosition = position.inMilliseconds > duration.inMilliseconds 
                    ? duration.inMilliseconds 
                    : position.inMilliseconds;
                
                // 确保duration不为0，避免除零错误
                final safeDuration = duration.inMilliseconds > 0 
                    ? duration.inMilliseconds 
                    : 1;
                
                return Column(
                  children: [
                    Slider(
                      value: safePosition.toDouble(),
                      min: 0,
                      max: safeDuration.toDouble(),
                      onChanged: duration.inMilliseconds > 0 ? (value) {
                        audioProvider.seekTo(
                          Duration(milliseconds: value.toInt()),
                        );
                      } : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(position)),
                          Text(_formatDuration(duration)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // 控制按钮
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: PlayerControls(),
          ),
        ],
      ),
    );
  }
  
  // 构建默认专辑封面
  Widget _buildDefaultAlbumArt() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.music_note,
          size: 100,
          color: Colors.white,
        ),
      ),
    );
  }
  
  // 格式化时间
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
