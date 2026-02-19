-- I18n API 示例插件
-- 展示 sl.i18n 命名空间下所有国际化方法的实际用法
-- 注意: sl.i18n 不需要额外权限，所有插件均可使用

local plugin = {}

-- 插件启用时调用
function plugin.onEnable()
    sl.log.info("========== [I18n Demo] 插件已启用 ==========")
    sl.log.info("")

    -- ==========================================
    -- sl.i18n.getLocale()
    -- 获取当前语言代码
    -- 返回: string - 如 "zh-CN", "en-US", "zh-TW" 等
    -- ==========================================
    sl.log.info("[1] sl.i18n.getLocale() - 获取当前语言")
    local locale = sl.i18n.getLocale()
    sl.log.info("  当前语言: " .. tostring(locale))
    sl.log.info("")

    -- ==========================================
    -- sl.i18n.t(key)
    -- 获取翻译文本
    -- 参数: key - 翻译键 (string)，格式为 "插件ID.分类.键名"
    -- 返回: string - 翻译后的文本，未找到时返回 key 本身
    -- ==========================================
    sl.log.info("[2] sl.i18n.t(key) - 基本翻译")

    -- 使用已有的翻译键演示
    local text = sl.i18n.t("i18n-demo.test.hello")
    sl.log.info("  t('i18n-demo.test.hello') = " .. tostring(text))

    -- 翻译键不存在时返回 key 本身
    local missing = sl.i18n.t("i18n-demo.test.nonexistent_key")
    sl.log.info("  t('i18n-demo.test.nonexistent_key') = " .. tostring(missing))
    sl.log.info("  (不存在的 key 会原样返回)")
    sl.log.info("")

    -- ==========================================
    -- sl.i18n.t(key, options)
    -- 获取翻译文本并替换变量
    -- 参数:
    --   key     - 翻译键 (string)
    --   options - 变量替换表 (table)，如 {name = "值"}
    -- 返回: string - 替换变量后的翻译文本
    -- 翻译文本中使用 {变量名} 作为占位符
    -- ==========================================
    sl.log.info("[3] sl.i18n.t(key, options) - 带变量替换的翻译")

    local greeting = sl.i18n.t("i18n-demo.test.greeting", { name = "SeaLantern" })
    sl.log.info("  t('i18n-demo.test.greeting', {name='SeaLantern'}) = " .. tostring(greeting))

    local count_msg = sl.i18n.t("i18n-demo.test.count", { count = "42" })
    sl.log.info("  t('i18n-demo.test.count', {count='42'}) = " .. tostring(count_msg))
    sl.log.info("")

    -- ==========================================
    -- sl.i18n.onLocaleChange(callback)
    -- 注册语言切换回调
    -- 参数: callback - 回调函数 function(new_locale)
    -- 当用户在设置中切换语言时触发
    -- 同一插件可多次注册，回调会追加而非覆盖
    -- ==========================================
    sl.log.info("[4] sl.i18n.onLocaleChange() - 监听语言切换")

    sl.i18n.onLocaleChange(function(new_locale)
        sl.log.info("[I18n Demo] 语言已切换为: " .. tostring(new_locale))
        -- 可以在这里重新加载翻译相关的 UI
    end)
    sl.log.info("  已注册语言切换回调")
    sl.log.info("  当用户切换语言时，回调将被触发")
    sl.log.info("")

    -- ==========================================
    -- 实际应用场景
    -- ==========================================
    sl.log.info("[实际应用场景]")
    sl.log.info("  - 插件 UI 文本多语言支持")
    sl.log.info("  - 根据语言调整日期/数字格式")
    sl.log.info("  - 动态切换语言时刷新插件界面")
    sl.log.info("  - 在日志中输出本地化消息")
    sl.log.info("")

    sl.log.info("[翻译键命名规范]")
    sl.log.info("  格式: 插件ID.分类.键名")
    sl.log.info("  示例: my-plugin.ui.title")
    sl.log.info("  翻译文件位于: src/locales/zh-CN.json, en-US.json 等")

    sl.log.info("")
    sl.log.info("========== [I18n Demo] 演示完成 ==========")
end

-- 插件禁用时调用
function plugin.onDisable()
    sl.log.info("[I18n Demo] 插件已禁用")
end

return plugin
