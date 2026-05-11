# 2048 Game (Flutter)

这是一个以 **Flutter** 为主的 2048 小游戏项目，当前开发重点是 Android 平台，代码主目录为 `flutter_2048/`。

## 当前状态

- 主开发方向：Flutter（Android 优先）
- Electron 桌面端：已移除
- 需求与上架文档：位于 `.docs/05-09/`

## 功能特性

- 经典 2048 数字合并玩法
- 支持 3x3 到 10x10 网格尺寸
- 深色/浅色主题切换
- 分数与最高分记录
- 本地数据持久化（SharedPreferences）
- 触摸滑动交互
- 震动反馈（移动端）

## 技术栈

- Flutter (Dart SDK `^3.11.0`)
- provider `^6.0.5`
- shared_preferences `^2.2.2`
- vibration `^3.1.8`

## 快速开始

### 1. 环境准备

- 安装 Flutter SDK（建议稳定版）
- 配置 Android 开发环境（Android SDK + 模拟器或真机）

### 2. 安装依赖并运行

```bash
cd flutter_2048
flutter pub get
flutter run
```

### 3. 构建 APK

```bash
cd flutter_2048
flutter build apk --release
```

## 项目结构

```text
.
├── flutter_2048/                 # Flutter 主项目
│   ├── lib/
│   │   ├── components/           # 视图组件
│   │   ├── models/               # 数据模型
│   │   ├── providers/            # 状态管理
│   │   ├── screens/              # 页面
│   │   └── main.dart             # 入口
│   ├── android/                  # Android 工程
│   ├── web/                      # Flutter Web 资源
│   └── windows/                  # Flutter Windows 资源
├── .docs/05-09/                  # 需求与上架文档
└── README.md
```

## 文档入口

- 需求文档：`.docs/05-09/2048游戏需求开发文档.md`
- 上架清单：`.docs/05-09/GooglePlay上架问题清单.md`

## License

MIT
