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
-- ============================================================

local plugin = {}

-- ============================================================
-- 辅助函数：注入通知样式 CSS
-- ============================================================
local function injectNotificationCss()
    if not sl.ui then
        sl.log.warn("UI API 不可用，无法注入 CSS")
        return false
    end

    -- 读取 style.css 文件
    local cssContent = ""
    local file = io.open("style.css", "r")
    if file then
        cssContent = file:read("*all")
        file:close()
    end

    if not cssContent or cssContent == "" then
        sl.log.debug("无法读取 style.css")
    end

    local success = sl.ui.inject_css("notification-style", cssContent)
    if success then
        sl.log.debug(t("notification-style.log.cssInjected"))
    end
    return success
end

-- ============================================================
-- 辅助函数：移除通知样式 CSS
-- ============================================================
local function removeNotificationCss()
    if not sl.ui then
        return false
    end
    return sl.ui.remove_css("notification-style")
end

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
    ["notification-style.log.cssInjected"] = { ["zh-CN"] = "提示: CSS 样式已注入，所有通知将使用美化后的样式", ["en-US"] = "Tip: CSS injected, all notifications will use styled appearance", ["zh-TW"] = "提示: CSS 樣式已注入，所有通知將使用美化後的樣式" },
    ["notification-style.log.disabled"] = { ["zh-CN"] = "通知美化插件已禁用", ["en-US"] = "Notification style plugin disabled", ["zh-TW"] = "通知美化插件已停用" },
    ["notification-style.log.styleRestored"] = { ["zh-CN"] = "通知样式已恢复为默认", ["en-US"] = "Notification style restored to default", ["zh-TW"] = "通知樣式已恢復為預設" },
    ["notification-style.log.unloaded"] = { ["zh-CN"] = "通知美化插件已卸载", ["en-US"] = "Notification style plugin unloaded", ["zh-TW"] = "通知美化插件已卸載" },
    ["notification-style.log.finalStats"] = { ["zh-CN"] = "最终统计 - 总通知数: {count}", ["en-US"] = "Final stats - Total notifications: {count}", ["zh-TW"] = "最終統計 - 總通知數: {count}" },
}

-- ============================================================
-- 翻译辅助函数
-- ============================================================
local function t(key, options)
    return sl.i18n.t(key, options)
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

-- 获取通知类型的本地化值
local function getTypeInfo(key)
    local colorKey = notificationTypes[key].colorKey
    local descKey = notificationTypes[key].descKey
    return t(colorKey), t(descKey)
end

-- ============================================================
-- 辅助函数：记录通知
-- ============================================================
local function recordNotification(notifType, message)
    local history = sl.storage.get("notification_history") or {}
    
    table.insert(history, {
        type = notifType,
        message = message
    })
    
    -- 只保留最近 20 条记录
    if #history > 20 then
        table.remove(history, 1)
    end
    
    sl.storage.set("notification_history", history)
    return #history
end

-- ============================================================
-- onLoad: 插件加载时调用
-- ============================================================
function plugin.onLoad()
    sl.log.info(t("notification-style.log.loaded"))

    -- 初始化统计数据
    local stats = sl.storage.get("notification_stats")
    if stats == nil then
        stats = {
            success = 0,
            warning = 0,
            error = 0,
            info = 0,
            total = 0
        }
        sl.storage.set("notification_stats", stats)
        sl.log.info(t("notification-style.log.firstLoad"))
    else
        sl.log.info(t("notification-style.log.historyCount", { count = tostring(stats.total) }))
    end
end

-- ============================================================
-- onEnable: 插件启用时调用
-- ============================================================
function plugin.onEnable()
    sl.log.info(t("notification-style.log.enabled"))
    sl.log.info("=" .. string.rep("=", 50))

    -- 注入通知样式 CSS
    injectNotificationCss()

    -- 显示通知类型说明
    sl.log.info(t("notification-style.log.typesTitle"))
    sl.log.info(t("notification-style.log.typesDesc"))
    sl.log.info("")

    for typeName, typeInfo in pairs(notificationTypes) do
        local color, desc = getTypeInfo(typeName)
        sl.log.info("  " .. typeInfo.icon .. " " .. typeName .. " (" .. color .. ")")
        sl.log.debug(t("notification-style.log.usage", { desc = desc }))
    end

    -- 显示 CSS 动画说明
    sl.log.info("")
    sl.log.info(t("notification-style.log.animTitle"))
    sl.log.info("  " .. t("notification-style.log.anim.slide"))
    sl.log.info("  " .. t("notification-style.log.anim.fade"))
    sl.log.info("  " .. t("notification-style.log.anim.bounce"))
    sl.log.info("  " .. t("notification-style.log.anim.scale"))

    -- 模拟发送不同类型的通知
    sl.log.info("")
    sl.log.info(t("notification-style.log.demoTitle"))

    -- 更新统计
    local stats = sl.storage.get("notification_stats") or {
        success = 0, warning = 0, error = 0, info = 0, total = 0
    }

    -- 模拟成功通知
    sl.log.info("  " .. t("notification-style.log.demo.success"))
    stats.success = stats.success + 1
    recordNotification("success", t("notification-style.log.demo.success.msg"))

    -- 模拟信息通知
    sl.log.info("  " .. t("notification-style.log.demo.info"))
    stats.info = stats.info + 1
    recordNotification("info", t("notification-style.log.demo.info.msg"))

    -- 模拟警告通知
    sl.log.warn("  " .. t("notification-style.log.demo.warning"))
    stats.warning = stats.warning + 1
    recordNotification("warning", t("notification-style.log.demo.warning.msg"))

    stats.total = stats.total + 3
    sl.storage.set("notification_stats", stats)

    -- 显示统计
    sl.log.info("")
    sl.log.info(t("notification-style.log.statsTitle"))
    sl.log.info("  " .. t("notification-style.log.stats.success", { count = tostring(stats.success) }))
    sl.log.info("  " .. t("notification-style.log.stats.info", { count = tostring(stats.info) }))
    sl.log.info("  " .. t("notification-style.log.stats.warning", { count = tostring(stats.warning) }))
    sl.log.info("  " .. t("notification-style.log.stats.error", { count = tostring(stats.error) }))
    sl.log.info("  " .. t("notification-style.log.stats.total", { count = tostring(stats.total) }))

    sl.log.info("=" .. string.rep("=", 50))
    sl.log.info(t("notification-style.log.cssInjected"))
end

-- ============================================================
-- onDisable: 插件禁用时调用
-- ============================================================
function plugin.onDisable()
    sl.log.warn(t("notification-style.log.disabled"))
    sl.log.info(t("notification-style.log.styleRestored"))
    -- 移除通知样式 CSS
    removeNotificationCss()
end

-- ============================================================
-- onUnload: 插件卸载时调用
-- ============================================================
function plugin.onUnload()
    sl.log.info(t("notification-style.log.unloaded"))

    -- 显示最终统计
    local stats = sl.storage.get("notification_stats")
    if stats then
        sl.log.debug(t("notification-style.log.finalStats", { count = tostring(stats.total) }))
    end
end

return plugin
