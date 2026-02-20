-- ============================================================
-- 通知美化插件 - SeaLantern 插件示例
-- ============================================================
-- 这个插件展示了如何通过 CSS 创建自定义通知/提示样式
--
-- 主要演示：
--   1. CSS 动画创建进入/退出效果
--   2. 不同类型通知的颜色区分
--   3. 生命周期钩子的使用
--   4. 存储 API 记录通知历史
--   5. i18n API 实现多语言支持
--
-- 注意：style.css 由前端自动注入，无需手动调用 inject_css
-- ============================================================

local plugin = {}

-- ============================================================
-- 翻译表
-- ============================================================
local translations = {
    -- notificationTypes 颜色和描述
    ["notification-style.types.success.color"] = { ["zh-CN"] = "绿色", ["en-US"] = "Green", ["zh-TW"] = "綠色" },
    ["notification-style.types.success.description"] = { ["zh-CN"] = "成功操作", ["en-US"] = "Success", ["zh-TW"] = "成功操作" },
    ["notification-style.types.warning.color"] = { ["zh-CN"] = "橙色", ["en-US"] = "Orange", ["zh-TW"] = "橙色" },
    ["notification-style.types.warning.description"] = { ["zh-CN"] = "警告提示", ["en-US"] = "Warning", ["zh-TW"] = "警告提示" },
    ["notification-style.types.error.color"] = { ["zh-CN"] = "红色", ["en-US"] = "Red", ["zh-TW"] = "紅色" },
    ["notification-style.types.error.description"] = { ["zh-CN"] = "错误信息", ["en-US"] = "Error", ["zh-TW"] = "錯誤資訊" },
    ["notification-style.types.info.color"] = { ["zh-CN"] = "蓝色", ["en-US"] = "Blue", ["zh-TW"] = "藍色" },
    ["notification-style.types.info.description"] = { ["zh-CN"] = "普通信息", ["en-US"] = "Info", ["zh-TW"] = "普通資訊" },

    -- 插件生命周期日志
    ["notification-style.log.loaded"] = { ["zh-CN"] = "通知美化插件已加载", ["en-US"] = "Notification style plugin loaded", ["zh-TW"] = "通知美化插件已載入" },
    ["notification-style.log.firstLoad"] = { ["zh-CN"] = "首次加载，初始化通知统计", ["en-US"] = "First load, initializing notification stats", ["zh-TW"] = "首次載入，初始化通知統計" },
    ["notification-style.log.historyCount"] = { ["zh-CN"] = "已加载通知统计，历史总数: {count}", ["en-US"] = "Loaded notification stats, total history: {count}", ["zh-TW"] = "已載入通知統計，歷史總數: {count}" },
    ["notification-style.log.enabled"] = { ["zh-CN"] = "通知美化插件已启用", ["en-US"] = "Notification style plugin enabled", ["zh-TW"] = "通知美化插件已啟用" },

    -- 通知类型说明
    ["notification-style.log.typesTitle"] = { ["zh-CN"] = "【通知类型说明】", ["en-US"] = "[Notification Types]", ["zh-TW"] = "【通知類型說明】" },
    ["notification-style.log.typesDesc"] = { ["zh-CN"] = "本插件为以下类型的通知提供美化样式:", ["en-US"] = "This plugin provides styled notifications for:", ["zh-TW"] = "本插件為以下類型的通知提供美化樣式:" },
    ["notification-style.log.usage"] = { ["zh-CN"] = "用途: {desc}", ["en-US"] = "Usage: {desc}", ["zh-TW"] = "用途: {desc}" },

    -- CSS 动画效果说明
    ["notification-style.log.animTitle"] = { ["zh-CN"] = "【CSS 动画效果】", ["en-US"] = "[CSS Animations]", ["zh-TW"] = "【CSS 動畫效果】" },
    ["notification-style.log.anim.slide"] = { ["zh-CN"] = "滑入滑出 - 从侧边滑入，向侧边滑出", ["en-US"] = "Slide - Slide in from side, slide out to side", ["zh-TW"] = "滑入滑出 - 從側邊滑入，向側邊滑出" },
    ["notification-style.log.anim.fade"] = { ["zh-CN"] = "淡入淡出 - 透明度渐变", ["en-US"] = "Fade - Opacity transition", ["zh-TW"] = "淡入淡出 - 透明度漸變" },
    ["notification-style.log.anim.bounce"] = { ["zh-CN"] = "弹跳效果 - 带弹性的出现动画", ["en-US"] = "Bounce - Elastic appearance animation", ["zh-TW"] = "彈跳效果 - 帶彈性的出現動畫" },
    ["notification-style.log.anim.scale"] = { ["zh-CN"] = "缩放效果 - 从小到大缩放", ["en-US"] = "Scale - Zoom from small to large", ["zh-TW"] = "縮放效果 - 從小到大縮放" },

    -- 模拟通知演示
    ["notification-style.log.demoTitle"] = { ["zh-CN"] = "【模拟通知演示】", ["en-US"] = "[Demo Notifications]", ["zh-TW"] = "【模擬通知演示】" },
    ["notification-style.log.demo.success"] = { ["zh-CN"] = "OK [成功] 操作已完成", ["en-US"] = "OK [Success] Operation completed", ["zh-TW"] = "OK [成功] 操作已完成" },
    ["notification-style.log.demo.success.msg"] = { ["zh-CN"] = "操作已完成", ["en-US"] = "Operation completed", ["zh-TW"] = "操作已完成" },
    ["notification-style.log.demo.info"] = { ["zh-CN"] = "i [信息] 插件已启用", ["en-US"] = "i [Info] Plugin enabled", ["zh-TW"] = "i [資訊] 插件已啟用" },
    ["notification-style.log.demo.info.msg"] = { ["zh-CN"] = "插件已启用", ["en-US"] = "Plugin enabled", ["zh-TW"] = "插件已啟用" },
    ["notification-style.log.demo.warning"] = { ["zh-CN"] = "! [警告] 这是一条警告示例", ["en-US"] = "! [Warning] This is a warning example", ["zh-TW"] = "! [警告] 這是一條警告示例" },
    ["notification-style.log.demo.warning.msg"] = { ["zh-CN"] = "这是一条警告示例", ["en-US"] = "This is a warning example", ["zh-TW"] = "這是一條警告示例" },

    -- 通知统计
    ["notification-style.log.statsTitle"] = { ["zh-CN"] = "【通知统计】", ["en-US"] = "[Notification Stats]", ["zh-TW"] = "【通知統計】" },
    ["notification-style.log.stats.success"] = { ["zh-CN"] = "成功: {count}", ["en-US"] = "Success: {count}", ["zh-TW"] = "成功: {count}" },
    ["notification-style.log.stats.info"] = { ["zh-CN"] = "信息: {count}", ["en-US"] = "Info: {count}", ["zh-TW"] = "資訊: {count}" },
    ["notification-style.log.stats.warning"] = { ["zh-CN"] = "警告: {count}", ["en-US"] = "Warning: {count}", ["zh-TW"] = "警告: {count}" },
    ["notification-style.log.stats.error"] = { ["zh-CN"] = "错误: {count}", ["en-US"] = "Error: {count}", ["zh-TW"] = "錯誤: {count}" },
    ["notification-style.log.stats.total"] = { ["zh-CN"] = "总计: {count}", ["en-US"] = "Total: {count}", ["zh-TW"] = "總計: {count}" },

    -- 提示和禁用/卸载
    ["notification-style.log.cssInjected"] = { ["zh-CN"] = "CSS 样式已由前端自动注入", ["en-US"] = "CSS styles auto-injected by frontend", ["zh-TW"] = "CSS 樣式已由前端自動注入" },
    ["notification-style.log.disabled"] = { ["zh-CN"] = "通知美化插件已禁用", ["en-US"] = "Notification style plugin disabled", ["zh-TW"] = "通知美化插件已停用" },
    ["notification-style.log.styleRestored"] = { ["zh-CN"] = "通知样式已恢复为默认", ["en-US"] = "Notification style restored to default", ["zh-TW"] = "通知樣式已恢復為預設" },
    ["notification-style.log.unloaded"] = { ["zh-CN"] = "通知美化插件已卸载", ["en-US"] = "Notification style plugin unloaded", ["zh-TW"] = "通知美化插件已卸載" },
    ["notification-style.log.finalStats"] = { ["zh-CN"] = "最终统计 - 总通知数: {count}", ["en-US"] = "Final stats - Total notifications: {count}", ["zh-TW"] = "最終統計 - 總通知數: {count}" },
}

-- ============================================================
-- 翻译辅助函数（必须在翻译表之后定义）
-- ============================================================
local function t(key, options)
    return sl.i18n.t(key, options)
end

-- ============================================================
-- 注册翻译到 i18n 系统
-- ============================================================
local function registerTranslations()
    for key, locales in pairs(translations) do
        for locale, text in pairs(locales) do
            sl.i18n.addTranslations(locale, { [key] = text })
        end
    end
end

-- ============================================================
-- 通知类型定义
-- ============================================================
local notificationTypes = {
    success = { icon = "OK", colorKey = "notification-style.types.success.color", descKey = "notification-style.types.success.description" },
    warning = { icon = "!", colorKey = "notification-style.types.warning.color", descKey = "notification-style.types.warning.description" },
    error = { icon = "X", colorKey = "notification-style.types.error.color", descKey = "notification-style.types.error.description" },
    info = { icon = "i", colorKey = "notification-style.types.info.color", descKey = "notification-style.types.info.description" }
}

-- ============================================================
-- 辅助函数：获取通知等级开关设置
-- ============================================================
local function isLevelEnabled(level)
    local settingKey = "level_" .. level
    local value = sl.storage.get(settingKey)
    -- 默认全部开启
    if value == nil then
        return true
    end
    return value == true
end

-- ============================================================
-- 辅助函数：获取通知类型信息
-- ============================================================
local function getTypeInfo(typeName)
    local typeInfo = notificationTypes[typeName]
    if not typeInfo then
        return "unknown", "unknown"
    end
    return t(typeInfo.colorKey), t(typeInfo.descKey)
end

-- ============================================================
-- 辅助函数：记录通知到历史
-- ============================================================
local function recordNotification(typeName, message)
    local history = sl.storage.get("notification_history") or {}
    table.insert(history, {
        type = typeName,
        message = message,
        timestamp = 0
    })
    -- 只保留最近 50 条
    while #history > 50 do
        table.remove(history, 1)
    end
    sl.storage.set("notification_history", history)
end

-- ============================================================
-- 生命周期：加载
-- ============================================================
function plugin.onLoad()
    -- 注册翻译
    registerTranslations()

    sl.log.info(t("notification-style.log.loaded"))

    -- 加载通知统计
    local stats = sl.storage.get("notification_stats")
    if not stats then
        sl.log.debug(t("notification-style.log.firstLoad"))
        stats = { success = 0, warning = 0, error = 0, info = 0, total = 0 }
        sl.storage.set("notification_stats", stats)
    else
        sl.log.info(t("notification-style.log.historyCount", { count = tostring(stats.total or 0) }))
    end
end

-- ============================================================
-- 生命周期：启用
-- ============================================================
function plugin.onEnable()
    sl.log.info(t("notification-style.log.enabled"))
    sl.log.info("===================================================")

    -- CSS 由前端自动注入（style.css + ui 权限）
    sl.log.info(t("notification-style.log.cssInjected"))

    -- 根据通知等级设置，注入隐藏 CSS
    local hideCss = ""
    local levels = { "info", "warning", "error", "success" }
    for _, level in ipairs(levels) do
        if not isLevelEnabled(level) then
            hideCss = hideCss .. ".sl-toast--" .. level .. " { display: none !important; }\n"
        end
    end
    if hideCss ~= "" then
        sl.ui.inject_css("notification-level-filter", hideCss)
        sl.log.info("已注入通知等级过滤 CSS")
    end

    -- 显示通知类型说明（仅显示已启用的等级）
    sl.log.info(t("notification-style.log.typesTitle"))
    sl.log.info(t("notification-style.log.typesDesc"))
    sl.log.info("")

    for typeName, typeInfo in pairs(notificationTypes) do
        if isLevelEnabled(typeName) then
            local color, desc = getTypeInfo(typeName)
            sl.log.info("  " .. typeInfo.icon .. " " .. typeName .. " (" .. color .. ")")
            sl.log.debug(t("notification-style.log.usage", { desc = desc }))
        end
    end

    -- 显示动画效果说明
    sl.log.info("")
    sl.log.info(t("notification-style.log.animTitle"))
    sl.log.info("  " .. t("notification-style.log.anim.slide"))
    sl.log.info("  " .. t("notification-style.log.anim.fade"))
    sl.log.info("  " .. t("notification-style.log.anim.bounce"))
    sl.log.info("  " .. t("notification-style.log.anim.scale"))

    -- 模拟发送不同类型的通知（仅发送已启用等级的通知）
    sl.log.info("")
    sl.log.info(t("notification-style.log.demoTitle"))

    -- 更新统计
    local stats = sl.storage.get("notification_stats") or {
        success = 0, warning = 0, error = 0, info = 0, total = 0
    }

    local demoCount = 0

    if isLevelEnabled("success") then
        sl.log.info("  " .. t("notification-style.log.demo.success"))
        sl.ui.toast("success", t("notification-style.log.demo.success.msg"))
        stats.success = stats.success + 1
        recordNotification("success", t("notification-style.log.demo.success.msg"))
        demoCount = demoCount + 1
    end

    if isLevelEnabled("info") then
        sl.log.info("  " .. t("notification-style.log.demo.info"))
        sl.ui.toast("info", t("notification-style.log.demo.info.msg"))
        stats.info = stats.info + 1
        recordNotification("info", t("notification-style.log.demo.info.msg"))
        demoCount = demoCount + 1
    end

    if isLevelEnabled("warning") then
        sl.log.warn("  " .. t("notification-style.log.demo.warning"))
        sl.ui.toast("warning", t("notification-style.log.demo.warning.msg"))
        stats.warning = stats.warning + 1
        recordNotification("warning", t("notification-style.log.demo.warning.msg"))
        demoCount = demoCount + 1
    end

    stats.total = stats.total + demoCount
    sl.storage.set("notification_stats", stats)

    -- 显示统计
    sl.log.info("")
    sl.log.info(t("notification-style.log.statsTitle"))
    sl.log.info("  " .. t("notification-style.log.stats.success", { count = tostring(stats.success) }))
    sl.log.info("  " .. t("notification-style.log.stats.info", { count = tostring(stats.info) }))
    sl.log.info("  " .. t("notification-style.log.stats.warning", { count = tostring(stats.warning) }))
    sl.log.info("  " .. t("notification-style.log.stats.error", { count = tostring(stats.error) }))
    sl.log.info("  " .. t("notification-style.log.stats.total", { count = tostring(stats.total) }))
    sl.log.info("===================================================")
end

-- ============================================================
-- 生命周期：禁用
-- ============================================================
function plugin.onDisable()
    sl.log.warn(t("notification-style.log.disabled"))
    sl.log.info(t("notification-style.log.styleRestored"))
end

-- ============================================================
-- 生命周期：卸载
-- ============================================================
function plugin.onUnload()
    local stats = sl.storage.get("notification_stats") or { total = 0 }
    sl.log.info(t("notification-style.log.finalStats", { count = tostring(stats.total or 0) }))
    sl.log.info(t("notification-style.log.unloaded"))
end

return plugin
