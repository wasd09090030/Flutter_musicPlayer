import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/song.dart';

enum PlayerState {
  loading, // 加载中
  playing, // 播放中
  paused, // 暂停
  stopped, // 停止
  completed, // 播放完成
  error, // 错误
}

class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // 当前播放列表
  List<Song> _playlist = [];
  // 当前播放歌曲索引
  int _currentIndex = -1;
  
  // 播放状态
  PlayerState _playerState = PlayerState.stopped;
  
  // 当前播放位置
  Duration _position = Duration.zero;
  
  // 构造函数，初始化音频会话
  AudioProvider() {
    _initAudioSession();
    _setupListeners();
  }
  
  // 获取属性
  AudioPlayer get audioPlayer => _audioPlayer;
  List<Song> get playlist => [..._playlist];
  Song? get currentSong => _currentIndex >= 0 && _currentIndex < _playlist.length 
      ? _playlist[_currentIndex] 
      : null;
  int get currentIndex => _currentIndex;
  PlayerState get playerState => _playerState;
  Duration get position => _position;
  Duration get duration => _audioPlayer.duration ?? Duration.zero;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  
  // 初始化音频会话
  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      debugPrint('初始化音频会话时出错: $e');
    }
  }
  
  // 设置监听器
  void _setupListeners() {
    // 播放状态监听
    _audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        _playerState = PlayerState.playing;
      } else {
        if (state.processingState == ProcessingState.completed) {
          _playerState = PlayerState.completed;
          // 重置播放位置到结尾
          _position = _audioPlayer.duration ?? Duration.zero;
          notifyListeners();
          // 播放下一首歌
          _playNext();
        } else if (state.processingState == ProcessingState.idle) {
          _playerState = PlayerState.stopped;
        } else if (state.processingState == ProcessingState.loading) {
          _playerState = PlayerState.loading;
        } else {
          _playerState = PlayerState.paused;
        }
      }
      notifyListeners();
    });
    
    // 播放位置监听
    _audioPlayer.positionStream.listen((position) {
      // 确保位置不超过总时长
      final duration = _audioPlayer.duration ?? Duration.zero;
      if (duration.inMilliseconds > 0 && position.inMilliseconds > duration.inMilliseconds) {
        _position = duration;
      } else {
        _position = position;
      }
      notifyListeners();
    });
    
    // 错误监听
    _audioPlayer.playbackEventStream.listen((event) {}, 
      onError: (Object e, StackTrace st) {
        debugPrint('音频播放错误: $e');
        _playerState = PlayerState.error;
        notifyListeners();
      }
    );
  }
  
  // 设置播放列表
  Future<void> setPlaylist(List<Song> songs, {int initialIndex = 0}) async {
    if (songs.isEmpty) return;
    
    _playlist = songs;
    notifyListeners();
    
    if (initialIndex >= 0 && initialIndex < songs.length) {
      await playAtIndex(initialIndex);
    }
  }
  
  // 在特定索引处播放
  Future<void> playAtIndex(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    
    _currentIndex = index;
    _playerState = PlayerState.loading;
    notifyListeners();
    
    try {
      await _audioPlayer.setFilePath(_playlist[index].filePath);
      play();
    } catch (e) {
      debugPrint('设置音频源时出错: $e');
      _playerState = PlayerState.error;
      notifyListeners();
    }
  }
  
  // 播放
  Future<void> play() async {
    if (_currentIndex < 0 || _currentIndex >= _playlist.length) return;
    
    try {
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('播放音频时出错: $e');
    }
  }
  
  // 暂停
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('暂停音频时出错: $e');
    }
  }
  
  // 切换播放/暂停
  Future<void> togglePlay() async {
    if (_playerState == PlayerState.playing) {
      await pause();
    } else {
      await play();
    }
  }
  
  // 播放下一首
  Future<void> _playNext() async {
    if (_playlist.isEmpty) return;
    
    int nextIndex = _currentIndex + 1;
    if (nextIndex >= _playlist.length) {
      nextIndex = 0; // 循环播放
    }
    
    await playAtIndex(nextIndex);
  }
  
  // 手动触发播放下一首
  Future<void> playNext() async {
    await _playNext();
  }
  
  // 播放上一首
  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;
    
    int prevIndex = _currentIndex - 1;
    if (prevIndex < 0) {
      prevIndex = _playlist.length - 1; // 循环播放
    }
    
    await playAtIndex(prevIndex);
  }
  
  // 跳转到特定位置
  Future<void> seekTo(Duration position) async {
    try {
      final duration = _audioPlayer.duration ?? Duration.zero;
      // 确保跳转位置不超过总时长
      final safePosition = position.inMilliseconds > duration.inMilliseconds 
          ? duration 
          : position;
      await _audioPlayer.seek(safePosition);
    } catch (e) {
      debugPrint('跳转到特定位置时出错: $e');
    }
  }
  
  // 释放资源
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

