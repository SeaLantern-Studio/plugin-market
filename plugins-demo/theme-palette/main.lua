-- 主题调色板插件
-- 为 SeaLantern 提供可视化 CSS 主题自定义功能

-- ============================================================
-- 翻译表
-- ============================================================
local translations = {
    -- 加载相关
    ["theme-palette.load.loaded"] = "主题调色板插件已加载",

    -- 启用相关
    ["theme-palette.enable.enabled"] = "主题调色板已启用",
    ["theme-palette.enable.current_preset"] = "当前主题预设: %preset%",
    ["theme-palette.enable.using_default"] = "使用默认主题",

    -- 禁用相关
    ["theme-palette.disable.disabled"] = "主题调色板插件已禁用 - 恢复默认主题",

    -- 卸载相关
    ["theme-palette.unload.unloaded"] = "主题调色板插件已卸载"
}

-- ============================================================
-- 翻译辅助函数
-- ============================================================
local function t(key, vars)
    if not sl.i18n then
        -- 如果 i18n 不可用，返回中文默认值
        local text = translations[key] or key
        if vars then
            for k, v in pairs(vars) do
                text = text:gsub("%%" .. k, tostring(v))
            end
        end
        return text
    end

    -- 使用 sl.i18n.t() 获取翻译
    local text = sl.i18n.t(key)

    -- 如果返回的 key 不存在（可能翻译表未加载），使用本地翻译表
    if text == key and translations[key] then
        text = translations[key]
    end

    -- 变量替换
    if vars then
        for k, v in pairs(vars) do
            text = text:gsub("%%" .. k, tostring(v))
        end
    end

    return text
end

function onLoad()
    sl.log.info(t("theme-palette.load.loaded"))
end

function onEnable()
    sl.log.info(t("theme-palette.enable.enabled"))

    -- 注册 API：获取当前主题预设名
    sl.api.register("get_preset", function()
        return sl.storage.get("current_preset") or "default"
    end)

    -- 注册 API：获取当前自定义颜色配置
    sl.api.register("get_colors", function()
        local colors = {}
        local keys = sl.storage.keys()
        for _, key in ipairs(keys) do
            if key:match("^color_") then
                colors[key] = sl.storage.get(key)
            end
        end
        return colors
    end)

    -- 注册 API：获取主题的主色调（供其他插件适配用）
    sl.api.register("get_primary_color", function()
        return sl.storage.get("color_primary") or "#64ffda"
    end)

    -- 注册 API：获取主题的背景色
    sl.api.register("get_background_color", function()
        return sl.storage.get("color_bg_primary") or "#0a0e14"
    end)

    -- 从存储中读取已保存的预设
    local preset = sl.storage.get("active_preset")
    if preset then
        sl.log.info(t("theme-palette.enable.current_preset", { preset = preset }))
    else
        sl.log.info(t("theme-palette.enable.using_default"))
    end
end

function onDisable()
    sl.log.info(t("theme-palette.disable.disabled"))
end

function onUnload()
    sl.log.info(t("theme-palette.unload.unloaded"))
end
