local plugin = {}

-- i18n keys
local i18n_keys = {
    plugin_enabled = "context-menu-demo.plugin.enabled",
    register_global_menu = "context-menu-demo.contextMenu.registerGlobal",
    test_menu_item = "context-menu-demo.contextMenu.testItem",
    register_show_callback = "context-menu-demo.callback.registerShow",
    menu_shown = "context-menu-demo.callback.menuShown",
    global_menu_shown = "context-menu-demo.callback.globalMenuShown",
    register_click_callback = "context-menu-demo.callback.registerClick",
    menu_clicked = "context-menu-demo.callback.menuClicked",
    test_item_clicked = "context-menu-demo.callback.testItemClicked",
    plugin_disabled = "context-menu-demo.plugin.disabled"
}

function plugin.onEnable()
    sl.log.info(sl.i18n.t(i18n_keys.plugin_enabled))

    -- 注册全局右键菜单
    sl.ui.register_context_menu("global", {
        { id = "test", label = sl.i18n.t(i18n_keys.test_menu_item) }
    })

    -- 注册菜单显示回调
    sl.ui.on_context_menu_show(function(context, target_data)
        sl.log.info(sl.i18n.t(i18n_keys.menu_shown, { context = context, target = tostring(target_data) }))
        if context == "global" then
            sl.log.info(sl.i18n.t(i18n_keys.global_menu_shown))
        end
    end)

    -- 注册菜单点击回调
    sl.ui.on_context_menu_click(function(context, item_id, target_data)
        sl.log.info(sl.i18n.t(i18n_keys.menu_clicked, { context = context, item = item_id, target = tostring(target_data) }))

        if context == "global" then
            if item_id == "test" then
                sl.log.info(sl.i18n.t(i18n_keys.test_item_clicked))
            end
        end
    end)
end

function plugin.onDisable()
    sl.ui.unregister_context_menu("global")
    sl.log.info(sl.i18n.t(i18n_keys.plugin_disabled))
end

return plugin
