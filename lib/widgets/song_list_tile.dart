import 'package:flutter/material.dart';
import '../models/song.dart';

class SongListTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;

  const SongListTile({
    Key? key,
    required this.song,
    required this.isPlaying,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildLeadingWidget(context),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
          color: isPlaying ? Theme.of(context).primaryColor : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          if (song.album != '未知专辑')
            Text(
              song.album,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
        ],
      ),
      trailing: song.duration != null
          ? Text(
              _formatDuration(song.duration!),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  // 构建前导组件（专辑封面或图标）
  Widget _buildLeadingWidget(BuildContext context) {
    if (song.albumArt != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          song.albumArt!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultIcon(context);
          },
        ),
      );
    } else {
      return _buildDefaultIcon(context);
    }
  }

  // 构建默认图标
  Widget _buildDefaultIcon(BuildContext context) {
    return CircleAvatar(
      backgroundColor: isPlaying ? Theme.of(context).primaryColor : Colors.grey[300],
      child: Icon(
        isPlaying ? Icons.music_note : Icons.music_note_outlined,
        color: isPlaying ? Colors.white : Colors.grey[700],
      ),
    );
  }

  // 格式化时长
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
