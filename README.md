# SeaLantern Plugin Market

SeaLantern 插件市场的静态站点模板，用于展示和分发 SeaLantern 插件。

## 核心思路（重点）

- **页面只访问 GitHub Pages 提供的静态 API**：`/api/plugins.json`、`/api/categories.json`
- **不在浏览器里调用 GitHub API**（避免 rate limit / CORS / 私有仓库等问题）
- `api/plugins.json` 通过本地脚本从 `plugins/<category>/*.json` 生成，然后提交到仓库，让 GitHub Pages 直接托管

---

## API

- 分类映射：`/api/categories.json`（手动维护，仅用于 英文文件夹名 -> 中文名）
- 插件列表：`/api/plugins.json`（`npm run build` 自动生成）

详见 `API.md`。

---

## 添加新插件（开发者流程）

1. 在 `plugins/<category>/` 创建 `<plugin-id>.json`
2. 执行构建生成 `/api/plugins.json`

```bash
npm install
npm run build
```

3. 提交并推送（GitHub Pages 会自动更新静态 API）

---

## 本地开发

> 由于使用了 fetch API，需要通过 HTTP 服务器访问（不能直接双击打开 html）。

```bash
npm install
npm run dev
```

`npm run dev` 会先执行 `npm run build`，再启动静态服务器。

---

## 部署到 GitHub Pages

1. 创建仓库（例如：`sealantern-plugin-market`）
2. 将 `plugin-market` 目录下的文件推送到仓库根目录
3. Settings > Pages > Deploy from a branch（main / root）

如果需要自定义域名，GitHub Pages 会读取 `CNAME` 文件。
