-- Server Monitor Plugin for SeaLantern
-- Demonstrates more advanced plugin features
-- i18n supported

local plugin = {}

-- i18n translations
local translations = {
    ["en-US"] = {
        ["server-monitor.load.message"] = "Server Monitor plugin loaded",
        ["server-monitor.load.event_log"] = "Event log has {count} entries",
        ["server-monitor.enable.message"] = "Server Monitor enabled - watching for server events",
        ["server-monitor.enable.enable_count"] = "Monitor has been enabled {count} time(s)",
        ["server-monitor.disable.message"] = "Server Monitor disabled",
        ["server-monitor.unload.message"] = "Server Monitor unloaded"
    },
    ["zh-CN"] = {
        ["server-monitor.load.message"] = "服务器监控插件已加载",
        ["server-monitor.load.event_log"] = "事件日志有 {count} 条记录",
        ["server-monitor.enable.message"] = "服务器监控已启用 - 正在监听服务器事件",
        ["server-monitor.enable.enable_count"] = "监控已启用 {count} 次",
        ["server-monitor.disable.message"] = "服务器监控已禁用",
        ["server-monitor.unload.message"] = "服务器监控已卸载"
    },
    ["zh-TW"] = {
        ["server-monitor.load.message"] = "伺服器監控插件已載入",
        ["server-monitor.load.event_log"] = "事件日誌有 {count} 筆記錄",
        ["server-monitor.enable.message"] = "伺服器監控已啟用 - 正在監聽伺服器事件",
        ["server-monitor.enable.enable_count"] = "監控已啟用 {count} 次",
        ["server-monitor.disable.message"] = "伺服器監控已停用",
        ["server-monitor.unload.message"] = "伺服器監控已卸載"
    }
}

-- Helper function to get or initialize a value
local function get_or_default(key, default)
    local val = sl.storage.get(key)
    if val == nil then
        return default
    end
    return val
end

-- i18n helper function
local function t(key, vars)
    -- Try to get translation using sl.i18n if available
    if sl.i18n and sl.i18n.t then
        return sl.i18n.t(key, vars)
    end

    -- Fallback to local translations
    local locale = "en-US"
    if sl.i18n and sl.i18n.getLocale then
        locale = sl.i18n.getLocale()
    end

    local lang = translations[locale] or translations["en-US"]
    local text = lang[key] or key

    -- Replace variables
    if vars then
        for k, v in pairs(vars) do
            text = text:gsub("{" .. k .. "}", tostring(v))
        end
    end

    return text
end

function plugin.onLoad()
    sl.log.info(t("server-monitor.load.message"))

    -- Initialize event log
    local events = get_or_default("event_log", {})
    sl.log.info(t("server-monitor.load.event_log", { count = #events }))
end

function plugin.onEnable()
    sl.log.info(t("server-monitor.enable.message"))

    -- Log enable event
    local events = get_or_default("event_log", {})
    table.insert(events, {
        type = "monitor_enabled"
    })
    sl.storage.set("event_log", events)

    -- Show stats
    local stats = get_or_default("stats", { enable_count = 0 })
    stats.enable_count = stats.enable_count + 1
    sl.storage.set("stats", stats)
    sl.log.info(t("server-monitor.enable.enable_count", { count = stats.enable_count }))
end

function plugin.onDisable()
    sl.log.info(t("server-monitor.disable.message"))

    local events = get_or_default("event_log", {})
    table.insert(events, {
        type = "monitor_disabled"
    })
    sl.storage.set("event_log", events)
end

function plugin.onUnload()
    sl.log.info(t("server-monitor.unload.message"))
end

return plugin
