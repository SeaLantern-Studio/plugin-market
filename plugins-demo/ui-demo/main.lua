-- UI API 示例插件
-- 展示 sl.ui 命名空间下所有 UI 操作方法的实际用法

local plugin = {}

-- 插件启用时调用
function plugin.onEnable()
    sl.log.info("========== [UI Demo] 插件已启用 ==========")
    sl.log.info("")

    -- ==========================================
    -- sl.ui.inject_html(element_id, html_content)
    -- 注入 HTML 元素到前端页面
    -- 参数:
    --   element_id   - 元素 ID (string)
    --   html_content - HTML 内容 (string)
    -- 返回: boolean - 是否成功
    -- ==========================================
    sl.log.info("[1] sl.ui.inject_html() - 注入 HTML")
    local ok = sl.ui.inject_html("ui-demo-banner",
        '<div id="ui-demo-banner" style="padding:8px 16px;background:#2563eb;color:white;text-align:center;font-size:13px;">' ..
        'UI Demo 插件已注入此横幅 - 禁用插件后将自动移除' ..
        '</div>')
    sl.log.info("  inject_html 结果: " .. tostring(ok))
    sl.log.info("")

    -- ==========================================
    -- sl.ui.update_html(element_id, html_content)
    -- 更新已注入的 HTML 元素内容
    -- 参数:
    --   element_id   - 元素 ID (string)
    --   html_content - 新的 HTML 内容 (string)
    -- 返回: boolean - 是否成功
    -- ==========================================
    sl.log.info("[2] sl.ui.update_html() - 更新已注入的 HTML")
    local ok2 = sl.ui.update_html("ui-demo-banner",
        '<div id="ui-demo-banner" style="padding:8px 16px;background:#16a34a;color:white;text-align:center;font-size:13px;">' ..
        'UI Demo 横幅已通过 update_html 更新为绿色' ..
        '</div>')
    sl.log.info("  update_html 结果: " .. tostring(ok2))
    sl.log.info("")

    -- ==========================================
    -- sl.ui.insert(placement, selector, html)
    -- 在指定位置插入 HTML
    -- 参数:
    --   placement - 插入位置: "before" | "after" | "prepend" | "append"
    --   selector  - CSS 选择器 (string)
    --   html      - HTML 内容 (string)
    -- 返回: boolean - 是否成功
    -- ==========================================
    sl.log.info("[3] sl.ui.insert() - 在指定位置插入 HTML")
    sl.log.info("  placement 可选值: before, after, prepend, append")
    sl.log.info("")

    -- ==========================================
    -- sl.ui.remove(selector)
    -- 移除匹配选择器的元素
    -- 参数: selector - CSS 选择器 (string)
    -- 返回: boolean - 是否成功
    -- ==========================================
    sl.log.info("[4] sl.ui.remove() - 移除元素")
    sl.log.info("")

    -- ==========================================
    -- sl.ui.hide(selector) / sl.ui.show(selector)
    -- 隐藏/显示匹配选择器的元素
    -- 参数: selector - CSS 选择器 (string)
    -- 返回: boolean - 是否成功
    -- ==========================================
    sl.log.info("[5] sl.ui.hide() / sl.ui.show() - 隐藏/显示元素")
    sl.log.info("")

    -- ==========================================
    -- sl.ui.disable(selector) / sl.ui.enable(selector)
    -- 禁用/启用匹配选择器的元素
    -- 参数: selector - CSS 选择器 (string)
    -- 返回: boolean - 是否成功
    -- ==========================================
    sl.log.info("[6] sl.ui.disable() / sl.ui.enable() - 禁用/启用元素")
    sl.log.info("")

    -- ==========================================
    -- sl.ui.set_style(selector, styles)
    -- 设置元素的内联样式
    -- 参数:
    --   selector - CSS 选择器 (string)
    --   styles   - 样式表 (table)
    -- 返回: boolean - 是否成功
    -- ==========================================
    sl.log.info("[7] sl.ui.set_style() - 设置元素样式")
    sl.log.info("")

    -- ==========================================
    -- sl.ui.set_attribute(selector, attr, value)
    -- 设置元素属性
    -- 参数:
    --   selector - CSS 选择器 (string)
    --   attr     - 属性名 (string)
    --   value    - 属性值 (string)
    -- 返回: boolean - 是否成功
    -- ==========================================
    sl.log.info("[8] sl.ui.set_attribute() - 设置元素属性")
    sl.log.info("")

    -- ==========================================
    -- sl.ui.query(selector)
    -- 查询匹配选择器的元素信息
    -- 参数: selector - CSS 选择器 (string)
    -- 返回: table - 匹配元素的信息数组
    -- ==========================================
    sl.log.info("[9] sl.ui.query() - 查询元素信息")
    sl.log.info("")

    -- ==========================================
    -- sl.ui.register_context_menu(context, items)
    -- 注册右键菜单项
    -- 参数:
    --   context - 菜单上下文标识 (string)
    --   items   - 菜单项数组 [{id, label}]
    -- ==========================================
    sl.log.info("[10] sl.ui.register_context_menu() - 注册右键菜单")
    sl.ui.register_context_menu("global", {
        { id = "ui-demo-action", label = "UI Demo 测试菜单项" }
    })
    sl.log.info("  已注册全局右键菜单项")
    sl.log.info("")

    -- ==========================================
    -- sl.ui.on_context_menu_show(callback)
    -- 监听右键菜单显示事件
    -- 参数: callback(context, target_data)
    -- ==========================================
    sl.log.info("[11] sl.ui.on_context_menu_show() - 监听菜单显示")
    sl.ui.on_context_menu_show(function(context, target_data)
        sl.log.info("[UI Demo] 右键菜单显示: context=" .. tostring(context))
    end)
    sl.log.info("  已注册菜单显示回调")
    sl.log.info("")

    -- ==========================================
    -- sl.ui.on_context_menu_click(callback)
    -- 监听右键菜单点击事件
    -- 参数: callback(context, item_id, target_data)
    -- ==========================================
    sl.log.info("[12] sl.ui.on_context_menu_click() - 监听菜单点击")
    sl.ui.on_context_menu_click(function(context, item_id, target_data)
        sl.log.info("[UI Demo] 菜单点击: context=" .. tostring(context) .. " item=" .. tostring(item_id))
    end)
    sl.log.info("  已注册菜单点击回调")
    sl.log.info("")

    -- ==========================================
    -- sl.ui.unregister_context_menu(context)
    -- 注销右键菜单
    -- 参数: context - 菜单上下文标识 (string)
    -- ==========================================
    sl.log.info("[13] sl.ui.unregister_context_menu() - 注销右键菜单")
    sl.log.info("  将在 onDisable 中调用")
    sl.log.info("")

    sl.log.info("========== [UI Demo] 演示完成 ==========")
end

-- 插件禁用时调用
function plugin.onDisable()
    -- 移除注入的 HTML
    sl.ui.remove_html("ui-demo-banner")
    -- 注销右键菜单
    sl.ui.unregister_context_menu("global")
    sl.log.info("[UI Demo] 插件已禁用，已清理注入内容和右键菜单")
end

return plugin
