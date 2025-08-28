# MyPlayer - Flutter本地音乐播放器

一个使用Flutter开发的简单、现代化的本地音乐播放器，专为Android 13+设备设计。

## 功能特性

- 🎵 扫描并播放本地音频文件
- 🎮 基本播放控制（播放/暂停/上一首/下一首）
- 🔄 后台播放支持
- 🎨 现代化的Material Design界面
- 🌓 深色模式支持
- 📱 适配Android 13+权限系统
- 🏗️ 支持x86 CPU架构
- 🎼 音乐元数据解析（标题、艺术家、专辑、时长等）
- 🖼️ 专辑封面显示
- 🎯 智能文件过滤（自动过滤小于3MB的文件）
- 💫 优雅的UI交互（正在播放状态标识、自动消失的提示信息）

## 支持的音频格式

- MP3
- WAV
- FLAC
- AAC
- M4A
- OGG

## 技术架构

### 状态管理
- **Provider** - 用于应用状态管理

### 音频播放
- **just_audio** - 高质量音频播放引擎
- **audio_session** - 后台播放和音频会话管理

### 权限处理
- **permission_handler** - Android权限管理
- 自动适配Android 13+ READ_MEDIA_AUDIO权限

### 项目结构
```
lib/
├── models/          # 数据模型
├── providers/       # 状态管理
├── screens/         # UI界面
├── services/        # 业务逻辑服务
├── widgets/         # 可复用组件
└── main.dart        # 应用入口
```

## 安装与运行

1. 克隆项目
```bash
git clone <repository-url>
cd myplayer
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行应用
```bash
flutter run
```

## 使用说明

1. **首次启动**: 应用会自动请求音频文件访问权限
2. **添加音乐**: 将音频文件放入以下目录：
   - `/storage/emulated/0/Music/`
   - `/storage/emulated/0/Download/`
   - `/storage/emulated/0/DCIM/`
   - `/storage/emulated/0/Audio/`
3. **刷新音乐库**: 点击右上角的刷新按钮重新扫描音频文件
4. **播放音乐**: 点击歌曲开始播放，支持后台播放

## 已修复的问题

### v1.2.0 新功能
- ✅ 添加了音乐元数据解析，显示真实的歌曲标题、艺术家和专辑信息
- ✅ 添加了专辑封面显示功能（歌曲列表和播放器界面）
- ✅ 改进了UI设计，正在播放的歌曲标题显示为蓝色并带有播放图标
- ✅ 添加了文件大小过滤，自动过滤小于3MB的音频文件
- ✅ 优化了底部播放控制栏：深色背景、白色字体、显示专辑封面
- ✅ 扫描信息现在会在3秒后自动消失

### v1.1.0 修复
- ✅ 修复了音乐播放完成后Slider范围错误的问题
- ✅ 改进了播放位置监听，防止位置超出总时长
- ✅ 增强了seekTo方法的安全性检查
- ✅ 优化了播放完成时的状态处理

### v1.0.0 修复
- ✅ 修复了ClassNotFoundException: AudioService的错误
- ✅ 解决了权限请求时Activity未准备好的问题
- ✅ 改进了文件扫描逻辑，避免访问被拒绝的目录
- ✅ 优化了UI线程阻塞问题

## 开发环境要求

- Flutter SDK: 3.0.0+
- Dart SDK: 2.17.0+
- Android SDK: API 21+ (Android 5.0+)
- 推荐Android 13+ (API 33+) 以获得最佳体验

## 未来改进计划

- [ ] 添加播放列表功能
- [ ] 添加搜索和排序功能
- [ ] 添加均衡器支持
- [ ] 添加更多动画效果
- [ ] 添加歌词显示功能
- [ ] 支持在线音乐流媒体
- [ ] 添加收藏功能
- [ ] 支持播放模式切换（单曲循环、随机播放等）

## 许可证

本项目采用MIT许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 贡献

欢迎提交Issues和Pull Requests来帮助改进这个项目！