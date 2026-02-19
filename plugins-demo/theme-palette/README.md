# Theme Palette - SeaLantern 主题调色板插件

一个可视化的 CSS 主题编辑器，让你轻松自定义 SeaLantern 的外观。

## 功能概述

Theme Palette 是一个功能强大的主题编辑器，提供以下功能：

- **预设主题**：6 种精心设计的配色方案
- **自定义颜色**：支持自定义各种颜色值
- **实时预览**：修改立即生效，无需保存即可预览
- **独立页面**：提供独立的主题编辑界面
- **侧边栏导航**：方便快速访问主题设置
- **设置持久化**：所有修改自动保存

## 核心功能

### 预设主题

内置 6 种精美的主题配色方案：

| 预设 | 描述 | 适用场景 |
|------|------|----------|
| Default (Dark Blue) | 默认深蓝色主题 | 日常使用 |
| Midnight Purple | 午夜紫色主题 | 夜间工作 |
| Forest Green | 森林绿色主题 | 自然爱好者 |
| Sunset Orange | 日落橙色主题 | 温暖氛围 |
| Ocean Teal | 海洋青色主题 | 清新海洋风 |
| Rose Pink | 玫瑰粉色主题 | 柔和浪漫风 |

### 自定义颜色

可以自定义以下颜色参数：

**背景色：**
- Primary Background - 主背景色
- Secondary Background - 次要背景色
- Tertiary Background - 三级背景色

**强调色：**
- Accent Color - 主强调色（按钮、链接、高亮）
- Secondary Accent - 辅助强调色

**文字色：**
- Primary Text - 主文字颜色
- Secondary Text - 次要文字颜色

**边框色：**
- Border Color - 边框颜色

### 效果设置

**毛玻璃效果：**
- Glass Blur Amount - 毛玻璃模糊程度
  - Light (4px) - 轻度模糊
  - Medium (8px) - 中等模糊
  - Default (12px) - 默认模糊
  - Heavy (20px) - 重度模糊
  - Ultra (32px) - 超强模糊

**圆角设置：**
- Border Radius - 控制卡片和元素的圆角大小
  - Sharp (4px) - 少量圆角
  - Slight (8px) - 轻微圆角
  - Default (12px) - 默认圆角
  - Round (16px) - 明显圆角
  - Very Round (24px) - 圆润圆角

## 独立页面

Theme Palette 插件提供一个独立的主题编辑页面，位于侧边栏的"主题调色板"导航项。

### 页面功能

**预设主题区：**
- 显示 6 种预设主题
- 点击即可应用
- 当前选中的主题会高亮显示

**颜色设置区：**
- 输入框：支持文本输入
- 颜色选择器：直观选择颜色
- 实时预览：修改立即生效
- 支持的颜色格式：
  - 十六进制：`#60a5fa`
  - RGB/RGBA：`rgba(255, 255, 255, 0.08)`
  - HSL：`hsl(217, 91%, 60%)`
  - 颜色名称：`blue`

**效果设置区：**
- 毛玻璃模糊程度
- 圆角大小
- 点击选择，立即生效

## 使用方法

### 安装插件

1. 在插件市场中找到 Theme Palette
2. 点击"安装"按钮
3. 等待插件安装完成

### 启用插件

1. 进入"插件"页面
2. 找到 Theme Palette 插件
3. 点击开关启用插件
4. 插件会自动注入主题样式

### 配置主题

**方法一：通过独立页面（推荐）**

1. 点击侧边栏中的"主题调色板"
2. 选择一个预设主题，或
3. 在颜色设置中自定义颜色
4. 在效果设置中调整毛玻璃和圆角
5. 点击"保存设置"保存所有修改

**方法二：通过插件卡片**

1. 进入"插件"页面
2. 找到 Theme Palette 插件
3. 点击设置按钮（齿轮图标）
4. 进行主题配置

### 预设主题应用

1. 在预设主题区点击喜欢的主题
2. 该主题的颜色值会自动填充到设置中
3. 实时预览会立即显示效果
4. 点击"保存设置"持久化配置

### 自定义颜色

1. 在颜色设置区找到要修改的颜色
2. 在文本框中输入新的颜色值
3. 或者点击颜色选择器选择颜色
4. 修改会立即生效（实时预览）
5. 点击"保存设置"持久化配置

## 颜色设置说明

### 颜色值格式

Theme Palette 支持多种 CSS 颜色格式：

**十六进制：**
```css
#60a5fa
#FF5733
#FFFFFF
```

**RGB/RGBA：**
```css
rgb(96, 165, 250)
rgba(96, 165, 250, 0.5)
```

**HSL：**
```css
hsl(217, 91%, 60%)
hsla(217, 91%, 60%, 0.5)
```

**颜色名称：**
```css
blue
red
green
transparent
```

### 颜色参数详解

**背景色：**
- `bg_primary`：主背景色，通常是最深的颜色
- `bg_secondary`：次要背景色，用于卡片和面板
- `bg_tertiary`：三级背景色，用于悬停和选中状态

**强调色：**
- `accent_primary`：主要强调色，用于按钮、链接、焦点
- `accent_secondary`：辅助强调色，用于次要元素

**文字色：**
- `text_primary`：主文字颜色，通常为浅色
- `text_secondary`：次要文字颜色，用于描述性文本

**边框色：**
- `border_color`：边框和分隔线颜色

## 实时预览

Theme Palette 提供实时预览功能：

1. 修改颜色时，页面会立即显示效果
2. 不需要保存即可预览
3. 这让你可以快速尝试不同的配色方案
4. 满意后点击"保存设置"持久化配置

## 设置持久化

所有设置会自动保存到插件的数据目录中：

```json
{
  "bg_primary": "#0a0a0f",
  "bg_secondary": "#12121a",
  "bg_tertiary": "#1a1a25",
  "accent_primary": "#60a5fa",
  "accent_secondary": "#818cf8",
  "text_primary": "#e2e8f0",
  "text_secondary": "#94a3b8",
  "border_color": "rgba(255, 255, 255, 0.08)",
  "glass_blur": "12px",
  "border_radius": "12px",
  "preset": "default"
}
```

如果你的主题设置文件丢失，可以：
1. 重新选择预设主题
2. 或者手动输入默认值
3. 系统会在插件启用时自动应用存储的设置

## 应用的主题参数

Theme Palette 通过 CSS 变量将颜色映射到应用的不同部分：

| 设置参数 | CSS 变量 | 说明 |
|----------|----------|------|
| `bg_primary` | `--sl-bg` | 主背景色 |
| `bg_secondary` | `--sl-bg-secondary` | 次要背景色 |
| `bg_tertiary` | `--sl-bg-tertiary` | 三级背景色 |
| `accent_primary` | `--sl-primary` | 主强调色 |
| `accent_secondary` | `--sl-accent` | 辅助强调色 |
| `text_primary` | `--sl-text-primary` | 主文字颜色 |
| `text_secondary` | `--sl-text-secondary` | 次要文字颜色 |
| `border_color` | `--sl-border` | 边框颜色 |
| `glass_blur` | `--sl-glass-blur` | 毛玻璃模糊 |
| `border_radius` | `--sl-radius-lg` | 圆角大小 |

## 侧边栏导航

Theme Palette 插件会在侧边栏添加导航项：

- **标签**：主题调色板
- **图标**：调色板图标
- **分组**：系统
- **优先级**：50

点击侧边栏中的"主题调色板"可以快速访问主题设置。

## 插件结构

Theme Palette 插件的文件结构：

```
theme-palette/
├── manifest.json      # 插件配置
├── main.lua           # 插件入口
├── style.css          # 自定义样式
├── icon.png           # 插件图标
└── README.md          # 本文档
```

### manifest.json

定义了插件的基本信息、权限、侧边栏配置和设置项。

**重要字段：**

```json
{
  "id": "theme-palette",
  "name": "Theme Palette",
  "permissions": ["log", "storage"],
  "settings": [...],
  "ui": {
    "sidebar": {
      "label": "主题调色板",
      "icon": "palette",
      "priority": 50
    }
  }
}
```

### main.lua

处理插件的生命周期：

```lua
local plugin = {}

function plugin.onLoad()
    sl.log.info("主题调色板插件已加载")
end

function plugin.onEnable()
    sl.log.info("主题调色板插件已启用")
end

function plugin.onDisable()
    sl.log.warn("主题调色板插件正在被禁用")
end

function plugin.onUnload()
    sl.log.info("主题调色板插件已卸载")
end

return plugin
```

### style.css

插件的自定义样式，会在插件启用时自动注入。

## 限制和注意事项

1. **颜色覆盖**：自定义颜色会覆盖预设主题的对应颜色
2. **禁用恢复**：禁用插件后会恢复默认主题
3. **深色背景**：建议使用深色背景以保持最佳可读性
4. **颜色格式**：确保使用有效的 CSS 颜色格式
5. **实时预览**：修改会立即生效，直到点击保存或重置

## 常见问题

### 如何重置为默认主题？

1. 打开主题调色板页面
2. 点击"预设主题"中的"Default (Dark Blue)"
3. 或者点击"重置为默认"按钮

### 自定义颜色后效果不好看怎么办？

1. 尝试不同的预设主题
2. 调整毛玻璃模糊程度
3. 调整圆角大小
4. 使用颜色选择器微调颜色

### 插件启用后不生效怎么办？

1. 确保已正确启用插件
2. 检查浏览器控制台是否有错误
3. 尝试刷新页面
4. 重新启用插件

### 如何分享我的主题？

1. 保存你的主题配置
2. 导出设置值
3. 分享给他人
4. 他人可以导入相同的配置

## 技术细节

Theme Palette 插件通过以下方式工作：

1. **CSS 注入**：插件启用时自动注入 CSS 样式
2. **CSS 变量**：使用 CSS 变量控制颜色和样式
3. **实时预览**：通过修改 `document.documentElement.style` 实现实时预览
4. **设置存储**：使用 storage API 保存和读取设置
5. **独立页面**：提供专门的 UI 进行主题编辑

## 开发者说明

如果你想基于 Theme Palette 开发自己的主题插件：

1. 复制 Theme Palette 的实现结构
2. 修改 `manifest.json` 中的设置项
3. 在 `style.css` 中定义你的 CSS 变量
4. 修改 `main.lua` 的生命周期函数
5. 确保使用正确的权限（`["log", "storage"]`）

## 版本历史

### v1.0.0

- 初始版本
- 支持 6 种预设主题
- 支持自定义颜色
- 支持毛玻璃效果
- 支持圆角设置
- 支持实时预览
- 支持侧边栏导航
- 独立主题编辑页面

## 许可证

GPLv3 License

## 贡献

欢迎贡献！请提交 Pull Request 或创建 Issue。

## 更多信息

- **API 参考**：查看 [API.md](../plugin-template/API.md) 了解插件系统的详细文档
- **插件模板**：查看 [插件模板](../plugin-template/README.md) 了解如何创建插件
- **插件市场**：查看 [插件市场](../../plugin-market/README.md) 了解如何发布插件
