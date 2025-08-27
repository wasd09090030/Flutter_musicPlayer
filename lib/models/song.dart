import 'package:flutter/foundation.dart';

class Song {
  final String id;           // 唯一标识符
  final String title;        // 歌曲标题
  final String artist;       // 艺术家
  final String album;        // 专辑
  final String filePath;     // 文件路径
  final Duration? duration;  // 时长
  final String? albumArt;    // 专辑封面路径 (可能为空)

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.filePath,
    this.duration,
    this.albumArt,
  });

  @override
  String toString() {
    return '$title by $artist';
  }

  // 从文件路径创建简单的Song对象
  factory Song.fromFilePath(String path, String id) {
    // 从文件路径提取文件名作为标题
    final fileName = path.split('/').last;
    final title = fileName.split('.').first;
    
    return Song(
      id: id,
      title: title,
      artist: '未知艺术家',
      album: '未知专辑',
      filePath: path,
    );
  }
}

class SongList with ChangeNotifier {
  List<Song> _songs = [];
  
  List<Song> get songs => [..._songs];
  
  void setSongs(List<Song> songs) {
    _songs = songs;
    notifyListeners();
  }
  
  void addSong(Song song) {
    _songs.add(song);
    notifyListeners();
  }
  
  void clear() {
    _songs.clear();
    notifyListeners();
  }
}
