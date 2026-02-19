-- Log API 示例插件
-- 展示 sl.log 命名空间下所有日志方法的用法

local plugin = {}

-- 插件启用时调用
function plugin.onEnable()
    sl.log.info(sl.i18n.t("log-demo.enable.title"))

    -- sl.log.debug(message)
    -- 输出调试级别日志，需要 log 权限才能显示
    -- 用于开发调试时输出详细信息
    sl.log.debug(sl.i18n.t("log-demo.log.debugMessage"))

    -- sl.log.info(message)
    -- 输出信息级别日志，始终可用
    -- 用于输出一般性信息
    sl.log.info(sl.i18n.t("log-demo.log.infoMessage"))

    -- sl.log.warn(message)
    -- 输出警告级别日志，始终可用
    -- 用于提示潜在问题或需要注意的情况
    sl.log.warn(sl.i18n.t("log-demo.log.warnMessage"))

    -- sl.log.error(message)
    -- 输出错误级别日志，始终可用
    -- 用于报告错误或异常情况
    sl.log.error(sl.i18n.t("log-demo.log.errorMessage"))

    -- 实际应用示例：记录插件状态
    sl.log.info(sl.i18n.t("log-demo.plugin.id") .. PLUGIN_ID)
    sl.log.info(sl.i18n.t("log-demo.plugin.directory") .. PLUGIN_DIR)

    -- 实际应用示例：条件日志
    local debug_mode = true
    if debug_mode then
        sl.log.debug(sl.i18n.t("log-demo.log.debugModeEnabled"))
    end

    -- 实际应用示例：格式化日志
    local player_count = 10
    local max_players = 20
    sl.log.info(sl.i18n.t("log-demo.log.currentPlayers", { current = player_count, max = max_players }))

    sl.log.info(sl.i18n.t("log-demo.demoComplete"))
end

-- 插件禁用时调用
function plugin.onDisable()
    sl.log.warn(sl.i18n.t("log-demo.disable.inProgress"))
    sl.log.info(sl.i18n.t("log-demo.disable.complete"))
end

return plugin
