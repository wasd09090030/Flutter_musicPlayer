import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';
import 'metadata_service.dart';

class FileService {
  // 音频文件扩展名
  static const List<String> _supportedExtensions = [
    'mp3', 'wav', 'flac', 'aac', 'm4a', 'ogg'
  ];
  
  // 检查权限
  static Future<bool> _checkPermission() async {
    // Android 13+ (API 33+) 使用 READ_MEDIA_AUDIO 权限
    if (Platform.isAndroid) {
      try {
        final sdkVersion = await _getAndroidSdkVersion();
        if (sdkVersion >= 33) {
          final status = await Permission.audio.status;
          if (status.isDenied) {
            final result = await Permission.audio.request();
            return result.isGranted;
          }
          return status.isGranted;
        } else {
          final status = await Permission.storage.status;
          if (status.isDenied) {
            final result = await Permission.storage.request();
            return result.isGranted;
          }
          return status.isGranted;
        }
      } catch (e) {
        debugPrint('请求权限时出错: $e');
        // 如果出现错误，返回false，在调用函数中处理
        return false;
      }
    }
    
    // iOS 默认使用应用程序沙盒，不需要特殊权限
    return true;
  }
  
  // 获取Android SDK版本
  static Future<int> _getAndroidSdkVersion() async {
    if (!Platform.isAndroid) return 0;
    
    try {
      // 对于Android 13+，我们直接假设需要新的权限
      // 因为获取确切的API级别比较复杂，我们采用保守的方法
      return 33; // 假设是Android 13+ (API 33+)
    } catch (e) {
      debugPrint('无法获取Android SDK版本: $e');
      return 33; // 默认使用新权限
    }
  }
  
  // 扫描单个目录（非递归，避免权限问题）
  static Future<void> _scanDirectory(Directory dir, List<String> filePaths) async {
    try {
      final entities = await dir.list(recursive: false, followLinks: false).toList();
      
      for (final entity in entities) {
        if (entity is File) {
          final path = entity.path.toLowerCase();
          if (_supportedExtensions.any((ext) => path.endsWith('.$ext'))) {
            filePaths.add(entity.path);
          }
        } else if (entity is Directory) {
          // 递归扫描子目录，但要处理权限异常
          try {
            await _scanDirectory(entity, filePaths);
          } catch (e) {
            debugPrint('跳过无法访问的子目录: ${entity.path}');
            // 继续扫描其他目录
          }
        }
      }
    } catch (e) {
      debugPrint('扫描目录 ${dir.path} 时出错: $e');
      // 不抛出异常，继续扫描其他目录
    }
  }
  
  // 扫描设备上的音频文件
  static Future<List<Song>> scanAudioFiles() async {
    // 检查权限
    bool hasPermission = false;
    try {
      hasPermission = await _checkPermission();
      if (!hasPermission) {
        debugPrint('无法获取存储权限，尝试使用有限的访问权限继续');
        // 即使没有权限，我们也尝试扫描应用可访问的目录
      }
    } catch (e) {
      debugPrint('检查权限时出错: $e');
      // 继续尝试扫描应用可访问的目录
    }
    
    try {
      List<Directory> directories = [];
      
      if (Platform.isAndroid) {
        // Android: 优先扫描应用可访问的目录
        Directory? externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // 首先添加应用专用的外部存储目录（总是可访问的）
          directories.add(externalDir);
        }
        
        // 尝试添加公共音乐目录，但要安全地检查访问权限
        final publicDirectories = [
          Directory('/storage/emulated/0/Music'),
          Directory('/storage/emulated/0/Download'),
          Directory('/storage/emulated/0/DCIM'),
          Directory('/storage/emulated/0/Audio'),
        ];
        
        for (final dir in publicDirectories) {
          try {
            if (await dir.exists()) {
              // 尝试列出目录以检查是否有权限
              await dir.list().take(1).toList();
              directories.add(dir);
            }
          } catch (e) {
            debugPrint('无法访问目录 ${dir.path}: $e');
            // 继续检查其他目录
          }
        }
      } else if (Platform.isIOS) {
        // iOS: 扫描文档目录
        final documentsDir = await getApplicationDocumentsDirectory();
        directories.add(documentsDir);
      }
      
      // 扫描所有目录，收集文件路径
      List<String> filePaths = [];
      for (var dir in directories) {
        await _scanDirectory(dir, filePaths);
      }
      
      // 使用元数据服务批量处理音频文件
      if (filePaths.isNotEmpty) {
        final songs = await MetadataService.readMultipleAudioMetadata(filePaths);
        return songs;
      }
      
      return [];
    } catch (e) {
      debugPrint('扫描音频文件时出错: $e');
      return [];
    }
  }
}
