-- SeaLantern Plugin Template
-- This is the main entry point for your plugin

local plugin = {}

-- ============================================
-- UI 控制 API (需要 "ui" 权限)
-- ============================================

-- 隐藏元素
-- sl.ui.hide(".some-element")

-- 显示元素
-- sl.ui.show(".some-element")

-- 禁用元素
-- sl.ui.disable("#some-button")

-- 启用元素
-- sl.ui.enable("#some-button")

-- 在指定位置插入 HTML
-- sl.ui.insert("append", ".container", "<div>新内容</div>")
-- placement 可选值: "before" | "after" | "prepend" | "append"

-- 移除插件插入的元素
-- sl.ui.remove(".my-inserted-element")

-- 设置元素样式
-- sl.ui.set_style(".some-element", {color = "red", ["font-size"] = "14px"})

-- 设置元素属性
-- sl.ui.set_attribute(".some-element", "title", "提示文字")

-- 查询元素信息
-- local elements = sl.ui.query(".some-selector")

-- ============================================
-- 元素交互 API (需要 "element" 权限)
-- ============================================

-- 获取元素文本
-- local text = sl.element.get_text(".some-element")

-- 获取表单值
-- local value = sl.element.get_value("#my-input")

-- 获取元素属性
-- local href = sl.element.get_attribute("a.link", "href")

-- 获取所有属性
-- local attrs = sl.element.get_attributes(".some-element")

-- 点击元素
-- sl.element.click("#submit-btn")

-- 设置表单值
-- sl.element.set_value("#my-input", "新值")

-- 设置复选框状态
-- sl.element.check("#my-checkbox", true)

-- 选择下拉框选项
-- sl.element.select("#my-select", "option-value")

-- 聚焦元素
-- sl.element.focus("#my-input")

-- 取消聚焦
-- sl.element.blur("#my-input")

-- 监听元素值变化
-- sl.element.on_change("#my-input", function(value)
--     sl.log.info("值变化: " .. tostring(value))
-- end)

-- ============================================
-- 插件生命周期回调
-- ============================================

function plugin.onLoad()
    sl.log.info("Plugin loaded!")
end

function plugin.onEnable()
    sl.log.info("Plugin enabled!")

    -- Example: Read a setting value from storage
    local greeting = sl.storage.get("greeting")
    if greeting then
        sl.log.info("Stored greeting: " .. greeting)
    end
end

function plugin.onDisable()
    sl.log.info("Plugin disabled!")
end

function plugin.onUnload()
    sl.log.info("Plugin unloaded!")
end

-- Available APIs:
--
-- sl.log.debug(message)   - Debug level log
-- sl.log.info(message)    - Info level log
-- sl.log.warn(message)    - Warning level log
-- sl.log.error(message)   - Error level log
--
-- sl.storage.get(key)     - Get a stored value (returns nil if not found)
-- sl.storage.set(key, value) - Store a value (string)
-- sl.storage.remove(key)  - Remove a stored value
-- sl.storage.keys()       - List all storage keys
--
-- Plugin Features:
-- - icon.png: Plugin icon displayed in the plugin card
-- - style.css: Custom CSS injected when plugin is enabled
-- - settings in manifest.json: Creates a settings UI in the plugin card
-- - Settings values are stored in settings.json in the plugin directory

return plugin
