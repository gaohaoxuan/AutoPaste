# Paste — macOS 剪贴板管理器

Paste 是一个运行于 macOS 的原生剪贴板管理器，功能参考 Windows 11 自带剪贴板（Win + V），交互和视觉风格遵循 macOS 设计语言。

## 功能

- **剪贴板监听** — 自动捕获文本、图片（PNG/JPEG/TIFF/GIF/WEBP）、HTML、文件
- **历史记录** — 最多保存 100 条（可配置），超出自动删除最旧的非固定项
- **一键恢复** — 点击任意历史项恢复到系统剪贴板
- **固定（Pin）** — 固定项始终置顶，不参与自动清理
- **搜索** — 实时搜索文本内容和文件名
- **删除与清空** — 单条删除、清空全部（保留固定项）
- **全局快捷键** — 默认 ⌘⇧V 呼出面板（可在设置中查看）
- **开机自启** — 自动注册到系统登录项
- **持久化** — 数据通过 SQLite 存储，图片缓存在本地
- **浅色/深色模式** — 支持系统外观自动切换

## 系统要求

- macOS 14.0+
- Apple Silicon（arm64）

## 安装

### 方式一：make install

```bash
cd Paste
make install    # 编译、打包、安装到 /Applications
```

### 方式二：DMG 安装包

```bash
make dmg        # 生成 Paste.dmg
open Paste.dmg  # 打开后拖入 Applications 文件夹
```

### 方式三：直接运行

```bash
make run        # 编译并启动
```

## 使用

1. 启动后 Paste 运行在状态栏（无 Dock 图标）
2. 首次使用需在「系统设置 → 隐私与安全性 → 辅助功能」中授权
3. 复制任意内容，按 **⌘⇧V** 打开剪贴板面板
4. 点击历史项恢复到剪贴板，右键可固定或删除
5. 顶部搜索框支持实时过滤，⚙ 齿轮打开设置

## 项目结构

```
Paste/
├── Package.swift              # Swift Package Manager 配置
├── Makefile                   # 构建、安装、DMG 打包
├── Info.plist                 # 应用 Bundle 配置
├── AppIcon.png                # 应用图标
├── Sources/
│   ├── PasteApp/              # 应用入口 + AppDelegate
│   ├── ClipboardManager/      # 中央编排器
│   ├── ClipboardListener/     # 剪贴板轮询监听
│   ├── ClipboardHistory/      # 数据模型与历史管理
│   ├── ClipboardStorage/      # SQLite 持久化 + 图片缓存
│   ├── ClipboardSearch/       # 搜索过滤
│   ├── ClipboardHotkey/       # Carbon 全局快捷键
│   ├── ClipboardWindow/       # 主面板 UI（SwiftUI）
│   ├── ClipboardPreview/      # 文本/图片/HTML/文件预览
│   ├── ClipboardSettings/     # 设置管理 + 设置界面
│   └── Utilities/             # 常量、扩展、错误类型
└── Tests/
    └── PasteTests.swift       # 单元测试
```

## 技术栈

| 项目 | 技术 |
|------|------|
| 语言 | Swift 6.1 |
| UI | SwiftUI + AppKit（混合） |
| 快捷键 | Carbon Event（`RegisterEventHotKey`） |
| 存储 | SQLite3（原生 C API） |
| 图片缓存 | `~/Library/Caches/Paste/Images/` |
| 设置 | UserDefaults + Combine |
| 测试 | Swift Testing（`@Suite` / `@Test` / `#expect`） |

## 构建命令

```bash
make build      # 仅编译（Release）
make install    # 编译 + 安装到 /Applications
make dmg        # 编译 + 生成 DMG 安装包
make run        # 编译 + 启动
make clean      # 清理构建产物
```

## 权限说明

应用需要「辅助功能」权限才能注册全局快捷键。首次启动后：

1. 打开「系统设置 → 隐私与安全性 → 辅助功能」
2. 点击 + 号，添加 `/Applications/Paste.app`
3. 确保开关为开启状态

## 关机行为

退出应用时 SQLite 中的历史记录会被**完全清空**，下次启动从零开始。

## 许可证

Copyright © 2025. All rights reserved.
