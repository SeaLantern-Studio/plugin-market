# SeaLantern 插件模板

这是一个 SeaLantern 插件的模板项目，包含了创建插件所需的所有基础文件和示例代码。

## 快速开始

1. 复制整个 `plugin-template` 目录到 `plugins` 文件夹
2. 重命名目录为你的插件名称
3. 修改 `manifest.json` 中的插件信息
4. 在 `main.lua` 中编写插件逻辑
5. 可选：添加 `icon.png` 图标
6. 可选：添加 `style.css` 自定义样式

## 新增功能

### UI 控制 API (sl.ui)

新增了 UI 控制 API，允许插件操作应用界面元素：

- `sl.ui.hide(selector)` - 隐藏元素
- `sl.ui.show(selector)` - 显示元素
- `sl.ui.disable(selector)` - 禁用元素
- `sl.ui.enable(selector)` - 启用元素
- `sl.ui.insert(placement, selector, html)` - 插入 HTML
- `sl.ui.remove(selector)` - 移除插件插入的元素
- `sl.ui.set_style(selector, styles)` - 设置样式
- `sl.ui.set_attribute(selector, attr, value)` - 设置属性
- `sl.ui.query(selector)` - 查询元素信息

使用这些 API 需要在 manifest.json 中声明 `ui` 权限。

### 元素交互 API (sl.element)

新增了元素交互 API，允许插件读取元素内容和模拟用户交互：

- `sl.element.get_text(selector)` - 获取元素文本
- `sl.element.get_value(selector)` - 获取表单值
- `sl.element.get_attribute(selector, attr)` - 获取属性
- `sl.element.get_attributes(selector)` - 获取所有属性
- `sl.element.click(selector)` - 点击元素
- `sl.element.set_value(selector, value)` - 设置表单值
- `sl.element.check(selector, checked)` - 设置复选框状态
- `sl.element.select(selector, value)` - 选择下拉框选项
- `sl.element.focus(selector)` / `blur(selector)` - 聚焦/取消聚焦
- `sl.element.on_change(selector, callback)` - 监听值变化

使用这些 API 需要在 manifest.json 中声明 `element` 权限。

### 权限系统变更

- 新增 `ui` 权限：允许使用 UI 控制 API
- 新增 `element` 权限：允许使用元素交互 API
- 所有 API 调用和命令执行现在会被追踪并显示在权限信息面板中
- 用户可以在插件卡片上查看插件的实际行为记录

### 可用权限列表

| 权限 | 说明 |
|------|------|
| `log` | 日志 API (sl.log) |
| `storage` | 存储 API (sl.storage) |
| `ui` | UI 控制 API (sl.ui) |
| `element` | 元素交互 API (sl.element) |
| `console` | 服务器控制台命令 |
| `fs` | 文件系统访问 |
| `api` | 外部 API 调用 |

详细 API 文档请参阅 [API.md](./API.md)。

## 目录结构

```
my-plugin/
├── manifest.json      # 必需 - 插件配置文件
├── main.lua           # 必需 - 插件主入口文件
├── icon.png           # 可选 - 插件图标
├── style.css          # 可选 - 自定义样式
├── API.md             # API 文档
└── README.md          # 说明文档
```

### 自动生成文件

以下文件会在插件首次运行时自动生成：

```
settings.json         # 存储用户设置值
storage.json          # 存储插件数据
```

## 文件说明

### manifest.json

插件的核心配置文件，定义了：

- **基本消息**：id, name, version, description, author
- **入口信息**：main - 主入口 Lua 文件
- **图标信息**：icon - 插件图标文件
- **权限声明**：permissions - 插件需要的权限列表
- **依赖关系**：dependencies - 其他插件依赖
- **设置定义**：settings - 插件设置项的配置
- **UI 配置**：ui - 侧边栏、独立页面和上下文菜单

**重要字段说明：**

**id**：插件唯一标识符
- 必须唯一
- 建议使用小写字母、数字和连字符
- 格式：`plugin-name` 或 `author-plugin-name`

**icon**：插件图标
- 支持格式：png, jpg, gif, webp, svg, ico, bmp
- 必须为正方形
- 建议大小：64x64 或 128x128 像素
- 最大尺寸：2048x2048 像素

**settings**：插件设置项配置
- 自动生成设置界面
- 支持多种类型：string, number, boolean, select
- 设置值存储在 `settings.json` 文件

**ui.sidebar**：侧边栏导航配置
- 在侧边栏添加导航项
- 显示在"系统"分组中

**ui.pages**：独立页面配置
- 定义插件的独立设置页面
- 通过 URL 访问：`/plugin/{pluginId}`

**示例 manifest.json：**

```json
{
  "id": "my-plugin",
  "name": "My Plugin",
  "version": "1.0.0",
  "description": "A SeaLantern plugin",
  "author": {
    "name": "Your Name",
    "url": "https://github.com/yourname"
  },
  "main": "main.lua",
  "icon": "icon.png",
  "permissions": ["log", "storage"],
  "settings": [
    {
      "key": "greeting",
      "label": "Greeting Message",
      "type": "string",
      "default": "Hello, SeaLantern!",
      "description": "The greeting message to display"
    },
    {
      "key": "enabled",
      "label": "Enable Feature",
      "type": "boolean",
      "default": true,
      "description": "Whether to enable this feature"
    }
  ],
  "ui": {
    "sidebar": {
      "label": "My Plugin",
      "icon": "puzzle",
      "priority": 100
    }
  }
}
```

### main.lua

插件的主入口文件，包含生命周期回调函数。

**生命周期函数：**

- `onLoad()` - 插件加载时调用（每次启动应用时调用）
- `onEnable()` - 插件启用时调用（用户启用插件时调用）
- `onDisable()` - 插件禁用时调用（用户禁用插件时调用）
- `onUnload()` - 插件卸载时调用（插件被删除时调用）

**示例 main.lua：**

```lua
-- Hello World Plugin for SeaLantern
local plugin = {}

function plugin.onLoad()
    sl.log.info("Hello World plugin loaded!")
    
    -- 测试存储 API
    local count = sl.storage.get("load_count")
    if count == nil then
        count = 0
    end
    count = count + 1
    sl.storage.set("load_count", count)
    sl.log.info("This plugin has been loaded " .. tostring(count) .. " time(s)")
end

function plugin.onEnable()
    sl.log.info("Hello World plugin enabled!")
    
    -- Store enable timestamp
    sl.storage.set("last_enabled", os.date("%Y-%m-%d %H:%M:%S"))
    
    -- Read back and log
    local last = sl.storage.get("last_enabled")
    sl.log.info("Enabled at: " .. tostring(last))
    
    -- Test storage keys
    local keys = sl.storage.keys()
    sl.log.debug("Storage keys: " .. table.concat(keys, ", "))
end

function plugin.onDisable()
    sl.log.warn("Hello World plugin is being disabled")
    sl.storage.set("last_disabled", os.date("%Y-%m-%d %H:%M:%S"))
end

function plugin.onUnload()
    sl.log.info("Hello World plugin unloaded. Goodbye!")
end

return plugin
```

### icon.png

插件图标文件，显示在插件卡片和侧边栏中。

**规格要求：**
- 支持格式：png, jpg, gif, webp, svg, ico, bmp
- 必须为正方形（宽高相等）
- 建议大小：64x64 或 128x128 像素
- 最大尺寸：2048x2048 像素
- 建议使用白色或浅色背景

### style.css

自定义 CSS 样式文件。当插件启用时，样式会自动注入到应用中。

**使用方法：**
1. 在 `style.css` 文件中编写样式
2. 启用插件后，CSS 会自动注入
3. 禁用插件后，CSS 会自动移除

**示例 style.css：**

```css
/*
 * SeaLantern 插件自定义样式
 */

/* 使用插件 ID 作为前缀以避免冲突 */
.my-plugin-container {
    /* 样式 */
}

.my-plugin-button {
    background: var(--sl-primary);
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: var(--sl-radius-sm);
    cursor: pointer;
}

.my-plugin-button:hover {
    background: var(--sl-primary-dark);
}
```

**可用 CSS 变量：**
- `--sl-bg`, `--sl-bg-secondary`, `--sl-bg-tertiary`
- `--sl-text-primary`, `--sl-text-secondary`, `--sl-text-tertiary`
- `--sl-primary`, `--sl-primary-light`, `--sl-primary-dark`
- `--sl-accent`
- `--sl-border`, `--sl-border-light`
- `--sl-success`, `--sl-warning`, `--sl-error`, `--sl-info`
- `--sl-shadow-sm`, `--sl-shadow-md`, `--sl-shadow-lg`, `--sl-shadow-xl`
- `--sl-radius-sm`, `--sl-radius-md`, `--sl-radius-lg`, `--sl-radius-xl`
- `--sl-space-xs`, `--sl-space-sm`, `--sl-space-md`, `--sl-space-lg`, `--sl-space-xl`
- `--sl-transition-fast`, `--sl-transition-normal`, `--sl-transition-slow`

## API

插件可以通过 `sl` 全局对象访问 API。

### 日志 API

```lua
sl.log.debug(message)   -- 调试日志
sl.log.info(message)    -- 信息日志
sl.log.warn(message)    -- 警告日志
sl.log.error(message)   -- 错误日志
```

所有日志都会自动添加插件 ID 前缀。

### 存储 API

```lua
sl.storage.get(key)        -- 获取存储值（支持 string, number, boolean, table）
sl.storage.set(key, value) -- 设置存储值
sl.storage.remove(key)     -- 删除存储值
sl.storage.keys()          -- 获取所有键
```

**存储值格式：**
- 自动保存为 JSON 格式
- 存储在 `storage.json` 文件中
- 支持多种数据类型

### 设置系统

```lua
-- 从 storage 获取设置值
local greeting = sl.storage.get("greeting") or "Hello"
local enabled = sl.storage.get("enabled") or false
```

**配置设置项：**
在 `manifest.json` 中的 `settings` 数组中定义设置项。

**示例：**
```json
{
  "settings": [
    {
      "key": "greeting",
      "label": "Greeting Message",
      "type": "string",
      "default": "Hello, SeaLantern!",
      "description": "The greeting message to display"
    },
    {
      "key": "max_count",
      "label": "Maximum Count",
      "type": "number",
      "default": 10,
      "description": "Maximum number of items"
    },
    {
      "key": "enabled",
      "label": "Enable Feature",
      "type": "boolean",
      "default": true,
      "description": "Whether to enable this feature"
    },
    {
      "key": "theme",
      "label": "Theme",
      "type": "select",
      "default": "light",
      "description": "Select theme",
      "options": [
        { "value": "light", "label": "Light Mode" },
        { "value": "dark", "label": "Dark Mode" },
        { "value": "auto", "label": "Auto" }
      ]
    }
  ]
}
```

**设置类型：**

| 类型 | 说明 | 示例 |
|------|------|------|
| `string` | 文本输入 | 用户名、问候语 |
| `number` | 数字输入 | 数量、大小 |
| `boolean` | 开关 | 启用/禁用 |
| `select` | 下拉选择 | 主题、语言 |

### 全局变量

插件运行时自动注入的全局变量：

| 变量 | 类型 | 说明 |
|------|------|------|
| `PLUGIN_ID` | string | 当前插件的 ID |
| `PLUGIN_DIR` | string | 插件目录的绝对路径 |

## 生命周期

插件通过生命周期函数响应不同的事件。

### 调用顺序

1. **onLoad()** - 插件加载时
   - 每次应用启动时都会调用
   - 适合进行初始化操作
   - 可以读取存储数据

2. **onEnable()** - 插件启用时
   - 用户启用插件时调用
   - 适合启动功能、注册事件
   - 可以访问 API

3. **onDisable()** - 插件禁用时
   - 用户禁用插件时调用
   - 适合清理资源
   - 可以保存状态

4. **onUnload()** - 插件卸载时
   - 插件被删除时调用
   - 适合最终清理
   - 仅调用一次

### 示例：完整的生命周期

```lua
local plugin = {}

function plugin.onLoad()
    sl.log.info("插件开始加载")
    
    -- 读取并更新加载次数
    local loadCount = sl.storage.get("load_count") or 0
    sl.storage.set("load_count", loadCount + 1)
    
    sl.log.info("这是第 " .. tostring(loadCount + 1) .. " 次加载")
end

function plugin.onEnable()
    sl.log.info("插件已启用")
    
    -- 启用时间戳
    sl.storage.set("last_enabled", os.date("%Y-%m-%d %H:%M:%S"))
    
    -- 检查需要的设置
    local greeting = sl.storage.get("greeting") or "Hello"
    sl.log.info("问候语: " .. greeting)
end

function plugin.onDisable()
    sl.log.warn("插件正在被禁用")
    
    -- 保存禁用时间
    sl.storage.set("last_disabled", os.date("%Y-%m-%d %H:%M:%S"))
    
    -- 清理临时数据
    sl.storage.remove("temp_data")
end

function plugin.onUnload()
    sl.log.info("插件已卸载，再见！")
    
    -- 可以选择保留或删除所有数据
    -- sl.storage.remove("load_count")
    -- sl.storage.remove("last_enabled")
end

return plugin
```

## 侧边栏导航

在 `manifest.json` 中配置 `ui.sidebar` 可以在侧边栏添加导航项：

```json
{
  "ui": {
    "sidebar": {
      "label": "我的插件",
      "icon": "puzzle",
      "group": "system",
      "priority": 100
    }
  }
}
```

**注意：**
- 导航项会自动显示在侧边栏的"系统"分组中
- 位于"插件市场"之后
- 可以通过 `priority` 控制显示顺序

## 独立页面

在 `manifest.json` 中配置 `ui.pages` 可以创建独立的设置页面：

```json
{
  "ui": {
    "pages": [
      {
        "id": "settings",
        "title": "设置",
        "path": "settings",
        "icon": "settings"
      }
    ]
  }
}
```

访问独立页面：
- 主页面：`/plugin/{pluginId}`
- 独立页面：`/plugin/{pluginId}/{pageId}`

## 插件市场

插件可以通过插件市场发布和分发。

**市场 API：**
- 基础 URL：`https://sealanternpluginmarket.little100.top`
- 插件列表：`/api/plugins.json`
- 插件详情：`/api/plugins/{id}.json`

**发布插件：**
1. 将插件打包为 ZIP 文件
2. 将文件上传到市场
3. 配置市场 API 文件
4. 提交审核

详细信息请参考 [插件市场 README](../../plugin-market/README.md)。

## 环境限制

出于安全考虑，插件运行在沙箱环境中，以下功能受限：

**可用的 Lua 标准库：**
- `string` - 字符串操作
- `table` - 表操作
- `math` - 数学函数
- `tonumber`, `tostring` - 类型转换
- `type`, `pairs`, `ipairs` - 类型和遍历
- `pcall`, `xpcall` - 错误处理
- `error`, `assert` - 错误处理

**不可用的功能：**
- 文件系统操作（`io`, `os.execute`）
- 网络请求
- 系统命令执行
- 加载外部库

这确保了插件的安全性，避免恶意代码的执行。

## 全局变量

在插件运行时，以下全局变量会自动注入：

| 变量 | 类型 | 说明 |
|------|------|------|
| `PLUGIN_ID` | string | 当前插件的 ID |
| `PLUGIN_DIR` | string | 插件目录的绝对路径 |

```lua
-- 使用 PPLUGIN_ID 进行日志前缀
sl.log.info("[" .. PLUGIN_ID .. "] 插件信息")

-- 使用 PLUGIN_DIR 访问资源
local resourcePath = PLUGIN_DIR .. "/resources"
```

## 错误处理

建议使用 `pcall` 进行错误处理：

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
        sl.storage.set("last_error", tostring(err))
    end
end

return plugin
```

## CSS 最佳实践

在 `style.css` 中，遵循以下最佳实践：

1. **使用插件 ID 作为前缀**：
   ```css
   /* 推荐 */
   .my-plugin-container { }
   .my-plugin-button { }
   
   /* 不推荐 */
   .container { }
   ```

2. **使用 CSS 变量**：
   ```css
   .my-plugin-card {
       background: var(--sl-bg-secondary);
       border: 1px solid var(--sl-border);
       border-radius: var(--sl-radius-md);
       padding: var(--sl-space-md);
   }
   ```

3. **避免 !important**：
   ```css
   /* 不推荐 */
   .my-plugin-button {
       background: red !important;
   }
   
   /* 推荐 */
   .my-plugin-button {
       background: red;
       background: var(--sl-primary);
   }
   ```

4. **考虑响应式**：
   ```css
   .my-plugin-container {
       width: 100%;
       max-width: 600px;
       padding: var(--sl-space-md);
   }
   
   @media (max-width: 768px) {
       .my-plugin-container {
           padding: var(--sl-space-sm);
       }
   }
   ```

## 设置系统最佳实践

1. **提供合理的默认值**：用户安装插件后应该能立即使用
2. **添加清晰的描述**：帮助用户理解每个设置项的作用
3. **使用合适的类型**：
   - 颜色值使用 `string` 类型
   - 数量使用 `number` 类型
   - 开关使用 `boolean` 类型
   - 选择使用 `select` 类型
4. **限制设置数量**：建议不超过 10 个设置项，避免用户困惑
5. **提供实时预览**：对于视觉相关的设置（如 Theme Palette），提供实时预览功能

## 常见问题

### 如何访问设置值？

```lua
local value = sl.storage.get("setting_key") or default_value
```

### 如何保存数据？

```lua
sl.storage.set("key", value)
```

### 插件图标支持哪些格式？

支持：png, jpg, gif, webp, svg, ico, bmp
- 必须为正方形
- 建议大小：64x64 或 128x128 像素

### 如何添加自定义样式？

创建 `style.css` 文件，插件启用时会自动注入。

### 如何处理错误？

使用 `pcall` 包装可能出错的代码，并记录错误日志。

### 插件安全吗？

是的，插件运行在沙箱环境中：
- 文件系统访问受限
- 不能执行系统命令
- 不能访问网络
- 不能加载外部库

## 下一步

1. **阅读 API 文档**：查看 [API.md](./API.md) 了解完整的 API 参考
2. **查看示例插件**：参考 `hello-world` 插件的实现
3. **测试插件**：在应用中安装和测试你的插件
4. **发布插件**：通过插件市场分享你的插件

## 示例插件

### Hello World 插件

最简单的插件示例：

```lua
-- main.lua
local plugin = {}

function plugin.onEnable()
    sl.log.info("Hello, SeaLantern!")
end

return plugin
```

**manifest.json:**
```json
{
  "id": "hello-world",
  "name": "Hello World",
  "version": "1.0.0",
  "description": "A simple test plugin",
  "author": { "name": "Your Name" },
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

**manifest.json:**
```json
{
  "id": "greeting-plugin",
  "name": "Greeting Plugin",
  "version": "1.0.0",
  "description": "A plugin with settings",
  "author": { "name": "Your Name" },
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

### 带侧边栏的插件

```lua
-- main.lua
local plugin = {}

function plugin.onEnable()
    sl.log.info("My Plugin 已启用")
end

return plugin
```

**manifest.json:**
```json
{
  "id": "my-plugin",
  "name": "My Plugin",
  "version": "1.0.0",
  "description": "A plugin with sidebar",
  "author": { "name": "Your Name" },
  "main": "main.lua",
  "icon": "icon.png",
  "permissions": ["log"],
  "ui": {
    "sidebar": {
      "label": "我的插件",
      "icon": "puzzle",
      "priority": 100
    }
  }
}
```

## 更多信息

- **API 参考**：查看 [API.md](./API.md) 了解详细的 API 文档
- **插件市场**：查看 [插件市场 README](../../plugin-market/README.md) 了解如何发布插件
- **示例插件**：查看 `hello-world` 和 `theme-palette` 插件的实现

## 许可证

MIT License

## 贡献

欢迎贡献！请提交 Pull Request 或创建 Issue。
