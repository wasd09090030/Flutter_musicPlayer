import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/audio_provider.dart';
import '../services/file_service.dart';
import '../widgets/song_list_tile.dart';
import '../widgets/player_controls.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    // 使用addPostFrameCallback确保在Widget完全构建后再扫描音乐文件
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanAudioFiles();
    });
  }

  // 扫描音频文件
  Future<void> _scanAudioFiles() async {
    final songListProvider = Provider.of<SongList>(context, listen: false);
    
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = '';
      });
    }

    try {
      // 直接调用文件扫描，但使用延迟以避免阻塞UI
      await Future.delayed(const Duration(milliseconds: 100));
      final songs = await FileService.scanAudioFiles();
      
      if (!mounted) return; // 检查widget是否仍然挂载
      
      if (songs.isEmpty) {
        setState(() {
          _error = '未找到音频文件，请检查存储权限或将音频文件放入Music、Download等目录';
        });
      } else {
        songListProvider.setSongs(songs);
        setState(() {
          _error = '';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '扫描音频文件时出错: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final songList = Provider.of<SongList>(context);
    final audioProvider = Provider.of<AudioProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的音乐'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _scanAudioFiles,
            tooltip: '刷新音乐库',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _scanAudioFiles,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : songList.songs.isEmpty
                  ? const Center(child: Text('没有找到音乐文件'))
                  : ListView.builder(
                      itemCount: songList.songs.length,
                      itemBuilder: (context, index) {
                        final song = songList.songs[index];
                        return SongListTile(
                          song: song,
                          isPlaying: audioProvider.currentSong?.id == song.id &&
                              audioProvider.playerState == PlayerState.playing,
                          onTap: () {
                            audioProvider.setPlaylist(
                              songList.songs,
                              initialIndex: index,
                            );
                            
                            // 打开播放器屏幕
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PlayerScreen(),
                              ),
                            );
                          },
                        );
                      },
                    ),
      bottomNavigationBar: audioProvider.currentSong != null
          ? Container(
              color: Theme.of(context).cardColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.music_note),
                    ),
                    title: Text(
                      audioProvider.currentSong?.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      audioProvider.currentSong?.artist ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const MiniPlayerControls(),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PlayerScreen(),
                        ),
                      );
                    },
                  ),
                  const LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
