local plugin = {}

function plugin.onEnable()
    -- 注册插件翻译
    sl.i18n.addTranslations("zh-CN", {
        ["context-menu-demo.plugin.enabled"]           = "[右键菜单示例] 插件已启用",
        ["context-menu-demo.plugin.disabled"]          = "[右键菜单示例] 插件已禁用",
        ["context-menu-demo.contextMenu.testItem"]     = "测试菜单项",
        ["context-menu-demo.callback.menuShown"]       = "[右键菜单示例] 菜单已显示 - 上下文: {context}, 目标: {target}",
        ["context-menu-demo.callback.globalMenuShown"] = "[右键菜单示例] 全局菜单已显示",
        ["context-menu-demo.callback.menuClicked"]     = "[右键菜单示例] 菜单项被点击 - 上下文: {context}, 项: {item}, 目标: {target}",
        ["context-menu-demo.callback.testItemClicked"] = "[右键菜单示例] 测试菜单项被点击！",
    })
    sl.i18n.addTranslations("en-US", {
        ["context-menu-demo.plugin.enabled"]           = "[Context Menu Demo] Plugin enabled",
        ["context-menu-demo.plugin.disabled"]          = "[Context Menu Demo] Plugin disabled",
        ["context-menu-demo.contextMenu.testItem"]     = "Test Menu Item",
        ["context-menu-demo.callback.menuShown"]       = "[Context Menu Demo] Menu shown - context: {context}, target: {target}",
        ["context-menu-demo.callback.globalMenuShown"] = "[Context Menu Demo] Global menu shown",
        ["context-menu-demo.callback.menuClicked"]     = "[Context Menu Demo] Item clicked - context: {context}, item: {item}, target: {target}",
        ["context-menu-demo.callback.testItemClicked"] = "[Context Menu Demo] Test item clicked!",
    })

    sl.log.info(sl.i18n.t("context-menu-demo.plugin.enabled"))

    -- 注册全局右键菜单
    sl.ui.register_context_menu("global", {
        { id = "test", label = sl.i18n.t("context-menu-demo.contextMenu.testItem") }
    })

    -- 注册菜单显示回调
    sl.ui.on_context_menu_show(function(context, target_data)
        sl.log.info(sl.i18n.t("context-menu-demo.callback.menuShown", { context = context, target = tostring(target_data) }))
        if context == "global" then
            sl.log.info(sl.i18n.t("context-menu-demo.callback.globalMenuShown"))
        end
    end)

    -- 注册菜单点击回调
    sl.ui.on_context_menu_click(function(context, item_id, target_data)
        sl.log.info(sl.i18n.t("context-menu-demo.callback.menuClicked", { context = context, item = item_id, target = tostring(target_data) }))

        if context == "global" then
            if item_id == "test" then
                sl.log.info(sl.i18n.t("context-menu-demo.callback.testItemClicked"))
            end
        end
    end)
end

function plugin.onDisable()
    sl.ui.unregister_context_menu("global")
    sl.log.info(sl.i18n.t("context-menu-demo.plugin.disabled"))
end

return plugin
