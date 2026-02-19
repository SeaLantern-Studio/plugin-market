-- Element API 示例插件
-- 展示 sl.element 命名空间下所有元素交互方法的实际用法

local plugin = {}

-- 插件启用时调用
function plugin.onEnable()
    sl.log.info("========== [Element Demo] 插件已启用 ==========")
    sl.log.info("")

    -- ==========================================
    -- sl.element.get_text(selector)
    -- 获取元素的文本内容
    -- 参数: selector - CSS 选择器 (string)
    -- 返回: string 或 nil
    -- ==========================================
    sl.log.info("[1] sl.element.get_text() - 获取元素文本")
    local ok, text = pcall(function()
        return sl.element.get_text("h1")
    end)
    if ok then
        sl.log.info("  h1 文本: " .. tostring(text))
    else
        sl.log.warn("  调用失败: " .. tostring(text))
    end
    sl.log.info("")

    -- ==========================================
    -- sl.element.get_value(selector)
    -- 获取表单元素的值
    -- 参数: selector - CSS 选择器 (string)
    -- 返回: string 或 nil
    -- ==========================================
    sl.log.info("[2] sl.element.get_value() - 获取表单值")
    local ok2, val = pcall(function()
        return sl.element.get_value("input")
    end)
    if ok2 then
        sl.log.info("  input 值: " .. tostring(val))
    else
        sl.log.warn("  调用失败: " .. tostring(val))
    end
    sl.log.info("")

    -- ==========================================
    -- sl.element.get_attribute(selector, attr)
    -- 获取元素的指定属性值
    -- 参数:
    --   selector - CSS 选择器 (string)
    --   attr     - 属性名 (string)
    -- 返回: string 或 nil
    -- ==========================================
    sl.log.info("[3] sl.element.get_attribute() - 获取元素属性")
    local ok3, attr = pcall(function()
        return sl.element.get_attribute("a", "href")
    end)
    if ok3 then
        sl.log.info("  a[href]: " .. tostring(attr))
    else
        sl.log.warn("  调用失败: " .. tostring(attr))
    end
    sl.log.info("")

    -- ==========================================
    -- sl.element.get_attributes(selector)
    -- 获取元素的所有属性
    -- 参数: selector - CSS 选择器 (string)
    -- 返回: table - {attr_name = attr_value, ...}
    -- ==========================================
    sl.log.info("[4] sl.element.get_attributes() - 获取所有属性")
    local ok4, attrs = pcall(function()
        return sl.element.get_attributes("body")
    end)
    if ok4 and attrs then
        for k, v in pairs(attrs) do
            sl.log.info("  body[" .. tostring(k) .. "] = " .. tostring(v))
        end
    else
        sl.log.warn("  调用失败: " .. tostring(attrs))
    end
    sl.log.info("")

    -- ==========================================
    -- sl.element.click(selector)
    -- 模拟点击元素
    -- 参数: selector - CSS 选择器 (string)
    -- 返回: boolean - 是否成功
    -- ==========================================
    sl.log.info("[5] sl.element.click() - 模拟点击")
    sl.log.info("  用法: sl.element.click('#submit-btn')")
    sl.log.info("")

    -- ==========================================
    -- sl.element.set_value(selector, value)
    -- 设置表单元素的值
    -- 参数:
    --   selector - CSS 选择器 (string)
    --   value    - 新值 (string)
    -- 返回: boolean - 是否成功
    -- ==========================================
    sl.log.info("[6] sl.element.set_value() - 设置表单值")
    sl.log.info("  用法: sl.element.set_value('#my-input', '新值')")
    sl.log.info("")

    -- ==========================================
    -- sl.element.check(selector, checked)
    -- 设置复选框的选中状态
    -- 参数:
    --   selector - CSS 选择器 (string)
    --   checked  - 是否选中 (boolean)
    -- 返回: boolean - 是否成功
    -- ==========================================
    sl.log.info("[7] sl.element.check() - 设置复选框状态")
    sl.log.info("  用法: sl.element.check('#my-checkbox', true)")
    sl.log.info("")

    -- ==========================================
    -- sl.element.select(selector, value)
    -- 选择下拉框的选项
    -- 参数:
    --   selector - CSS 选择器 (string)
    --   value    - 选项值 (string)
    -- 返回: boolean - 是否成功
    -- ==========================================
    sl.log.info("[8] sl.element.select() - 选择下拉框选项")
    sl.log.info("  用法: sl.element.select('#my-select', 'option-value')")
    sl.log.info("")

    -- ==========================================
    -- sl.element.focus(selector)
    -- 聚焦元素
    -- 参数: selector - CSS 选择器 (string)
    -- 返回: boolean - 是否成功
    -- ==========================================
    sl.log.info("[9] sl.element.focus() - 聚焦元素")
    sl.log.info("  用法: sl.element.focus('#my-input')")
    sl.log.info("")

    -- ==========================================
    -- sl.element.blur(selector)
    -- 取消聚焦
    -- 参数: selector - CSS 选择器 (string)
    -- 返回: boolean - 是否成功
    -- ==========================================
    sl.log.info("[10] sl.element.blur() - 取消聚焦")
    sl.log.info("  用法: sl.element.blur('#my-input')")
    sl.log.info("")

    -- ==========================================
    -- sl.element.on_change(selector, callback)
    -- 监听元素值变化事件
    -- 参数:
    --   selector - CSS 选择器 (string)
    --   callback - 回调函数 function(value)
    -- 返回: boolean - 是否成功
    -- ==========================================
    sl.log.info("[11] sl.element.on_change() - 监听值变化")
    sl.log.info("  用法:")
    sl.log.info("  sl.element.on_change('#my-input', function(value)")
    sl.log.info("      sl.log.info('值变化: ' .. tostring(value))")
    sl.log.info("  end)")
    sl.log.info("")

    sl.log.info("========== [Element Demo] 演示完成 ==========")
end

-- 插件禁用时调用
function plugin.onDisable()
    sl.log.info("[Element Demo] 插件已禁用")
end

return plugin
