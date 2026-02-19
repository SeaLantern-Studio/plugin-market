-- Hello World Plugin for SeaLantern
-- Demonstrates basic plugin API usage

local plugin = {}

function plugin.onLoad()
    sl.log.info(sl.i18n.t("hello-world.load.message"))

    -- Test storage API (使用 tonumber 处理可能的字符串，使用 tostring 确保一致性)
    local count = tonumber(sl.storage.get("load_count")) or 0
    count = count + 1
    sl.storage.set("load_count", tostring(count))
    sl.log.info(sl.i18n.t("hello-world.load.count", { count = count }))
end

function plugin.onEnable()
    sl.log.info(sl.i18n.t("hello-world.enable.message"))

    -- Increment enable count (使用 tonumber 处理可能的字符串，使用 tostring 确保一致性)
    local enable_count = tonumber(sl.storage.get("enable_count")) or 0
    enable_count = enable_count + 1
    sl.storage.set("enable_count", tostring(enable_count))

    -- Read back and log
    sl.log.info(sl.i18n.t("hello-world.enable.count", { count = enable_count }))

    -- Test storage keys
    local keys = sl.storage.keys()
    sl.log.debug("Storage keys: " .. table.concat(keys, ", "))
end

function plugin.onDisable()
    sl.log.warn(sl.i18n.t("hello-world.disable.message"))
end

function plugin.onUnload()
    sl.log.info(sl.i18n.t("hello-world.unload.message"))
end

return plugin
