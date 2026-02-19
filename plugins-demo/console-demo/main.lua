-- Console API 示例插件
-- 展示 sl.console 命名空间下所有控制台操作方法的用法
-- 用于与 Minecraft 服务器控制台交互

local plugin = {}

-- 插件启用时调用
function plugin.onEnable()
    sl.log.info(sl.i18n.t("console-demo.enable.title"))

    -- 首先获取服务器列表
    local servers = sl.server.list()

    if #servers == 0 then
        sl.log.warn(sl.i18n.t("console-demo.enable.no_servers"))
        sl.log.info(sl.i18n.t("console-demo.enable.demo_end"))
        return
    end

    -- 使用第一个服务器进行演示
    local server_id = servers[1].id
    sl.log.info("Use server '" .. server_id .. "' for demo")
    sl.log.info("")

    -- sl.console.get_status(server_id)
    -- 获取服务器运行状态
    -- 参数: server_id - 服务器 ID
    -- 返回: string - 状态值: "running", "stopped", "starting", "stopping", "error"
    sl.log.info(sl.i18n.t("console-demo.console.status"))
    local ok, status = pcall(function()
        return sl.console.get_status(server_id)
    end)

    if ok then
        sl.log.info(sl.i18n.t("console-demo.console.server_status") .. tostring(status))

        -- 根据状态显示说明
        local status_desc = {
            running = sl.i18n.t("console-demo.console.status_running"),
            stopped = sl.i18n.t("console-demo.console.status_stopped"),
            starting = sl.i18n.t("console-demo.console.status_starting"),
            stopping = sl.i18n.t("console-demo.console.status_stopping"),
            error = sl.i18n.t("console-demo.console.status_error")
        }
        sl.log.info(sl.i18n.t("console-demo.console.status_desc") .. (status_desc[status] or sl.i18n.t("console-demo.console.status_unknown")))
    else
        sl.log.warn(sl.i18n.t("console-demo.console.status_failed") .. tostring(status))
    end

    -- sl.console.get_logs(server_id, count)
    -- 获取服务器控制台日志
    -- 参数: server_id - 服务器 ID, count - 获取的日志条数 (可选，默认 100)
    -- 返回: table - 日志行数组
    sl.log.info("")
    sl.log.info(sl.i18n.t("console-demo.console.logs"))
    local ok, logs = pcall(function()
        return sl.console.get_logs(server_id, 10)
    end)

    if ok and logs then
        if #logs == 0 then
            sl.log.info(sl.i18n.t("console-demo.console.no_logs"))
        else
            for i, line in ipairs(logs) do
                -- 截断过长的日志行
                local display_line = line
                if #display_line > 80 then
                    display_line = display_line:sub(1, 77) .. "..."
                end
                sl.log.info("  " .. tostring(i) .. ". " .. display_line)
            end
        end
    else
        sl.log.warn(sl.i18n.t("console-demo.console.logs_failed") .. tostring(logs))
    end

    -- sl.console.send(server_id, command)
    -- 向服务器控制台发送命令
    -- 参数: server_id - 服务器 ID, command - 要执行的命令
    -- 返回: boolean - 是否发送成功
    -- 注意: 只有在服务器运行时才能发送命令
    sl.log.info("")
    sl.log.info(sl.i18n.t("console-demo.console.send"))

    -- 检查服务器是否运行
    local current_status = sl.console.get_status(server_id)
    if current_status == "running" then
        sl.log.info(sl.i18n.t("console-demo.console.trying_send"))

        -- 发送一个安全的命令 (list 命令列出在线玩家)
        local ok, result = pcall(function()
            return sl.console.send(server_id, "list")
        end)

        if ok then
            sl.log.info(sl.i18n.t("console-demo.console.send_success"))
            sl.log.info(sl.i18n.t("console-demo.console.send_result_hint"))
        else
            sl.log.warn(sl.i18n.t("console-demo.console.send_failed") .. tostring(result))
        end

        -- 演示其他常用命令 (仅显示，不实际执行)
        sl.log.info("")
        sl.log.info(sl.i18n.t("console-demo.console.other_commands"))
        sl.log.info("    sl.console.send(server_id, 'say Hello from plugin!')")
        sl.log.info("    sl.console.send(server_id, 'time set day')")
        sl.log.info("    sl.console.send(server_id, 'weather clear')")
        sl.log.info("    sl.console.send(server_id, 'tp @a 0 100 0')")
    else
        sl.log.warn(sl.i18n.t("console-demo.console.not_running", { status = current_status }))
        sl.log.info(sl.i18n.t("console-demo.console.not_running_hint"))
    end

    sl.log.info("")
    sl.log.info(sl.i18n.t("console-demo.demo_complete"))
end

-- 插件禁用时调用
function plugin.onDisable()
    sl.log.info(sl.i18n.t("console-demo.disable.complete"))
end

return plugin
