# 2048 Game

一个基于Flutter开发的2048小游戏，支持多种平台，包括Electron桌面端。

## 功能特性

- 🎮 经典2048游戏玩法
- 🎨 支持深色/浅色主题切换
- 📊 多个关卡选择（3x3到10x10）
- 💾 本地数据持久化保存
- 📳 震动反馈支持
- ⌨️ 键盘控制支持（↑↓←→ 或 WASD）
- 📱 触摸滑动控制
- 🖥️ Electron桌面端支持

## 技术栈

- Flutter 3.10+
- Provider (状态管理)
- SharedPreferences (数据存储)
- Vibration (震动反馈)
- Electron 28+ (桌面端)

## 运行项目

### 前置要求

确保已安装 Flutter SDK 和 Node.js：
- [Flutter官方安装指南](https://docs.flutter.dev/get-started/install)
- [Node.js官方安装](https://nodejs.org/)

### Flutter运行命令

```bash
# 安装依赖
flutter pub get

# 运行项目（默认设备）
flutter run

# 运行到Android设备
flutter run -d android

# 运行到iOS设备
flutter run -d ios

# 构建Web版本
flutter build web

# 构建Android APK
flutter build apk

# 构建iOS IPA
flutter build ios
```

### Electron运行命令

```bash
# 进入Electron目录
cd electron

# 安装依赖
npm install

# 先构建Flutter Web
npm run build:web

# 运行Electron开发模式
npm start

# 构建Windows安装包
npm run build
```

## 项目结构

```
├── lib/             # Flutter源代码
│   ├── components/       # UI组件
│   │   ├── game_board.dart    # 游戏网格
│   │   ├── score_board.dart   # 分数面板
│   │   ├── tile.dart          # 方块组件
│   │   ├── level_select.dart  # 关卡选择
│   │   └── settings_panel.dart # 设置面板
│   ├── game/            # 游戏引擎
│   │   └── game_engine.dart   # 核心游戏逻辑
│   ├── models/          # 数据模型
│   │   ├── tile.dart          # 方块数据
│   │   ├── game_state.dart    # 游戏状态
│   │   └── level.dart         # 关卡数据
│   ├── providers/       # 状态管理
│   │   ├── game_provider.dart # 游戏状态
│   │   └── theme_provider.dart # 主题状态
│   ├── screens/         # 页面
│   │   └── game_screen.dart   # 游戏页面
│   ├── services/        # 服务
│   │   ├── storage_service.dart  # 存储服务
│   │   └── vibration_service.dart # 震动服务
│   └── main.dart        # 应用入口
├── electron/        # Electron配置
│   ├── main.js          # 主进程
│   ├── preload.js       # 预加载脚本
│   ├── package.json     # 依赖配置
│   └── resources/       # 资源文件
├── build/web/       # Flutter Web构建输出
└── pubspec.yaml     # Flutter依赖配置
```

## 键盘控制

| 按键 | 功能 |
|------|------|
| ↑ / W | 向上移动 |
| ↓ / S | 向下移动 |
| ← / A | 向左移动 |
| → / D | 向右移动 |

## 游戏规则

1. 使用滑动控制方块移动
2. 相同数字的方块碰撞时会合并成一个
3. 目标是合并出2048方块
4. 无法移动时游戏结束

## 开发者

- GitHub: [bilibili-niang](https://github.com/bilibili-niang)

## 许可证

MIT License