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

- **纯前端**: HTML5 + CSS3 + JavaScript (ES6+)
- **框架**: 无依赖原生实现
- **存储**: LocalStorage
- **Electron 28+**: 桌面端打包

## 运行项目

### 前置要求

纯前端版本无需安装任何框架，直接打开即可运行。如需Electron桌面端，需安装Node.js：
- [Node.js官方安装](https://nodejs.org/)

### 纯前端运行（推荐）

**方式一：直接打开HTML文件**
```bash
# 直接在浏览器中打开 web/index.html
start web/index.html  # Windows
open web/index.html   # macOS/Linux
```

**方式二：使用本地服务器**
```bash
# 使用Python启动简单服务器
python -m http.server 8000

# 然后在浏览器访问 http://localhost:8000/web/
```

### Electron桌面端运行

```bash
# 进入Electron目录
cd electron

# 安装依赖
npm install

# 运行Electron开发模式
npm start

# 构建Windows安装包
npm run build
```

## 项目结构

```
├── web/             # 纯前端代码（无需依赖即可运行）
│   ├── index.html      # 页面结构
│   ├── style.css       # 样式文件
│   └── app.js          # 游戏逻辑
├── electron/        # Electron配置（可选）
│   ├── main.js          # 主进程
│   ├── preload.js       # 预加载脚本
│   ├── package.json     # 依赖配置
│   └── resources/       # 资源文件
├── .docs/           # 需求文档
└── README.md        # 项目说明
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