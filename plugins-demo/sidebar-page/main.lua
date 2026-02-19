-- ============================================================
-- 侧边栏页面示例插件 - SeaLantern 插件示例
-- ============================================================
-- 这个插件展示了如何创建带侧边栏导航的插件独立页面
--
-- 主要演示：
--   1. manifest.json 中的 ui.sidebar 配置
--   2. 生命周期钩子的使用
--   3. 存储 API 保存页面状态
--   4. 设置项的使用
--   5. i18n API 的使用
--
-- 侧边栏配置说明：
--   在 manifest.json 中添加 ui.sidebar 配置后，
--   插件会在应用侧边栏中显示一个导航项，
--   点击后会打开插件的独立页面。
-- ============================================================

local plugin = {}

-- ============================================================
-- 翻译表
-- ============================================================
local i18n = {
    -- 插件状态消息
    ["sidebar-page.plugin.loaded"] = "自定义页面插件已加载",
    ["sidebar-page.plugin.enabled"] = "自定义页面插件已启用",
    ["sidebar-page.plugin.disabled"] = "自定义页面插件已禁用",
    ["sidebar-page.plugin.unloaded"] = "自定义页面插件已卸载",

    -- 初始化消息
    ["sidebar-page.init.first"] = "首次加载，初始化插件数据...",
    ["sidebar-page.init.complete"] = "初始化完成",
    ["sidebar-page.init.welcome"] = "欢迎回来！页面已被访问 {count} 次",

    -- 页面访问统计
    ["sidebar-page.visit.stat"] = "页面访问统计: 第 {count} 次访问",
    ["sidebar-page.visit.session"] = "本次会话期间页面被访问了 {count} 次",

    -- 侧边栏配置说明
    ["sidebar-page.config.sidebar.title"] = "【侧边栏配置说明】",
    ["sidebar-page.config.sidebar.desc"] = "在 manifest.json 中添加以下配置即可创建侧边栏导航:",
    ["sidebar-page.config.sidebar.label"] = "显示名称",
    ["sidebar-page.config.sidebar.icon"] = "图标名称",
    ["sidebar-page.config.sidebar.priority"] = "排序优先级（数字越大越靠后）",

    -- 设置项配置说明
    ["sidebar-page.config.settings.title"] = "【设置项配置说明】",
    ["sidebar-page.config.settings.desc"] = "本插件配置了以下设置项:",
    ["sidebar-page.config.settings.page_title"] = "page_title (string) - 页面标题",
    ["sidebar-page.config.settings.show_welcome"] = "show_welcome (boolean) - 是否显示欢迎信息",
    ["sidebar-page.config.settings.theme_color"] = "theme_color (select) - 主题颜色选择",
    ["sidebar-page.config.settings.items_per_page"] = "items_per_page (number) - 每页显示数量",

    -- 存储使用示例
    ["sidebar-page.storage.title"] = "【存储使用示例】",
    ["sidebar-page.storage.note_content"] = "这是第 {index} 条笔记",
    ["sidebar-page.storage.saved"] = "已保存新笔记，当前共 {count} 条笔记",
    ["sidebar-page.storage.list"] = "笔记列表:",
    ["sidebar-page.storage.data_saved"] = "所有数据已保存，下次加载时将恢复",

    -- 提示信息
    ["sidebar-page.tip.sidebar"] = "提示: 在侧边栏中点击「自定义页面」可以打开插件页面",
}

-- ============================================================
-- 翻译函数封装
-- ============================================================
local function t(key, vars)
    -- 优先使用 sl.i18n，如果不可用则回退到本地翻译表
    if sl and sl.i18n and sl.i18n.t then
        return sl.i18n.t(key, vars)
    end
    -- 回退到本地翻译表
    local text = i18n[key] or key
    if vars then
        for k, v in pairs(vars) do
            text = text:gsub("{" .. k .. "}", tostring(v))
        end
    end
    return text
end

-- ============================================================
-- 辅助函数：记录页面访问
-- ============================================================
local function recordPageVisit()
    -- 获取访问次数
    local visitCount = sl.storage.get("page_visit_count") or 0
    visitCount = visitCount + 1
    sl.storage.set("page_visit_count", visitCount)
    
    -- 记录访问历史
    local visitHistory = sl.storage.get("visit_history") or {}
    table.insert(visitHistory, {
        count = visitCount
    })
    
    -- 只保留最近 10 条记录
    if #visitHistory > 10 then
        table.remove(visitHistory, 1)
    end
    sl.storage.set("visit_history", visitHistory)
    
    return visitCount
end

-- ============================================================
-- onLoad: 插件加载时调用
-- ============================================================
function onLoad()
    sl.log.info(t("sidebar-page.plugin.loaded"))

    -- 检查是否首次加载
    local isFirstLoad = sl.storage.get("initialized") == nil

    if isFirstLoad then
        sl.log.info(t("sidebar-page.init.first"))

        -- 初始化默认数据
        sl.storage.set("initialized", true)
        sl.storage.set("page_visit_count", 0)
        sl.storage.set("visit_history", {})
        sl.storage.set("user_notes", {})

        sl.log.info(t("sidebar-page.init.complete"))
    else
        -- 显示历史数据
        local visitCount = sl.storage.get("page_visit_count") or 0
        sl.log.info(t("sidebar-page.init.welcome", { count = visitCount }))
    end
end

-- ============================================================
-- onEnable: 插件启用时调用
-- ============================================================
function onEnable()
    sl.log.info(t("sidebar-page.plugin.enabled"))
    sl.log.info("=" .. string.rep("=", 50))

    -- 记录页面访问
    local visitCount = recordPageVisit()
    sl.log.info(t("sidebar-page.visit.stat", { count = visitCount }))

    -- 显示侧边栏配置说明
    sl.log.info("")
    sl.log.info(t("sidebar-page.config.sidebar.title"))
    sl.log.info(t("sidebar-page.config.sidebar.desc"))
    sl.log.debug([[
{
  "ui": {
    "sidebar": {
      "label": "]] .. t("sidebar-page.config.sidebar.label") .. [[",    -- 侧边栏中显示的文字
      "icon": "icon-name",   -- ] .. t("sidebar-page.config.sidebar.icon") .. [[
      "priority": 100        -- ] .. t("sidebar-page.config.sidebar.priority") .. [[
    }
  }
}
]])

    -- 显示设置项说明
    sl.log.info("")
    sl.log.info(t("sidebar-page.config.settings.title"))
    sl.log.info(t("sidebar-page.config.settings.desc"))
    sl.log.info("  - " .. t("sidebar-page.config.settings.page_title"))
    sl.log.info("  - " .. t("sidebar-page.config.settings.show_welcome"))
    sl.log.info("  - " .. t("sidebar-page.config.settings.theme_color"))
    sl.log.info("  - " .. t("sidebar-page.config.settings.items_per_page"))

    -- 显示存储使用示例
    sl.log.info("")
    sl.log.info(t("sidebar-page.storage.title"))

    -- 保存用户笔记示例
    local notes = sl.storage.get("user_notes") or {}
    local newNote = {
        id = #notes + 1,
        content = t("sidebar-page.storage.note_content", { index = #notes + 1 })
    }
    table.insert(notes, newNote)

    -- 只保留最近 5 条笔记
    if #notes > 5 then
        table.remove(notes, 1)
    end
    sl.storage.set("user_notes", notes)

    sl.log.info(t("sidebar-page.storage.saved", { count = #notes }))

    -- 显示所有笔记
    sl.log.debug(t("sidebar-page.storage.list"))
    for i, note in ipairs(notes) do
        sl.log.debug("  " .. tostring(i) .. ". " .. note.content)
    end

    sl.log.info("=" .. string.rep("=", 50))
    sl.log.info(t("sidebar-page.tip.sidebar"))
end

-- ============================================================
-- onDisable: 插件禁用时调用
-- ============================================================
function onDisable()
    sl.log.warn(t("sidebar-page.plugin.disabled"))

    -- 显示统计信息
    local visitCount = sl.storage.get("page_visit_count") or 0
    sl.log.info(t("sidebar-page.visit.session", { count = visitCount }))
end

-- ============================================================
-- onUnload: 插件卸载时调用
-- ============================================================
function onUnload()
    sl.log.info(t("sidebar-page.plugin.unloaded"))
    sl.log.debug(t("sidebar-page.storage.data_saved"))
end

return plugin
