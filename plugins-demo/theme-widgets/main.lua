-- 主题小组件插件
-- 必须依赖 theme-palette，通过其 API 获取颜色并创建装饰效果

local plugin = {}

-- ============================================================
-- 辅助函数：注入主题小组件样式 CSS
-- ============================================================
local function injectThemeWidgetsCss()
    if not sl.ui then
        sl.log.warn("UI API 不可用，无法注入 CSS")
        return false
    end

    -- 读取 style.css 文件（使用沙箱安全 API）
    local cssContent = sl.plugins.read_file("theme-widgets", "style.css") or ""

    if cssContent == "" then
        sl.log.debug("无法读取 style.css")
    end

    local success = sl.ui.inject_css("theme-widgets", cssContent)
    if success then
        sl.log.debug("Theme widgets CSS injected")
    end
    return success
end

-- ============================================================
-- 辅助函数：移除主题小组件样式 CSS
-- ============================================================
local function removeThemeWidgetsCss()
    if not sl.ui then
        return false
    end
    return sl.ui.remove_css("theme-widgets")
end

-- ============================================================
-- onLoad: 插件加载时调用
-- ============================================================
function plugin.onLoad()
    sl.log.info(sl.i18n.t("theme-widgets.load.loading"))
end

-- ============================================================
-- onEnable: 插件启用时调用
-- ============================================================
function plugin.onEnable()
    sl.log.info(sl.i18n.t("theme-widgets.enable.initializing"))

    -- 注入主题小组件 CSS
    injectThemeWidgetsCss()

    -- 从 theme-palette 获取颜色信息
    local primary = sl.api.call("theme-palette", "get_primary_color")
    if not primary then
        primary = "#64ffda"  -- 默认主色调
    end
    local bg = sl.api.call("theme-palette", "get_background_color")
    if not bg then
        bg = "#0a0e14"  -- 默认背景色
    end
    local preset = sl.api.call("theme-palette", "get_preset")
    if not preset then
        preset = "default"  -- 默认预设
    end

    sl.log.info(sl.i18n.t("theme-widgets.enable.preset", { preset = tostring(preset) }))
    sl.log.info(sl.i18n.t("theme-widgets.enable.primary", { color = tostring(primary) }))
    sl.log.info(sl.i18n.t("theme-widgets.enable.background", { color = tostring(bg) }))

    -- 保存颜色到存储
    sl.storage.set("current_primary", primary or "#64ffda")
    sl.storage.set("current_bg", bg or "#0a0e14")
    sl.storage.set("current_preset", preset or "default")

    -- 注册自己的 API，供其他插件查询当前装饰状态
    sl.api.register("get_effects", function()
        return {
            glow = sl.storage.get("enable_glow") ~= "false",
            gradient_text = sl.storage.get("enable_gradient_text") ~= "false",
            particles = sl.storage.get("enable_particles") == "true"
        }
    end)

    sl.log.info(sl.i18n.t("theme-widgets.enable.activated"))
end

-- ============================================================
-- onDisable: 插件禁用时调用
-- ============================================================
function plugin.onDisable()
    sl.log.info(sl.i18n.t("theme-widgets.disable.disabled"))
    -- 移除主题小组件 CSS
    removeThemeWidgetsCss()
end

-- ============================================================
-- onUnload: 插件卸载时调用
-- ============================================================
function plugin.onUnload()
    sl.log.info(sl.i18n.t("theme-widgets.unload.unloaded"))
end

return plugin
