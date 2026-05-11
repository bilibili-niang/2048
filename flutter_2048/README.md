# 2048 Game

一个使用Flutter开发的2048小游戏，支持安卓平台。

## 功能特性

- 🎮 经典2048数字合并玩法
- 🎯 支持多种网格大小（3×3 ~ 10×10）
- 🌓 深色/浅色主题切换
- 📊 分数和最高分记录
- 📱 触摸滑动控制
- 📳 震动反馈
- 💾 数据持久化存储

## 技术栈

- Flutter 3.10+
- Provider (状态管理)
- SharedPreferences (数据存储)
- Vibration (震动反馈)

## 运行项目

```bash
# 安装依赖
flutter pub get

# 运行项目
flutter run

# 构建APK
flutter build apk
```

## 项目结构

```
lib/
├── components/      # UI组件
│   ├── game_board.dart
│   ├── tile.dart
│   ├── score_board.dart
│   ├── level_select.dart
│   └── settings_panel.dart
├── models/          # 数据模型
│   └── tile.dart
├── providers/       # 状态管理
│   ├── game_provider.dart
│   └── theme_provider.dart
├── screens/         # 页面
│   └── game_screen.dart
└── main.dart        # 入口文件
```

## 游戏说明

1. 通过滑动屏幕移动方块
2. 相同数字的方块碰撞时会合并成一个
3. 目标是合并出2048方块
4. 当无法移动时游戏结束

## 许可证

MIT License