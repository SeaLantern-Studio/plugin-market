-- ============================================================
-- CSS 样式定制插件 - SeaLantern 插件示例
-- ============================================================
-- 这个插件展示了如何通过 CSS 注入修改应用的各种视觉效果
-- 主要演示：
--   1. 生命周期钩子的使用
--   2. 日志 API 记录样式变更
--   3. 存储 API 保存用户偏好
--   4. i18n API 实现多语言支持
-- ============================================================

local plugin = {}

-- ============================================================
-- 翻译表
-- ============================================================
local translations = {
    ["zh-CN"] = {
        ["custom-css.load.success"] = "CSS 样式定制插件已加载",
        ["custom-css.load.preferences_loaded"] = "已加载用户样式偏好",
        ["custom-css.load.first_time"] = "首次加载，使用默认样式配置",
        ["custom-css.enable.success"] = "CSS 样式定制已启用",
        ["custom-css.enable.applied_effects"] = "已应用以下样式效果:",
        ["custom-css.enable.effect_scrollbar"] = "  • 自定义滚动条 - 更细腻的滚动条外观",
        ["custom-css.enable.effect_card_hover"] = "  • 卡片悬浮动画 - 悬停时的 3D 倾斜效果",
        ["custom-css.enable.effect_button_ripple"] = "  • 按钮波纹效果 - 点击时的水波纹动画",
        ["custom-css.enable.effect_sidebar_gradient"] = "  • 侧边栏渐变 - 动态渐变背景",
        ["custom-css.enable.css_injected"] = "所有 CSS 样式已注入到页面",
        ["custom-css.disable.success"] = "CSS 样式定制已禁用",
        ["custom-css.disable.styles_removed"] = "所有自定义样式已移除，恢复默认外观",
        ["custom-css.unload.success"] = "CSS 样式定制插件已卸载",
    },
    ["zh-TW"] = {
        ["custom-css.load.success"] = "CSS 樣式定制外掛已載入",
        ["custom-css.load.preferences_loaded"] = "已載入使用者樣式偏好",
        ["custom-css.load.first_time"] = "首次載入，使用預設樣式配置",
        ["custom-css.enable.success"] = "CSS 樣式定制已啟用",
        ["custom-css.enable.applied_effects"] = "已套用以下樣式效果:",
        ["custom-css.enable.effect_scrollbar"] = "  • 自訂捲軸 - 更細膩的捲軸外觀",
        ["custom-css.enable.effect_card_hover"] = "  • 卡片懸浮動畫 - 懸停時的 3D 傾斜效果",
        ["custom-css.enable.effect_button_ripple"] = "  • 按鈕波紋效果 - 點擊時的水波紋動畫",
        ["custom-css.enable.effect_sidebar_gradient"] = "  • 側邊欄漸變 - 動態漸變背景",
        ["custom-css.enable.css_injected"] = "所有 CSS 樣式已注入到頁面",
        ["custom-css.disable.success"] = "CSS 樣式定制已停用",
        ["custom-css.disable.styles_removed"] = "所有自訂樣式已移除，恢復預設外觀",
        ["custom-css.unload.success"] = "CSS 樣式定制外掛已卸載",
    },
    ["en-US"] = {
        ["custom-css.load.success"] = "Custom CSS plugin loaded",
        ["custom-css.load.preferences_loaded"] = "User style preferences loaded",
        ["custom-css.load.first_time"] = "First load, using default style configuration",
        ["custom-css.enable.success"] = "Custom CSS styling enabled",
        ["custom-css.enable.applied_effects"] = "Applied the following style effects:",
        ["custom-css.enable.effect_scrollbar"] = "  • Custom scrollbar - Sleeker scrollbar appearance",
        ["custom-css.enable.effect_card_hover"] = "  • Card hover animation - 3D tilt effect on hover",
        ["custom-css.enable.effect_button_ripple"] = "  • Button ripple effect - Water ripple animation on click",
        ["custom-css.enable.effect_sidebar_gradient"] = "  • Sidebar gradient - Dynamic gradient background",
        ["custom-css.enable.css_injected"] = "All CSS styles injected into the page",
        ["custom-css.disable.success"] = "Custom CSS styling disabled",
        ["custom-css.disable.styles_removed"] = "All custom styles removed, default appearance restored",
        ["custom-css.unload.success"] = "Custom CSS plugin unloaded",
    },
}

-- ============================================================
-- 辅助函数：读取 style.css 文件内容并注入
-- ============================================================
local function injectCustomCss()
    if not sl.ui then
        sl.log.warn("UI API 不可用，无法注入 CSS")
        return false
    end

    -- 尝试读取 style.css 文件
    local cssContent = ""
    if sl.fs.exists and sl.fs.exists("style.css") then
        -- 读取 CSS 文件
        local file = io.open("style.css", "r")
        if file then
            cssContent = file:read("*all")
            file:close()
        end
    end

    -- 如果无法读取文件，使用内联的 CSS
    if not cssContent or cssContent == "" then
        sl.log.debug("无法读取 style.css，使用空 CSS")
    end

    -- 注入 CSS（如果 UI API 支持）
    local success = sl.ui.inject_css("custom-css", cssContent)
    if success then
        sl.log.debug(t("custom-css.enable.css_injected"))
    end
    return success
end

-- ============================================================
-- 辅助函数：获取翻译文本（带 fallback）
-- ============================================================
local function t(key)
    local locale = sl.i18n.getLocale()
    local lang_table = translations[locale]
    if lang_table and lang_table[key] then
        return lang_table[key]
    end
    -- fallback 到 en-US
    if translations["en-US"] and translations["en-US"][key] then
        return translations["en-US"][key]
    end
    return key
end

-- ============================================================
-- onLoad: 插件加载时调用
-- ============================================================
function plugin.onLoad()
    sl.log.info(t("custom-css.load.success"))

    -- 读取用户的样式偏好历史
    local preferences = sl.storage.get("style_preferences")
    if preferences then
        sl.log.debug(t("custom-css.load.preferences_loaded"))
    else
        sl.log.info(t("custom-css.load.first_time"))
    end

    -- 监听语言变化，输出日志以确认
    sl.i18n.onLocaleChange(function()
        sl.log.debug(t("custom-css.load.success"))
    end)
end

-- ============================================================
-- onEnable: 插件启用时调用
-- ============================================================
function plugin.onEnable()
    sl.log.info(t("custom-css.enable.success"))

    -- 输出样式效果说明
    sl.log.info(t("custom-css.enable.applied_effects"))
    sl.log.info(t("custom-css.enable.effect_scrollbar"))
    sl.log.info(t("custom-css.enable.effect_card_hover"))
    sl.log.info(t("custom-css.enable.effect_button_ripple"))
    sl.log.info(t("custom-css.enable.effect_sidebar_gradient"))

    -- 注入 CSS 样式
    injectCustomCss()

    sl.log.debug(t("custom-css.enable.css_injected"))
end

-- ============================================================
-- 辅助函数：移除注入的 CSS
-- ============================================================
local function removeCustomCss()
    if not sl.ui then
        return false
    end
    return sl.ui.remove_css("custom-css")
end

-- ============================================================
-- onDisable: 插件禁用时调用
-- ============================================================
function plugin.onDisable()
    sl.log.warn(t("custom-css.disable.success"))
    sl.log.info(t("custom-css.disable.styles_removed"))
    -- 移除注入的 CSS
    removeCustomCss()
end

-- ============================================================
-- onUnload: 插件卸载时调用
-- ============================================================
function plugin.onUnload()
    sl.log.info(t("custom-css.unload.success"))
end

return plugin
