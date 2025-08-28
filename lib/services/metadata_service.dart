import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import '../models/song.dart';

class MetadataService {
  /// 从音频文件读取元数据
  static Future<SongMetadata> readAudioMetadata(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        throw Exception('文件不存在: $filePath');
      }
      
      // 读取元数据，包括专辑封面
      final metadata = readMetadata(file, getImage: true);
      
      // 从文件路径提取默认标题（去掉扩展名）
      final fileName = file.path.split('/').last;
      final defaultTitle = fileName.split('.').first;
      
      return SongMetadata(
        title: metadata.title?.trim().isNotEmpty == true 
            ? metadata.title! 
            : defaultTitle,
        artist: metadata.artist?.trim().isNotEmpty == true 
            ? metadata.artist! 
            : '未知艺术家',
        album: metadata.album?.trim().isNotEmpty == true 
            ? metadata.album! 
            : '未知专辑',
        albumArt: metadata.pictures.isNotEmpty == true 
            ? metadata.pictures.first.bytes 
            : null,
        duration: metadata.duration,
        trackNumber: metadata.trackNumber,
        year: metadata.year?.year,
        genre: metadata.genres.isNotEmpty == true 
            ? metadata.genres.first 
            : null,
      );
      
    } catch (e) {
      debugPrint('读取元数据时出错 ($filePath): $e');
      
      // 如果读取元数据失败，返回基于文件名的默认信息
      final fileName = filePath.split('/').last;
      final defaultTitle = fileName.split('.').first;
      
      return SongMetadata(
        title: defaultTitle,
        artist: '未知艺术家',
        album: '未知专辑',
        albumArt: null,
        duration: null,
        trackNumber: null,
        year: null,
        genre: null,
      );
    }
  }
  
  /// 批量读取多个音频文件的元数据
  static Future<List<Song>> readMultipleAudioMetadata(List<String> filePaths) async {
    final List<Song> songs = [];
    
    for (int i = 0; i < filePaths.length; i++) {
      try {
        final metadata = await readAudioMetadata(filePaths[i]);
        final song = Song.fromMetadata(
          id: i.toString(),
          filePath: filePaths[i],
          metadata: metadata,
        );
        songs.add(song);
      } catch (e) {
        debugPrint('处理文件时出错 (${filePaths[i]}): $e');
        // 即使某个文件出错，也创建一个基本的Song对象
        final song = Song.fromFilePath(filePaths[i], i.toString());
        songs.add(song);
      }
    }
    
    return songs;
  }
  
  /// 更新音频文件的元数据
  static Future<bool> updateAudioMetadata(
    String filePath,
    SongMetadata newMetadata,
  ) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        throw Exception('文件不存在: $filePath');
      }
      
      updateMetadata(file, (metadata) {
        metadata.setTitle(newMetadata.title);
        metadata.setArtist(newMetadata.artist);
        metadata.setAlbum(newMetadata.album);
        
        if (newMetadata.trackNumber != null) {
          metadata.setTrackNumber(newMetadata.trackNumber!);
        }
        
        if (newMetadata.year != null) {
          metadata.setYear(DateTime(newMetadata.year!));
        }
        
        if (newMetadata.genre != null) {
          metadata.setGenres([newMetadata.genre!]);
        }
        
        if (newMetadata.albumArt != null) {
          metadata.setPictures([
            Picture(
              newMetadata.albumArt!,
              "image/jpeg",
              PictureType.coverFront,
            )
          ]);
        }
      });
      
      return true;
    } catch (e) {
      debugPrint('更新元数据时出错 ($filePath): $e');
      return false;
    }
  }
  
  /// 检查文件是否支持元数据读取
  static bool isSupportedFormat(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['mp3', 'mp4', 'm4a', 'flac', 'ogg', 'wav'].contains(extension);
  }
}

/// 音乐元数据模型
class SongMetadata {
  final String title;
  final String artist;
  final String album;
  final Uint8List? albumArt;
  final Duration? duration;
  final int? trackNumber;
  final int? year;
  final String? genre;
  
  SongMetadata({
    required this.title,
    required this.artist,
    required this.album,
    this.albumArt,
    this.duration,
    this.trackNumber,
    this.year,
    this.genre,
  });
  
  @override
  String toString() {
    return 'SongMetadata(title: $title, artist: $artist, album: $album)';
  }
}
