# SeaLantern Plugin Market

SeaLantern 插件市场的静态站点，用于展示和分发 SeaLantern 插件。

- [官方源: https://sealantern-studio.github.io/plugin-market/](https://sealantern-studio.github.io/plugin-market/)
- [官方镜像源: https://sealantern-studio.needhelp.icu/](https://sealantern-studio.needhelp.icu/)

## 核心思路

- 页面只访问 GitHub Pages 提供的静态 API：`/api/plugins.json`、`/api/categories.json`
- 不在浏览器里调用 GitHub API（避免 rate limit / CORS 问题）
- `api/plugins.json` 由 GitHub Actions 自动从 `plugins/<user>/<plugin-id>/` 扫描生成

---

## 添加新插件

1. 在 `plugins/<你的用户名>/<plugin-id>/` 创建 `<plugin-id>.json`
2. 提交并推送，GitHub Actions 会自动更新 `api/plugins.json`

参考 `example-plugin.json` 了解所有可用字段。

---

## 插件 JSON 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|:----:|------|
| `id` | string | ✅ | 插件唯一标识，只允许字母、数字、连字符、下划线 |
| `repo` | string | ✅ | 插件仓库。格式为 `"username/repo"`（GitHub）或 `"https://..."` / `"http://..."`（第三方）|
| `name` | i18n object | ✅ | 插件名称，支持多语言，见下方 i18n 格式 |
| `description` | i18n object | ❌ | 插件描述，支持多语言 |
| `version` | string | ❌ | 当前版本号，如 `"1.0.0"` |
| `author.name` | string | ❌ | 作者名称（不填时自动从路径推断为用户名） |
| `author.url` | string | ❌ | 作者主页 URL |
| `icon_url` | string | ❌ | 图标文件名，相对于插件 JSON 所在目录，如 `"icon.png"` |
| `categories` | string[] | ❌ | 分类列表，值对应 `api/categories.json` 中的 key |
| `permissions` | string[] | ❌ | 所需权限列表，见下方权限说明 |
| `dependencies` | string[] | ❌ | 必须依赖的插件，格式为 `"username/plugin-id"` |
| `optional_dependencies` | string[] | ❌ | 可选依赖，缺少时功能受限但仍可运行 |
| `download_url` | string | ❌ | 自定义下载链接（优先级高于 `repo`），必须是白名单域名 |
| `download_type` | `"release"` \| `"source"` | ❌ | GitHub 下载方式：`release`（Release 资产）或 `source`（源码 zip），默认 `source` |
| `release_asset` | string | ❌ | Release 资产文件名，仅 `download_type: "release"` 时有效 |
| `branch` | string | ❌ | 源码下载分支，仅 `download_type: "source"` 时有效，默认 `main` |
| `tags` | string[] | ❌ | 标签列表，用于搜索和筛选 |

### i18n 格式

```json
{
  "name": {
    "zh-CN": "中文名称",
    "en-US": "English Name"
  }
}
```

### 权限说明

| 权限 | 危险等级 | 说明 |
|------|:--------:|------|
| `log` | 普通 | 写入日志 |
| `storage` | 普通 | 读写插件本地存储 |
| `api` | 普通 | 调用其他插件注册的 API |
| `ui` | 普通 | 创建和操作 UI 元素 |
| `system` | 普通 | 获取系统信息 |
| `fs` | ⚠️ 危险 | 读写文件系统 |
| `network` | ⚠️ 危险 | 发送 HTTP 请求 |
| `server` | ⚠️ 危险 | 管理 Minecraft 服务器 |
| `console` | ⚠️ 危险 | 向服务器控制台发送命令 |
| `execute_program` | 🚨 极危 | 执行外部程序 |
| `plugin_folder_access` | 🚨 极危 | 访问其他插件的文件和数据 |

### repo 字段解析规则

- `"username/repo"` → 视为 GitHub 仓库，按 `download_type` 下载
- `"https://..."` 或 `"http://..."` → 视为第三方仓库，直接作为下载 URL

---

## 本地开发

```bash
npm install
npm run dev
```

## 部署

推送到 GitHub 后，GitHub Actions 自动更新 `api/plugins.json`，GitHub Pages 自动部署。
