-- ============================================================
-- Storage API Demo Plugin - SeaLantern Plugin Example
-- ============================================================
-- This plugin demonstrates all features of sl.storage API
--
-- sl.storage API:
--   • sl.storage.get(key)         - Get value by key
--   • sl.storage.set(key, value)  - Set key-value pair
--   • sl.storage.remove(key)      - Remove key
--   • sl.storage.keys()           - Get all keys
--
-- Storage Features:
--   • Data persists after app restart
--   • Each plugin has isolated storage space
--   • Supports strings, numbers, booleans, tables
-- ============================================================

local plugin = {}

-- Get current locale
local locale = sl.i18n.getLocale()

-- ============================================================
-- Helper function: convert table to string (for log output)
-- ============================================================
local function tableToString(tbl)
    if type(tbl) ~= "table" then
        return tostring(tbl)
    end
    
    local result = "{"
    local first = true
    for k, v in pairs(tbl) do
        if not first then
            result = result .. ", "
        end
        first = false
        
        if type(k) == "string" then
            result = result .. k .. "="
        end
        
        if type(v) == "table" then
            result = result .. tableToString(v)
        elseif type(v) == "string" then
            result = result .. '"' .. v .. '"'
        else
            result = result .. tostring(v)
        end
    end
    return result .. "}"
end

-- ============================================================
-- onLoad: 插件加载时调用
-- 演示：读取历史数据、初始化存储
-- ============================================================
function onLoad()
    sl.log.info(sl.i18n.t("storage-demo.plugin.loaded"))
    sl.log.info("=" .. string.rep("=", 50))

    -- --------------------------------------------------------
    -- Demo 1: sl.storage.get() - Get data
    -- --------------------------------------------------------
    sl.log.info(sl.i18n.t("storage-demo.demo.get"))

    -- Try to get last load time
    local lastLoadTime = sl.storage.get("last_load_time")

    if lastLoadTime == nil then
        -- If returns nil, key doesn't exist (first run)
        sl.log.info(sl.i18n.t("storage-demo.firstLoad.noHistory"))
    else
        sl.log.info(sl.i18n.t("storage-demo.firstLoad.lastTime") .. tostring(lastLoadTime))
    end

    -- Get load count (use tonumber to handle possible strings)
    local loadCount = tonumber(sl.storage.get("load_count")) or 0
    sl.log.info(sl.i18n.t("storage-demo.firstLoad.loadCount") .. tostring(loadCount))

    -- --------------------------------------------------------
    -- Demo 2: sl.storage.set() - Save data
    -- --------------------------------------------------------
    sl.log.info("")
    sl.log.info(sl.i18n.t("storage-demo.demo.set"))

    -- Save load marker (string type)
    sl.storage.set("last_load_time", "loaded")
    sl.log.info("  " .. sl.i18n.t("storage-demo.saved.lastLoadTime", { value = "loaded" }))

    -- Save load count (use tostring for consistency)
    loadCount = loadCount + 1
    sl.storage.set("load_count", tostring(loadCount))
    sl.log.info("  " .. sl.i18n.t("storage-demo.saved.loadCount", { value = tostring(loadCount) }))

    -- Save boolean value
    sl.storage.set("is_initialized", true)
    sl.log.info("  " .. sl.i18n.t("storage-demo.saved.isInitialized"))

    -- Save table (complex data structure)
    local pluginInfo = {
        name = "Storage Demo",
        version = "1.0.0",
        features = {"get", "set", "remove", "keys"}
    }
    sl.storage.set("plugin_info", pluginInfo)
    sl.log.info("  " .. sl.i18n.t("storage-demo.saved.pluginInfo", { value = tableToString(pluginInfo) }))

    sl.log.info("=" .. string.rep("=", 50))
end

-- ============================================================
-- onEnable: 插件启用时调用
-- 演示：读取和更新数据、列出所有键
-- ============================================================
function onEnable()
    sl.log.info(sl.i18n.t("storage-demo.plugin.enabled"))
    sl.log.info("=" .. string.rep("=", 50))

    -- --------------------------------------------------------
    -- Demo 3: sl.storage.keys() - List all keys
    -- --------------------------------------------------------
    sl.log.info(sl.i18n.t("storage-demo.demo.keys"))

    local allKeys = sl.storage.keys()

    if #allKeys == 0 then
        sl.log.info(sl.i18n.t("storage-demo.keys.empty"))
    else
        sl.log.info(sl.i18n.t("storage-demo.keys.count", { count = tostring(#allKeys) }))
        for i, key in ipairs(allKeys) do
            -- Get value for each key and display
            local value = sl.storage.get(key)
            local valueStr = tableToString(value)
            sl.log.info("     " .. tostring(i) .. ". " .. key .. " = " .. valueStr)
        end
    end

    -- --------------------------------------------------------
    -- Demo 4: Update existing data
    -- --------------------------------------------------------
    sl.log.info("")
    sl.log.info(sl.i18n.t("storage-demo.demo.update"))

    -- Read enable count (use tonumber to handle possible strings)
    local enableCount = tonumber(sl.storage.get("enable_count")) or 0
    sl.log.info("  " .. sl.i18n.t("storage-demo.update.readCount", { value = tostring(enableCount) }))

    -- Update enable count
    enableCount = enableCount + 1
    sl.storage.set("enable_count", tostring(enableCount))
    sl.log.info("  " .. sl.i18n.t("storage-demo.update.writeCount", { value = tostring(enableCount) }))

    -- Save enable marker
    sl.storage.set("last_enable_time", "enabled")
    sl.log.info("  " .. sl.i18n.t("storage-demo.update.saveEnableTime"))

    sl.log.info("=" .. string.rep("=", 50))
    sl.log.debug(sl.i18n.t("storage-demo.plugin.persistTip"))
end

-- ============================================================
-- onDisable: 插件禁用时调用
-- 演示：保存状态数据
-- ============================================================
function onDisable()
    sl.log.warn(sl.i18n.t("storage-demo.plugin.disabled"))
    sl.log.info("=" .. string.rep("=", 50))

    -- Save disable marker
    sl.storage.set("last_disable_time", "disabled")
    sl.log.info(sl.i18n.t("storage-demo.status.saveDisableTime"))

    -- Update disable count (use tonumber to handle possible strings)
    local disableCount = tonumber(sl.storage.get("disable_count")) or 0
    disableCount = disableCount + 1
    sl.storage.set("disable_count", tostring(disableCount))
    sl.log.info(sl.i18n.t("storage-demo.status.disableCount", { value = tostring(disableCount) }))

    sl.log.info("=" .. string.rep("=", 50))
end

-- ============================================================
-- onUnload: 插件卸载时调用
-- 演示：sl.storage.remove() - 删除数据
-- ============================================================
function onUnload()
    sl.log.info(sl.i18n.t("storage-demo.plugin.unloading"))
    sl.log.info("=" .. string.rep("=", 50))

    -- --------------------------------------------------------
    -- Demo 5: sl.storage.remove() - Delete data
    -- --------------------------------------------------------
    sl.log.info(sl.i18n.t("storage-demo.demo.remove"))

    -- Delete temp data (demo purpose)
    -- Note: In real usage, you might want to keep most data

    -- Check if key exists before deletion
    local tempKey = "temp_data"
    sl.storage.set(tempKey, "This is temporary data")
    sl.log.info("  " .. sl.i18n.t("storage-demo.remove.create", { key = tempKey }))

    -- Delete temp data
    sl.storage.remove(tempKey)
    sl.log.info("  " .. sl.i18n.t("storage-demo.remove.deleted", { key = tempKey }))

    -- Verify deletion result
    local deletedValue = sl.storage.get(tempKey)
    if deletedValue == nil then
        sl.log.info("  " .. sl.i18n.t("storage-demo.remove.verifySuccess"))
    else
        sl.log.error("  " .. sl.i18n.t("storage-demo.remove.verifyFailed"))
    end

    -- --------------------------------------------------------
    -- Show final storage status
    -- --------------------------------------------------------
    sl.log.info("")
    sl.log.info(sl.i18n.t("storage-demo.status.final"))
    local finalKeys = sl.storage.keys()
    sl.log.info("  " .. sl.i18n.t("storage-demo.status.remaining", { count = tostring(#finalKeys) }))
    for _, key in ipairs(finalKeys) do
        sl.log.debug("     - " .. key)
    end

    sl.log.info("=" .. string.rep("=", 50))
    sl.log.info(sl.i18n.t("storage-demo.plugin.unloaded"))
    sl.log.info(sl.i18n.t("storage-demo.plugin.dataPersistTip"))
end

return plugin
