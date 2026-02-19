# SeaLantern 插件市场 API

## 概述

插件市场数据通过静态 JSON 文件提供，可通过 GitHub Pages / 任意静态服���器远程访问。

**基础 URL**: `https://<username>.github.io/<repository>`

例如: `https://little100.github.io/sealantern-plugin-market`

---

## API 端点

### 1. 获取所有插件（推荐）

```
GET /api/plugins.json
```

**响应**:
```json
{
  "plugins": [
    {
      "id": "hello-world",
      "category": "demo",
      "name": { "zh-CN": "Hello World", "en-US": "Hello World" },
      "description": { "zh-CN": "示例插件", "en-US": "Example plugin" },
      "author": { "name": "Little_100", "url": "https://github.com/Little100" },
      "github": "Little100/sealantern-hello-world",
      "permissions": ["log", "storage"],
      "icon_url": "icon.png"
    }
  ],
  "total": 1,
  "updated_at": "2026-01-01T00:00:00Z"
}
```

> `api/plugins.json` 是静态文件，由本仓库的 `plugins/<category>/*.json` 本地扫描生成。
> - 本地：执行 `npm run build`
> - GitHub Pages：直接访问 `/api/plugins.json`

---

### 2. 获取分类列表

```
GET /api/categories.json
```

**响应**:
```json
{
  "demo": "示例插件",
  "theme": "主题美化",
  "ui": "界面增强"
}
```

---

## 目录结构

```
plugin-market/
├── index.html
├── style.css
├── script.js
├── API.md
├── example-plugin.json
├── api/
│   ├── categories.json     # 分类映射（手动维护）
│   └── plugins.json        # 本地 build 自动生成（提交到仓库给 Pages 访问）
├── scripts/
│   └── build.js            # 扫描 plugins/ 并生成 api/plugins.json
└── plugins/
    ├── demo/
    │   ├── hello-world.json
    │   └── ...
    ├── theme/
    │   └── ...
    └── ui/
        └── ...
```

---

## 插件 JSON 字段

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | string | 是 | 插件唯一标识 |
| `category` | string | 是 | 分类文件夹名（由 build 自动补充） |
| `name` | object | 是 | 名称，支持 i18n |
| `description` | object | 否 | 描述，支持 i18n |
| `author.name` | string | 是 | 作者名称 |
| `author.url` | string | 否 | 作者主页 |
| `github` | string | 否 | GitHub 仓库 |
| `permissions` | string[] | 否 | 所需权限 |
| `icon_url` | string | 否 | 图标文件名（相对插件 JSON 所在目录） |

### i18n 格式

```json
{
  "name": {
    "zh-CN": "中文名称",
    "en-US": "English Name"
  }
}
```

---

## 添加新插件

1. 在 `plugins/<category>/` 创建 `<plugin-id>.json`
2. 运行 `npm run build` 生成/更新 `api/plugins.json`
3. 提交并推送到 GitHub，GitHub Pages 将自动提供最新的 `/api/plugins.json`

---

## 本地开发

```bash
npm install
npm run dev
```

- `npm run dev` 会先执行 `npm run build`，再启动本地静态服务器。
