# SeaLantern 插件 API 参考

本文档描述了 SeaLantern 插件系统提供的所有功能和 API。

## 目录

- [插件目录结构](#插件目录结构)
- [manifest.json 配置](#manifestjson-配置)
- [Lua API 参考](#lua-api-参考)
  - [sl.log 命名空间](#sllog-命名空间)
  - [sl.storage 命名空间](#slstorage-命名空间)
  - [sl.ui 命名空间](#slui-命名空间)
  - [sl.element 命名空间](#slelement-命名空间)
  - [sl.process 命名空间](#slprocess-命名空间)
  - [sl.plugins 命名空间](#slplugins-命名空间)
- [生命周期钩子](#生命周期钩子)
- [CSS 注入](#css-注入)
- [设置系统](#设置系统)
- [侧边栏导航](#侧边栏导航)
- [插件市场](#插件市场)
- [最佳实践](#最佳实践)

---

## 插件目录结构

一个完整的 SeaLantern 插件目录结构如下：

```
my-plugin/
├── manifest.json      # 必需 - 插件元数据和配置
├── main.lua           # 必需 - 插件主入口文件
├── icon.png           # 可选 - 插件图标
├── style.css          # 可选 - 自定义 CSS 样式
├── settings.json      # 自动生成 - 存储用户设置值
└── storage.json       # 自动生成 - 存储插件数据
```

### 文件说明

#### manifest.json
插件的核心配置文件，定义了插件的元数据、权限和功能。所有字段将在下文详细说明。

#### main.lua
插件的主入口文件，包含生命周期回调函数。插件通过定义特定的函数来响应不同的生命周期事件。

#### icon.png
插件图标文件，显示在插件卡片和侧边栏中。支持多种图片格式，要求为正方形。

#### style.css
可选的 CSS 样式文件，用于自定义插件界面或应用整体样式。当插件启用时，CSS 会自动注入。

#### settings.json
自动生成的文件，存储插件的用户配置值。格式为 JSON。

#### storage.json
自动生成的文件，存储插件的持久化数据。格式为 JSON。

---

## manifest.json 配置

manifest.json 是插件的核心配置文件，定义了插件的所有属性和功能。

### 完整字段说明

```json
{
  "id": "my-plugin",
  "name": "My Plugin",
  "version": "1.0.0",
  "description": "插件描述",
  "author": {
    "name": "作者名",
    "url": "https://github.com/yourname"
  },
  "main": "main.lua",
  "icon": "icon.png",
  "repository": "https://github.com/yourname/my-plugin",
  "permissions": ["log", "storage"],
  "dependencies": {
    "other-plugin": ">=1.0.0"
  },
  "settings": [...],
  "ui": {
    "sidebar": {
      "label": "显示名称",
      "icon": "palette",
      "priority": 50
    }
  }
}
```

### 字段详解

#### 基本字段

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `id` | string | 是 | 插件唯一标识符，建议使用小写字母、数字和连字符 |
| `name` | string | 是 | 插件显示名称 |
| `version` | string | 是 | 版本号，建议使用语义化版本 (如 1.0.0) |
| `description` | string | 是 | 插件描述 |
| `author` | object | 是 | 作者信息 |

#### author 字段

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `name` | string | 是 | 作者名称 |
| `url` | string | 否 | 作者主页链接 |
| `email` | string | 否 | 作者电子邮件地址 |

#### 主入口和图标

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `main` | string | 是 | 主入口 Lua 文件名，如 "main.lua" |
| `icon` | string | 否 | 插件图标文件名，如 "icon.png" |

**图标规格：**
- 支持格式：png, jpg, gif, webp, svg, ico, bmp
- 必须为正方形（宽高相等）
- 建议大小：64x64 或 128x128 像素
- 最大尺寸：2048x2048 像素
- 建议使用白色或浅色背景，以在深色主题下清晰显示

#### 仓库信息

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `repository` | string | 否 | 插件源代码仓库链接（如 GitHub、Gitee） |
| `homepage` | string | 否 | 插件主页链接 |
| `license` | string | 否 | 插件许可证（如 MIT、GPL-3.0） |

#### 发动机要求

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `engines` | object | 否 | 指定兼容的 SeaLantern 版本 |

```json
{
  "engines": {
    "sealantern": ">=1.0.0"
  }
}
```

#### 权限列表

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `permissions` | array | 是 | 请求的权限列表 |

当前支持的权限：

| 权限 | 危险等级 | 说明 |
|------|----------|------|
| `log` | 普通 | 允许使用日志 API (sl.log) |
| `storage` | 普通 | 允许使用存储 API (sl.storage) |
| `ui` | 普通 | 允许使用 UI 控制 API (sl.ui) |
| `element` | 普通 | 允许使用元素交互 API (sl.element) |
| `api` | 普通 | 允许调用其他插件注册的 API (sl.api) |
| `system` | 普通 | 允许获取系统信息 (sl.system) |
| `fs` | 危险 | 允许在插件自身目录内读写文件 (sl.fs) |
| `network` | 危险 | 允许发送 HTTP 请求 (sl.http) |
| `server` | 危险 | 允许管理 Minecraft 服务器 (sl.server) |
| `console` | 危险 | 允许向服务器控制台发送命令 (sl.console) |
| `execute_program` | 极度危险 | 允许在插件目录内执行外部程序 (sl.process) |
| `plugin_folder_access` | 极度危险 | 允许读写其他插件的文件和数据 (sl.plugins) |

权限危险等级说明：
- **普通** - 基本功能，风险较低
- **危险** - 可能影响系统或数据安全，需要用户注意
- **极度危险** - 可执行任意程序或访问敏感数据，请务必确认插件来源可信

注意：所有 API 调用和命令执行都会被追踪并显示在权限信息面板中，便于用户了解插件的实际行为。

#### 依赖关系

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `dependencies` | object | 否 | 插件依赖的其他插件 |

```json
{
  "dependencies": {
    "other-plugin": ">=1.0.0",
    "another-plugin": "~2.0.0"
  }
}
```

版本约束语法：
- `>=1.0.0` - 大于或等于 1.0.0
- `<=2.0.0` - 小于或等于 2.0.0
- `~1.2.0` - 兼容 1.2.x 版本
- `^1.0.0` - 兼容 1.x.x 版本

#### 事件和命令

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `events` | array | 否 | 插件可以触发的事件列表 |
| `commands` | array | 否 | 插件注册的命令列表 |

```json
{
  "events": ["player-join", "player-quit"],
  "commands": [
    {
      "id": "mycommand",
      "title": "我的命令",
      "shortcut": "Ctrl+Shift+M"
    }
  ]
}
```

#### UI 配置

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `ui` | object | 否 | 插件 UI 配置 |

```json
{
  "ui": {
    "pages": [...],
    "sidebar": {...},
    "contextMenus": [...]
  }
}
```

**pages 数组：**

用于定义插件的独立页面。

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `id` | string | 是 | 页面唯一标识符 |
| `title` | string | 是 | 页面标题 |
| `path` | string | 是 | 页面路径（如 "settings"） |
| `icon` | string | 否 | 页面图标名 |

**contextMenus 数组：**

用于定义上下文菜单项。

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `id` | string | 是 | 菜单项唯一标识符 |
| `title` | string | 是 | 菜单项显示文本 |
| `contexts` | array | 否 | 触发该菜单的上下文类型 |

#### 设置项配置

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `settings` | array | 否 | 插件设置项定义 |

设置项会在插件启用时自动生成配置 UI，并存储在 `settings.json` 文件中。

### PluginSettingField 类型

每个设置项是一个对象，具有以下字段：

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `key` | string | 是 | 设置项的唯一标识符 |
| `label` | string | 是 | 显示的标签 |
| `type` | string | 是 | 类型：string, number, boolean, select, textarea, checkbox |
| `default` | any | 是 | 默认值 |
| `description` | string | 否 | 设置项描述 |
| `options` | array | select 类型必需 | 选项列表 |
| `rows` | number | 否 | textarea 专用，显示行数（默认 3） |
| `maxlength` | number | 否 | textarea 专用，最大字符数 |

#### 设置项类型示例

**string - 文本输入：**
```json
{
  "key": "greeting",
  "label": "问候语",
  "type": "string",
  "default": "Hello",
  "description": "显示的问候语"
}
```

**textarea - 多行文本输入：**
```json
{
  "key": "motd",
  "label": "服务器公告",
  "type": "textarea",
  "default": "",
  "description": "显示在服务器列表中的公告内容",
  "rows": 5,
  "maxlength": 500
}
```

**number - 数字输入：**
```json
{
  "key": "max_count",
  "label": "最大数量",
  "type": "number",
  "default": 10,
  "description": "允许的最大数量"
}
```

**boolean - 开关：**
```json
{
  "key": "enabled",
  "label": "启用功能",
  "type": "boolean",
  "default": true,
  "description": "是否启用此功能"
}
```

**checkbox - 复选框：**

与 boolean 类似，但渲染为复选框样式而非开关。适用于需要明确勾选确认的场景。

```json
{
  "key": "agree_terms",
  "label": "同意使用条款",
  "type": "checkbox",
  "default": false,
  "description": "勾选表示同意相关条款"
}
```

**select - 下拉选择：**
```json
{
  "key": "theme",
  "label": "主题",
  "type": "select",
  "default": "light",
  "description": "选择主题",
  "options": [
    { "value": "light", "label": "浅色" },
    { "value": "dark", "label": "深色" },
    { "value": "auto", "label": "跟随系统" }
  ]
}
```

### sidebar 配置

侧边栏导航配置：

```json
{
  "sidebar": {
    "label": "显示名称",
    "icon": "palette",
    "group": "system",
    "priority": 50
  }
}
```

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `label` | string | 是 | 侧边栏显示的标签 |
| `icon` | string | 否 | 图标名称（使用 Lucide 图标名） |
| `group` | string | 否 | 分组 (main, server, system) |
| `priority` | number | 否 | 排序优先级，数字越小越靠前 |

可用的图标名称（部分）：
- `home` - 首页
- `plus` - 添加
- `terminal` - 终端
- `settings` - 设置
- `users` - 用户
- `puzzle` - 拼图
- `store` - 商店
- `palette` - 调色板
- `info` - 信息

### 完整示例

```json
{
  "id": "theme-palette",
  "name": "Theme Palette",
  "version": "1.0.0",
  "description": "Visual CSS theme editor for SeaLantern",
  "author": {
    "name": "Your Name",
    "url": "https://github.com/yourname"
  },
  "main": "main.lua",
  "icon": "icon.png",
  "repository": "https://github.com/yourname/theme-palette",
  "permissions": ["log", "storage"],
  "settings": [
    {
      "key": "bg_primary",
      "label": "Primary Background",
      "type": "string",
      "default": "#0a0a0f",
      "description": "Main background color"
    },
    {
      "key": "glass_blur",
      "label": "Glass Blur Amount",
      "type": "select",
      "default": "12px",
      "description": "Backdrop blur intensity for glass effect",
      "options": [
        { "value": "4px", "label": "Light (4px)" },
        { "value": "8px", "label": "Medium (8px)" },
        { "value": "12px", "label": "Default (12px)" },
        { "value": "20px", "label": "Heavy (20px)" }
      ]
    }
  ],
  "ui": {
    "sidebar": {
      "label": "主题调色板",
      "icon": "palette",
      "priority": 50
    }
  }
}
```

---

## Lua API 参考

### 全局变量

插件运行时会自动注入以下全局变量：

| 变量 | 类型 | 说明 |
|------|------|------|
| `PLUGIN_ID` | string | 当前插件的 ID |
| `PLUGIN_DIR` | string | 插件目录的绝对路径 |

### sl 命名空间

所有插件 API 都通过 `sl` 全局对象提供。

#### sl.log 命名空间

日志 API 用于输出调试信息。所有日志都会自动添加插件 ID 前缀。

**方法：**

| 方法 | 说明 |
|------|------|
| `sl.log.debug(message)` | 调试级别日志 |
| `sl.log.info(message)` | 信息级别日志 |
| `sl.log.warn(message)` | 警告级别日志 |
| `sl.log.error(message)` | 错误级别日志 |

**参数：**
- `message` (string): 要输出的日志消息

**示例：**
```lua
sl.log.info("插件已启动")
sl.log.warn("配置文件不存在，使用默认值")
sl.log.error("无法连接到服务器")
```

#### sl.storage 命名空间

存储 API 用于持久化插件数据。数据存储在插件目录下的 `storage.json` 文件中。

**方法：**

**sl.storage.get(key)**
获取存储的值。

参数：
- `key` (string): 存储键名

返回值：
- `string | number | boolean | table | nil`: 存储的值，如果不存在则返回 nil

示例：
```lua
local value = sl.storage.get("my_key")
if value then
    sl.log.info("值: " .. tostring(value))
else
    sl.log.info("键不存在")
end
```

**sl.storage.set(key, value)**
存储一个值。

参数：
- `key` (string): 存储键名
- `value` (string | number | boolean | table): 要存储的值

示例：
```lua
sl.storage.set("my_key", "my_value")
sl.storage.set("counter", 42)
sl.storage.set("config", { enabled = true, count = 10 })
```

**sl.storage.remove(key)**
删除一个存储的值。

参数：
- `key` (string): 要删除的键名

示例：
```lua
sl.storage.remove("my_key")
```

**sl.storage.keys()**
获取所有存储键的列表。

返回值：
- `table`: 包含所有键名的数组

示例：
```lua
local keys = sl.storage.keys()
for _, key in ipairs(keys) do
    sl.log.info("键: " .. key)
end
```

#### sl.ui 命名空间

UI 控制 API 用于操作应用界面元素。需要 `ui` 权限。

**sl.ui.hide(selector)**

隐藏匹配选择器的元素。

参数：
- `selector` (string): CSS 选择器

返回值：
- `boolean`: 是否成功

示例：
```lua
sl.ui.hide(".some-element")
sl.ui.hide("#server-start-btn")
```

**sl.ui.show(selector)**

显示匹配选择器的元素。

参数：
- `selector` (string): CSS 选择器

返回值：
- `boolean`: 是否成功

示例：
```lua
sl.ui.show(".some-element")
```

**sl.ui.disable(selector)**

禁用匹配选择器的元素（添加 disabled 属性）。

参数：
- `selector` (string): CSS 选择器

返回值：
- `boolean`: 是否成功

示例：
```lua
sl.ui.disable("#some-button")
```

**sl.ui.enable(selector)**

启用匹配选择器的元素（移除 disabled 属性）。

参数：
- `selector` (string): CSS 选择器

返回值：
- `boolean`: 是否成功

示例：
```lua
sl.ui.enable("#some-button")
```

**sl.ui.insert(placement, selector, html)**

在指定位置插入 HTML 内容。

参数：
- `placement` (string): 插入位置，可选值：
  - `"before"`: 目标元素外部之前
  - `"after"`: 目标元素外部之后
  - `"prepend"`: 目标元素内部开头
  - `"append"`: 目标元素内部结尾
- `selector` (string): CSS 选择器，用于定位参考元素
- `html` (string): 要插入的 HTML 内容

返回值：
- `boolean`: 是否成功

示例：
```lua
sl.ui.insert("append", ".container", "<div class='my-element'>新内容</div>")
sl.ui.insert("before", "#target", "<span>前置内容</span>")
```

**sl.ui.remove(selector)**

移除插件插入的元素。注意：只能移除由当前插件插入的元素。

参数：
- `selector` (string): CSS 选择器

返回值：
- `boolean`: 是否成功

示例：
```lua
sl.ui.remove(".my-element")
```

**sl.ui.set_style(selector, styles)**

设置匹配元素的样式。

参数：
- `selector` (string): CSS 选择器
- `styles` (table): 样式表，键为 CSS 属性名，值为属性值

返回值：
- `boolean`: 是否成功

示例：
```lua
sl.ui.set_style(".some-element", {
    color = "red",
    ["font-size"] = "14px",
    ["background-color"] = "#f0f0f0"
})
```

**sl.ui.set_attribute(selector, attr, value)**

设置匹配元素的属性。

参数：
- `selector` (string): CSS 选择器
- `attr` (string): 属性名
- `value` (string): 属性值

返回值：
- `boolean`: 是否成功

示例：
```lua
sl.ui.set_attribute(".some-element", "title", "提示文字")
sl.ui.set_attribute("img.avatar", "src", "/new-avatar.png")
```

**sl.ui.query(selector)**

查询匹配选择器的元素信息。

参数：
- `selector` (string): CSS 选择器

返回值：
- `table`: 元素信息数组，每个元素包含 id、tag、class、visible 等属性

示例：
```lua
local elements = sl.ui.query(".sidebar-item")
for _, elem in ipairs(elements) do
    sl.log.info("元素: " .. elem.tag .. ", 可见: " .. tostring(elem.visible))
end
```

#### sl.element 命名空间

元素交互 API 用于读取元素内容和模拟用户交互。需要 `element` 权限。

**sl.element.get_text(selector)**

获取元素的文本内容。

参数：
- `selector` (string): CSS 选择器

返回值：
- `string`: 元素的文本内容

示例：
```lua
local text = sl.element.get_text(".player-name")
sl.log.info("玩家名: " .. text)
```

**sl.element.get_value(selector)**

获取表单元素的当前值（适用于 input、select、textarea）。

参数：
- `selector` (string): CSS 选择器

返回值：
- `string`: 表单元素的值

示例：
```lua
local value = sl.element.get_value("#my-input")
local selected = sl.element.get_value("select.language-selector")
```

**sl.element.get_attribute(selector, attr)**

获取元素的指定属性值。

参数：
- `selector` (string): CSS 选择器
- `attr` (string): 属性名

返回值：
- `string | nil`: 属性值，如果不存在则返回 nil

示例：
```lua
local href = sl.element.get_attribute("a.link", "href")
local src = sl.element.get_attribute("img.icon", "src")
```

**sl.element.get_attributes(selector)**

获取元素的所有属性。

参数：
- `selector` (string): CSS 选择器

返回值：
- `table`: 属性表，键为属性名，值为属性值

示例：
```lua
local attrs = sl.element.get_attributes("input.config")
sl.log.info("类型: " .. (attrs.type or "未知"))
sl.log.info("占位符: " .. (attrs.placeholder or "无"))
```

**sl.element.click(selector)**

触发元素的点击事件。

参数：
- `selector` (string): CSS 选择器

返回值：
- `boolean`: 是否成功

示例：
```lua
sl.element.click("#submit-btn")
sl.element.click(".player-item[data-id='Steve']")
```

**sl.element.set_value(selector, value)**

设置表单元素的值。

参数：
- `selector` (string): CSS 选择器
- `value` (string): 要设置的值

返回值：
- `boolean`: 是否成功

示例：
```lua
sl.element.set_value("#my-input", "新值")
sl.element.set_value("textarea.notes", "服务器描述")
```

**sl.element.check(selector, checked)**

设置复选框或开关的选中状态。

参数：
- `selector` (string): CSS 选择器
- `checked` (boolean): 是否选中

返回值：
- `boolean`: 是否成功

示例：
```lua
sl.element.check("#my-checkbox", true)
sl.element.check("input.auto-start", false)
```

**sl.element.select(selector, value)**

选择下拉框的指定选项。

参数：
- `selector` (string): CSS 选择器
- `value` (string): 要选择的 option 值

返回值：
- `boolean`: 是否成功

示例：
```lua
sl.element.select("#my-select", "option-value")
sl.element.select("select.version", "1.20.4")
```

**sl.element.focus(selector)**

聚焦到指定元素。

参数：
- `selector` (string): CSS 选择器

返回值：
- `boolean`: 是否成功

示例：
```lua
sl.element.focus("#my-input")
```

**sl.element.blur(selector)**

取消元素的聚焦状态。

参数：
- `selector` (string): CSS 选择器

返回值：
- `boolean`: 是否成功

示例：
```lua
sl.element.blur("#my-input")
```

**sl.element.on_change(selector, callback)**

监听元素值变化事件。

参数：
- `selector` (string): CSS 选择器
- `callback` (function): 回调函数，接收变化后的值作为参数

返回值：
- `boolean`: 是否成功

示例：
```lua
sl.element.on_change("#my-input", function(value)
    sl.log.info("值变化: " .. tostring(value))
end)

sl.element.on_change("select.version", function(value)
    sl.log.info("选择了版本: " .. value)
end)
```

#### sl.process 命名空间

进程执行 API，允许插件在自身目录内执行外部程序。需要 `execute_program` 权限（极度危险）。

安全限制：
- 只能执行位于插件自身目录内的程序
- 路径不允许包含 `..` 或使用绝对路径
- 插件禁用时，所有由该插件启动的进程会被自动终止
- 所有操作都会记录审计日志

**sl.process.exec(program, args, options)**

执行插件目录内的程序。

参数：
- `program` (string): 相对于插件目录的可执行文件路径
- `args` (table, 可选): 命令行参数数组
- `options` (table, 可选): 选项表
  - `cwd` (string): 工作目录（相对于插件目录，默认为插件目录）
  - `env` (table): 环境变量表
  - `background` (boolean): 是否后台运行（默认 false）

返回值：
- `table`: 包含以下字段
  - `pid` (number): 进程 ID（失败时为 0）
  - `success` (boolean): 是否成功启动
  - `exit_code` (number): 退出码（仅非后台模式）
  - `error` (string): 错误信息（失败时）

示例：
```lua
-- 执行插件目录下的脚本（阻塞等待完成）
local result = sl.process.exec("scripts/build.bat", {"--release"})
if result.success then
    sl.log.info("构建完成，退出码: " .. tostring(result.exit_code))
end

-- 后台执行
local result = sl.process.exec("server.exe", {"--port", "8080"}, {
    background = true,
    env = { MODE = "production" }
})
if result.success then
    sl.log.info("服务器已启动，PID: " .. tostring(result.pid))
end
```

**sl.process.kill(pid)**

终止指定进程。

参数：
- `pid` (number): 进程 ID

返回值：
- `boolean`: 是否成功终止（进程不存在时返回 false）

示例：
```lua
local killed = sl.process.kill(12345)
```

**sl.process.get(pid)**

获取进程状态。

参数：
- `pid` (number): 进程 ID

返回值：
- `table | nil`: 进程信息，不存在时返回 nil
  - `pid` (number): 进程 ID
  - `running` (boolean): 是否正在运行
  - `exit_code` (number): 退出码（仅已结束的进程）

示例：
```lua
local info = sl.process.get(12345)
if info and info.running then
    sl.log.info("进程仍在运行")
end
```

**sl.process.list()**

列出当前插件启动的所有进程。

返回值：
- `table`: 进程信息数组，每项包含
  - `pid` (number): 进程 ID
  - `program` (string): 程序路径
  - `running` (boolean): 是否正在运行

示例：
```lua
local procs = sl.process.list()
for _, p in ipairs(procs) do
    sl.log.info("PID=" .. p.pid .. " " .. p.program .. " running=" .. tostring(p.running))
end
```

**sl.process.read_output(pid)**

读取进程的标准输出。

参数：
- `pid` (number): 进程 ID

返回值：
- `string | nil`: 输出内容，无数据时返回 nil

示例：
```lua
local output = sl.process.read_output(12345)
if output then
    sl.log.info("输出: " .. output)
end
```

#### sl.plugins 命名空间

跨插件文件夹访问 API，允许插件读写其他插件的文件。需要 `plugin_folder_access` 权限（极度危险）。

安全限制：
- 只能访问已安装插件的目录
- 路径不允许包含 `..` 或使用绝对路径
- 文件大小限制为 10MB
- 所有操作都会记录审计日志

**sl.plugins.list()**

列出所有已安装的插件。

返回值：
- `table`: 插件信息数组，每项包含
  - `id` (string): 插件 ID
  - `name` (string): 插件名称
  - `version` (string): 插件版本
  - `installed` (boolean): 是否已安装

示例：
```lua
local plugins = sl.plugins.list()
for _, p in ipairs(plugins) do
    sl.log.info(p.id .. " v" .. p.version)
end
```

**sl.plugins.get_manifest(plugin_id)**

获取指定插件的 manifest 信息。

参数：
- `plugin_id` (string): 目标插件 ID

返回值：
- `table | nil`: manifest 内容（Lua table），不存在时返回 nil

示例：
```lua
local manifest = sl.plugins.get_manifest("other-plugin")
if manifest then
    sl.log.info("插件名: " .. manifest.name)
    sl.log.info("版本: " .. manifest.version)
end
```

**sl.plugins.read_file(plugin_id, relative_path)**

读取指定插件目录下的文件。

参数：
- `plugin_id` (string): 目标插件 ID
- `relative_path` (string): 相对于目标插件目录的文件路径

返回值：
- `string | nil`: 文件内容，文件不存在时返回 nil

示例：
```lua
local config = sl.plugins.read_file("other-plugin", "config.json")
if config then
    sl.log.info("读取到配置: " .. config)
end
```

**sl.plugins.write_file(plugin_id, relative_path, content)**

写入指定插件目录下的文件。

参数：
- `plugin_id` (string): 目标插件 ID
- `relative_path` (string): 相对于目标插件目录的文件路径
- `content` (string): 要写入的内容

返回值：
- `boolean`: 是否成功

示例：
```lua
local ok = sl.plugins.write_file("other-plugin", "shared/data.json", '{"key":"value"}')
```

**sl.plugins.file_exists(plugin_id, relative_path)**

检查指定插件目录下的文件是否存在。

参数：
- `plugin_id` (string): 目标插件 ID
- `relative_path` (string): 相对于目标插件目录的文件路径

返回值：
- `boolean`: 文件是否存在

示例：
```lua
if sl.plugins.file_exists("other-plugin", "config.json") then
    sl.log.info("配置文件存在")
end
```

**sl.plugins.list_files(plugin_id, relative_path)**

列出指定插件目录下的文件。

参数：
- `plugin_id` (string): 目标插件 ID
- `relative_path` (string): 相对于目标插件目录的目录路径

返回值：
- `table`: 文件名数组

示例：
```lua
local files = sl.plugins.list_files("other-plugin", "data")
for _, name in ipairs(files) do
    sl.log.info("文件: " .. name)
end
```

### 可用的 Lua 标准库

出于安全考虑，插件只能使用以下 Lua 标准库：

| 库 | 说明 |
|------|------|
| `string` | 字符串操作 |
| `table` | 表操作 |
| `math` | 数学函数 |
| `tonumber` | 转换为数字 |
| `tostring` | 转换为字符串 |
| `type` | 获取类型 |
| `pairs` | 遍历表 |
| `ipairs` | 遍历数组 |
| `next` | 获取下一个键值对 |
| `select` | 选择参数 |
| `unpack` | 解包表 |
| `pcall` | 保护调用 |
| `xpcall` | 扩展保护调用 |
| `error` | 抛出错误 |
| `assert` | 断言 |
| `os.date` | 日期格式化 |

**不可用的库：**
- `io` - 文件操作
- `os` - 系统操作（除 `os.date`）
- `debug` - 调试库
- `loadfile` / `dofile` - 加载文件
- `require` - 模块加载

---

## 生命周期钩子

插件可以定义以下生命周期回调函数，这些函数会在特定事件发生时自动调用：

```lua
local plugin = {}

function plugin.onLoad()
    -- 插件加载时调用
    -- 每次应用启动时都会调用
    -- 适合进行初始化操作
end

function plugin.onEnable()
    -- 插件启用时调用
    -- 每次用户启用插件时调用
    -- 适合启动功能、注册事件等
end

function plugin.onDisable()
    -- 插件禁用时调用
    -- 每次用户禁用插件时调用
    -- 适合清理资源、保存状态等
end

function plugin.onUnload()
    -- 插件卸载时调用
    -- 仅在插件被删除时调用
    -- 适合最终清理操作
end

return plugin
```

### 调用顺序

1. `onLoad()` - 插件首次加载（应用启动时）
2. `onEnable()` - 插件被启用（用户启用插件时）
3. `onDisable()` - 插件被禁用（用户禁用插件时）
4. `onUnload()` - 插件被卸载（插件被删除时）

### 示例插件

```lua
-- main.lua
local plugin = {}

function plugin.onLoad()
    sl.log.info("Hello World 插件已加载！")
    
    -- 测试存储 API
    local count = sl.storage.get("load_count")
    if count == nil then
        count = 0
    end
    count = count + 1
    sl.storage.set("load_count", count)
    sl.log.info("此插件已被加载 " .. tostring(count) .. " 次")
end

function plugin.onEnable()
    sl.log.info("Hello World 插件已启用！")
    
    -- 存储启用时间戳
    sl.storage.set("last_enabled", os.date("%Y-%m-%d %H:%M:%S"))
    
    -- 读取并记录
    local last = sl.storage.get("last_enabled")
    sl.log.info("启用于: " .. tostring(last))
    
    -- 测试存储键
    local keys = sl.storage.keys()
    sl.log.debug("存储键: " .. table.concat(keys, ", "))
end

function plugin.onDisable()
    sl.log.warn("Hello World 插件正在被禁用")
    sl.storage.set("last_disabled", os.date("%Y-%m-%d %H:%M:%S"))
end

function plugin.onUnload()
    sl.log.info("Hello World 插件已卸载。再见！")
end

return plugin
```

---

## CSS 注入

插件可以通过 `style.css` 文件注入自定义样式。当插件启用时，CSS 会自动注入到应用中；禁用时会自动移除。

### 创建 style.css

在插件目录下创建 `style.css` 文件：

```css
/*
 * SeaLantern 插件自定义样式
 * 这个 CSS 会在插件启用时自动注入到应用中
 */

/* 使用应用提供的 CSS 变量 */
.plugin-card {
    background: var(--bg-secondary);
    border: 1px solid var(--sl-border);
    border-radius: var(--sl-radius-md);
    padding: var(--sl-space-md);
}

.plugin-button {
    background: var(--sl-primary);
    color: white;
    border: none;
    border-radius: var(--sl-radius-sm);
    padding: 8px 16px;
    cursor: pointer;
    transition: all var(--sl-transition-fast);
}

.plugin-button:hover {
    background: var(--sl-primary-dark);
}

/* 使用插件 ID 作为前缀以避免冲突 */
.theme-palette-preview {
    border-left: 3px solid var(--sl-primary);
    padding-left: var(--sl-space-sm);
}
```

### 可用的 CSS 变量

应用提供了以下 CSS 变量供插件使用：

**颜色变量：**

| 变量 | 说明 |
|------|------|
| `--sl-bg` | 主背景色 |
| `--sl-bg-secondary` | 次要背景色 |
| `--sl-bg-tertiary` | 三级背景色 |
| `--sl-surface` | 表面色 |
| `--sl-surface-hover` | 表面悬停色 |
| `--sl-border` | 边框颜色 |
| `--sl-border-light` | 浅色边框 |

**文字颜色：**

| 变量 | 说明 |
|------|------|
| `--sl-text-primary` | 主文字颜色 |
| `--sl-text-secondary` | 次要文字颜色 |
| `--sl-text-tertiary` | 三级文字颜色 |
| `--sl-text-inverse` | 反色文字 |

**强调色：**

| 变量 | 说明 |
|------|------|
| `--sl-primary` | 主强调色 |
| `--sl-primary-light` | 浅主强调色 |
| `--sl-primary-dark` | 深主强调色 |
| `--sl-primary-bg` | 主强调色背景 |
| `--sl-accent` | 辅助强调色 |
| `--sl-accent-light` | 浅辅助强调色 |
| `--sl-success` | 成功色 |
| `--sl-warning` | 警告色 |
| `--sl-error` | 错误色 |
| `--sl-info` | 信息色 |

**阴影：**

| 变量 | 说明 |
|------|------|
| `--sl-shadow-sm` | 小阴影 |
| `--sl-shadow-md` | 中等阴影 |
| `--sl-shadow-lg` | 大阴影 |
| `--sl-shadow-xl` | 超大阴影 |

**圆角：**

| 变量 | 说明 |
|------|------|
| `--sl-radius-sm` | 小圆角 |
| `--sl-radius-md` | 中等圆角 |
| `--sl-radius-lg` | 大圆角 |
| `--sl-radius-xl` | 超大圆角 |
| `--sl-radius-full` | 完全圆角（圆形） |

**间距：**

| 变量 | 说明 |
|------|------|
| `--sl-space-xs` | 超小间距（4px） |
| `--sl-space-sm` | 小间距（8px） |
| `--sl-space-md` | 中等间距（16px） |
| `--sl-space-lg` | 大间距（24px） |
| `--sl-space-xl` | 超大间距（32px） |
| `--sl-space-2xl` | 双倍超大间距（48px） |

**布局：**

| 变量 | 说明 |
|------|------|
| `--sl-sidebar-width` | 侧边栏宽度（240px） |
| `--sl-sidebar-collapsed-width` | 侧边栏折叠宽度（64px） |
| `--sl-header-height` | 头部高度（48px） |

**过渡：**

| 变量 | 说明 |
|------|------|
| `--sl-transition-fast` | 快速过渡（0.15s） |
| `--sl-transition-normal` | 正常过渡（0.25s） |
| `--sl-transition-slow` | 慢速过渡（0.4s） |

### CSS 注入注意事项

1. **使用特定选择器**：避免使用过于通用的选择器（如 `div`、`span`），以免影响其他插件或应用本身
2. **添加前缀**：建议为自定义类名添加插件 ID 前缀，如 `.my-plugin-xxx`
3. **避免 !important**：尽量不使用 `!important`，以便用户可以覆盖样式
4. **测试兼容性**：确保样式在不同主题下都能正常显示
5. **考虑响应式**：确保样式在不同屏幕尺寸下都能正常显示

---

## 设置系统

插件可以在 manifest.json 中定义设置项，系统会自动生成设置界面。设置值会自动保存到 `settings.json` 文件中。

### 设置值存储

设置值存储在插件目录下的 `settings.json` 文件中，格式如下：

```json
{
  "greeting": "Hello World",
  "max_count": 20,
  "enabled": false,
  "theme": "dark"
}
```

### 在 Lua 中读取设置

设置值可以通过 storage API 读取：

```lua
local greeting = sl.storage.get("greeting") or "Hello"
local enabled = sl.storage.get("enabled") or false

if enabled then
    sl.log.info("功能已启用")
else
    sl.log.info("功能已禁用")
end
```

### 设置界面

当插件启用时，系统会根据 manifest.json 中的 `settings` 字段自动生成设置界面。用户可以在插件页面中修改这些设置。

### theme-palette 插件示例

Theme Palette 插件使用复杂的设置系统，包括：
- 颜色输入（使用文本框 + 颜色选择器）
- 预设主题选择
- 实时预览功能

你可以参考 `theme-palette` 插件的实现来创建更复杂的设置界面。

---

## 侧边栏导航

插件可以在侧边栏中添加导航项，方便用户快速访问插件功能。

### 配置侧边栏

在 `manifest.json` 中配置 `ui.sidebar`：

```json
{
  "id": "my-plugin",
  "ui": {
    "sidebar": {
      "label": "我的插件",
      "icon": "puzzle",
      "group": "system",
      "priority": 50
    }
  }
}
```

### 侧边栏导航项

插件的主入口文件会自动映射到侧边栏导航项。导航项会显示在侧边栏的"系统"分组中，位于"插件市场"之后。

### 配置分组

侧边栏导航项可以分组显示：

| 分组 | 说明 |
|------|------|
| `main` | 通用功能（首页、创建服务器） |
| `server` | 服务器功能（控制台、配置编辑、玩家管理） |
| `system` | 系统功能（插件、设置、关于） |

### 优先级

可以通过 `priority` 控制导航项的显示顺序。数字越小，越靠前显示。

---

## 独立页面

插件可以定义独立的设置页面，提供丰富的配置界面。

### 配置独立页面

在 `manifest.json` 中配置 `ui.pages`：

```json
{
  "id": "my-plugin",
  "ui": {
    "pages": [
      {
        "id": "settings",
        "title": "设置",
        "path": "settings",
        "icon": "settings"
      },
      {
        "id": "about",
        "title": "关于",
        "path": "about",
        "icon": "info"
      }
    ]
  }
}
```

### 页面访问

独立页面可以通过以下 URL 访问：
- `/plugin/{pluginId}` - 主页面
- `/plugin/{pluginId}/{pageId}` - 特定页面

例如，对于插件 ID 为 `theme-palette` 的插件：
- `/plugin/theme-palette` - 主设置页面
- `/plugin/theme-palette/settings` - 设置页面
- `/plugin/theme-palette/about` - 关于页面

### 页面内容

插件的独立页面会自动包含以下功能：
- 插件信息卡片
- 设置表单（基于 `settings` 字段自动生成）
- 保存/重置按钮
- 实时预览（如 Theme Palette 的主题预览）

### theme-palette 示例

Theme Palette 插件展示了如何创建复杂的独立页面：
- 预设主题选择
- 颜色设置（文本输入 + 颜色选择器）
- 效果设置（毛玻璃模糊、圆角）
- 实时预览（修改立即生效）

---

## 插件市场

SeaLantern 提供了一个插件市场，用户可以从市场安装和更新插件。

### 市场 API 结构

**基础 URL：**
```
https://sealanternpluginmarket.little100.top
```

**市场元信息（GET /api/market.json）：**

```json
{
  "name": "SeaLantern Plugin Market",
  "version": "1.0.0",
  "api_version": "1",
  "base_url": "https://sealanternpluginmarket.little100.top",
  "total_plugins": 2,
  "updated_at": "2025-01-01T00:00:00Z"
}
```

**插件列表（GET /api/plugins.json）：**

```json
{
  "plugins": [
    {
      "id": "hello-world",
      "name": "Hello World",
      "version": "1.0.0",
      "description": "A simple test plugin for SeaLantern",
      "author": {
        "name": "Little_100",
        "url": "https://github.com/Little-100"
      },
      "download_url": "https://sealanternpluginmarket.little100.top/downloads/hello-world-1.0.0.zip",
      "icon_url": "https://sealanternpluginmarket.little100.top/icons/hello-world.png",
      "tags": ["utility", "example"],
      "created_at": "2025-01-01",
      "updated_at": "2025-01-01"
    }
  ],
  "total": 2,
  "updated_at": "2025-01-01T00:00:00Z"
}
```

**插件详情（GET /api/plugins/{id}.json）：**

```json
{
  "id": "theme-palette",
  "name": "Theme Palette",
  "version": "1.0.0",
  "description": "A visual CSS theme editor for SeaLantern",
  "long_description": "Detailed description...",
  "author": {
    "name": "Little_100",
    "url": "https://github.com/Little-100"
  },
  "download_url": "https://sealanternpluginmarket.little100.top/downloads/theme-palette-1.0.0.zip",
  "icon_url": "https://sealanternpluginmarket.little100.top/icons/theme-palette.png",
  "tags": ["theme", "ui"],
  "changelog": "## v1.0.0\n- Initial release",
  "min_app_version": "1.0.0",
  "permissions": ["log", "storage"],
  "versions": [
    {
      "version": "1.0.0",
      "download_url": "https://sealanternpluginmarket.little100.top/downloads/theme-palette-1.0.0.zip",
      "changelog": "Initial release",
      "released_at": "2025-01-01"
    }
  ],
  "created_at": "2025-01-01",
  "updated_at": "2025-01-01"
}
```

### 从市场安装插件

1. 在应用中打开"插件市场"
2. 浏览或搜索插件
3. 点击"安装"按钮
4. 插件会自动下载并安装到本地

### 更新插件

市场会自动检查插件更新。当有新版本可用时，会在插件卡片上显示"更新"按钮。

---

## 最佳实践

### 1. 插件 ID 命名

- 使用小写字母、数字和连字符
- 避免使用特殊字符和空格
- 建议格式：`author-plugin-name` 或 `plugin-name`

```
OK 推荐: my-awesome-plugin, hello-world
X 避免: My_Plugin!, plugin.name, my plugin
```

### 2. 版本管理

使用语义化版本号 (Semantic Versioning)：

- `MAJOR.MINOR.PATCH`
- MAJOR: 不兼容的 API 变更
- MINOR: 向后兼容的功能新增
- PATCH: 向后兼容的问题修复

### 3. 错误处理

```lua
local plugin = {}

function plugin.onEnable()
    local success, err = pcall(function()
        -- 可能出错的代码
        local data = loadConfiguration()
        sl.storage.set("config", data)
    end)
    
    if not success then
        sl.log.error("初始化失败: " .. tostring(err))
        -- 保存错误状态
        sl.storage.set("last_error", tostring(err))
    end
end

return plugin
```

### 4. 资源清理

在 `onDisable` 中清理资源：

```lua
function plugin.onDisable()
    -- 保存状态
    sl.storage.set("last_state", "disabled")
    
    -- 清理临时数据
    sl.storage.remove("temp_data")
    
    sl.log.info("插件已禁用，资源已清理")
end
```

### 5. CSS 样式隔离

```css
/* 使用插件 ID 作为前缀 */
.my-plugin-container {
    /* 样式 */
}

.my-plugin-button {
    /* 样式 */
}

/* 避免全局选择器 */
/* X 不推荐 */
div {
    color: red;
}

/* OK 推荐 */
.my-plugin-container div {
    color: red;
}
```

### 6. 设置项设计

- 提供合理的默认值
- 添加清晰的描述
- 使用合适的类型
- 避免过多设置项（建议不超过 10 个）
- 对于颜色等设置，提供实时预览

### 7. 文档编写

- 为插件编写清晰的 README.md
- 说明插件的功能和使用方法
- 提供配置示例
- 记录已知问题和限制

### 8. 性能优化

- 避免在 `onLoad` 中执行耗时操作
- 使用 `pcall` 包装可能出错的代码
- 及时清理不再需要的数据
- 避免频繁的存储操作

### 9. 兼容性考虑

- 考虑不同 SeaLantern 版本的兼容性
- 在 manifest.json 中指定最低版本要求
- 测试插件在不同环境下的表现
- 避免依赖未公开的 API

---

## 示例插件

### 最小插件

```lua
-- main.lua
local plugin = {}

function plugin.onEnable()
    sl.log.info("Hello from my plugin!")
end

return plugin
```

```json
{
  "id": "minimal-plugin",
  "name": "Minimal Plugin",
  "version": "1.0.0",
  "description": "A minimal plugin",
  "author": { "name": "Author" },
  "main": "main.lua",
  "permissions": ["log"]
}
```

### 带设置的插件

```lua
-- main.lua
local plugin = {}

function plugin.onEnable()
    local greeting = sl.storage.get("greeting") or "Hello"
    sl.log.info(greeting .. ", SeaLantern!")
end

return plugin
```

```json
{
  "id": "greeting-plugin",
  "name": "Greeting Plugin",
  "version": "1.0.0",
  "description": "A plugin with settings",
  "author": { "name": "Author" },
  "main": "main.lua",
  "permissions": ["log", "storage"],
  "settings": [
    {
      "key": "greeting",
      "label": "Greeting",
      "type": "string",
      "default": "Hello",
      "description": "The greeting message"
    }
  ]
}
```

### 带侧边栏和独立页面的插件

```lua
-- main.lua
local plugin = {}

function plugin.onLoad()
    sl.log.info("主题调色板插件已加载")
end

function plugin.onEnable()
    sl.log.info("主题调色板插件已启用")
end

return plugin
```

```json
{
  "id": "theme-palette",
  "name": "Theme Palette",
  "version": "1.0.0",
  "description": "Visual CSS theme editor for SeaLantern",
  "author": {
    "name": "Little_100",
    "url": "https://github.com/Little-100"
  },
  "main": "main.lua",
  "icon": "icon.png",
  "permissions": ["log", "storage"],
  "ui": {
    "sidebar": {
      "label": "主题调色板",
      "icon": "palette",
      "priority": 50
    }
  },
  "settings": [
    {
      "key": "bg_primary",
      "label": "Primary Background",
      "type": "string",
      "default": "#0a0a0f",
      "description": "Main background color"
    },
    {
      "key": "preset",
      "label": "Color Preset",
      "type": "select",
      "default": "default",
      "description": "Quick apply a color preset",
      "options": [
        { "value": "default", "label": "Default (Dark Blue)" },
        { "value": "midnight", "label": "Midnight Purple" },
        { "value": "forest", "label": "Forest Green" }
      ]
    }
  ]
}
```

---

## 更新记录

### v1.2.0
- 新增 `execute_program` 权限和 `sl.process` 命名空间，支持在插件目录内执行外部程序
- 新增 `plugin_folder_access` 权限和 `sl.plugins` 命名空间，支持跨插件文件夹读写
- 权限系统新增危险等级分类：普通、危险、极度危险
- 插件禁用时自动终止所有由该插件启动的子进程

### v1.1.0
- 设置系统新增 `textarea` 类型（多行文本输入），支持 `rows` 和 `maxlength` 属性
- 设置系统新增 `checkbox` 类型（复选框），与 `boolean`（开关）互为补充

### v1.0.0
- 初始版本
- 支持插件目录结构
- 支持 manifest.json 配置
- 支持 Lua API（log, storage）
- 支持生命周期钩子
- 支持 CSS 注入
- 支持设置系统
- 支持侧边栏导航
- 支持插件市场
