-- Server API 示例插件
-- 展示 sl.server 命名空间下所有服务器操作方法的用法
-- 用于访问和管理 Minecraft 服务器目录中的文件

local plugin = {}

-- 插件启用时调用
function plugin.onEnable()
    sl.log.info("========== " .. sl.i18n.t("server-demo.plugin.enabled") .. " ==========")

    -- sl.server.list()
    -- 获取所有服务器列表
    -- 返回: table - 服务器信息数组 [{id, name, path, version, server_type}]
    sl.log.info("[list] " .. sl.i18n.t("server-demo.server.list"))

    local servers = sl.server.list()

    if #servers == 0 then
        sl.log.warn(sl.i18n.t("server-demo.server.noServers"))
        sl.log.info("========== " .. sl.i18n.t("server-demo.plugin.demoEnd") .. " ==========")
        return
    end

    for i, server in ipairs(servers) do
        sl.log.info("  " .. sl.i18n.t("server-demo.server.index", { index = tostring(i) }) .. ":")
        sl.log.info("    ID: " .. tostring(server.id))
        sl.log.info("    " .. sl.i18n.t("server-demo.server.name") .. ": " .. tostring(server.name))
        sl.log.info("    " .. sl.i18n.t("server-demo.server.path") .. ": " .. tostring(server.path))
        sl.log.info("    " .. sl.i18n.t("server-demo.server.version") .. ": " .. tostring(server.version or sl.i18n.t("server-demo.server.unknown")))
        sl.log.info("    " .. sl.i18n.t("server-demo.server.type") .. ": " .. tostring(server.server_type or sl.i18n.t("server-demo.server.unknown")))
    end

    -- 使用第一个服务器进行演示
    local server_id = servers[1].id
    sl.log.info("")
    sl.log.info(sl.i18n.t("server-demo.server.useForDemo", { serverId = server_id }))

    -- sl.server.get_path(server_id)
    -- 获取服务器目录的完整路径
    -- 参数: server_id - 服务器 ID
    -- 返回: string - 服务器目录路径
    sl.log.info("")
    sl.log.info("[get_path] " .. sl.i18n.t("server-demo.server.getPath"))
    local path = sl.server.get_path(server_id)
    sl.log.info("  " .. sl.i18n.t("server-demo.server.pathLabel") .. ": " .. tostring(path))

    -- sl.server.exists(server_id, relative_path)
    -- 检查服务器目录下的文件或目录是否存在
    -- 参数: server_id - 服务器 ID, relative_path - 相对路径
    -- 返回: boolean
    sl.log.info("")
    sl.log.info("[exists] " .. sl.i18n.t("server-demo.file.checkExists"))

    local files_to_check = {"server.properties", "eula.txt", "plugins", "world"}
    for _, file in ipairs(files_to_check) do
        local exists = sl.server.exists(server_id, file)
        sl.log.info("  " .. file .. ": " .. tostring(exists))
    end

    -- sl.server.list_dir(server_id, relative_path)
    -- 列出服务器目录下的文件和子目录
    -- 参数: server_id - 服务器 ID, relative_path - 相对路径
    -- 返回: table - 文件信息数组 [{name, is_dir, size}]
    sl.log.info("")
    sl.log.info("[list_dir] " .. sl.i18n.t("server-demo.file.listDir"))
    local ok, result = pcall(function()
        return sl.server.list_dir(server_id, ".")
    end)

    if ok and result then
        local count = 0
        for _, item in ipairs(result) do
            count = count + 1
            if count <= 10 then  -- 只显示前 10 个
                local type_str = item.is_dir and sl.i18n.t("server-demo.file.directory") or sl.i18n.t("server-demo.file.file")
                local size_str = item.is_dir and "" or (" (" .. tostring(item.size) .. " " .. sl.i18n.t("server-demo.file.bytes") .. ")")
                sl.log.info("  " .. type_str .. " " .. item.name .. size_str)
            end
        end
        if count > 10 then
            sl.log.info("  ... " .. sl.i18n.t("server-demo.file.moreItems", { count = tostring(count - 10) }))
        end
    else
        sl.log.warn("  " .. sl.i18n.t("server-demo.file.listDirError", { error = tostring(result) }))
    end

    -- sl.server.read_file(server_id, relative_path)
    -- 读取服务器目录下的文件内容 (最大 10MB)
    -- 参数: server_id - 服务器 ID, relative_path - 相对路径
    -- 返回: string - 文件内容
    sl.log.info("")
    sl.log.info("[read_file] " .. sl.i18n.t("server-demo.file.readProperties"))
    if sl.server.exists(server_id, "server.properties") then
        local ok, content = pcall(function()
            return sl.server.read_file(server_id, "server.properties")
        end)

        if ok and content then
            -- 只显示前几行
            local lines = {}
            for line in content:gmatch("[^\r\n]+") do
                table.insert(lines, line)
                if #lines >= 5 then break end
            end
            for _, line in ipairs(lines) do
                sl.log.info("  " .. line)
            end
            sl.log.info("  " .. sl.i18n.t("server-demo.file.moreContent"))
        else
            sl.log.warn("  " .. sl.i18n.t("server-demo.file.readError", { error = tostring(content) }))
        end
    else
        sl.log.warn("  " .. sl.i18n.t("server-demo.file.propertiesNotFound"))
    end

    -- sl.server.write_file(server_id, relative_path, content)
    -- 写入文件到服务器目录
    -- 参数: server_id - 服务器 ID, relative_path - 相对路径, content - 文件内容
    -- 返回: boolean - 是否成功
    sl.log.info("")
    sl.log.info("[write_file] " .. sl.i18n.t("server-demo.file.writeTest"))
    local test_file = "plugin_test.txt"
    local test_content = sl.i18n.t("server-demo.file.testContent")

    local ok, err = pcall(function()
        return sl.server.write_file(server_id, test_file, test_content)
    end)

    if ok then
        sl.log.info("  " .. sl.i18n.t("server-demo.file.writeSuccess", { file = test_file }))

        -- 验证写入
        if sl.server.exists(server_id, test_file) then
            sl.log.info("  " .. sl.i18n.t("server-demo.file.verifyExists"))

            -- 读取验证
            local read_content = sl.server.read_file(server_id, test_file)
            sl.log.info("  " .. sl.i18n.t("server-demo.file.verifyContent") .. " = " .. tostring(read_content == test_content))
        end
    else
        sl.log.warn("  " .. sl.i18n.t("server-demo.file.writeError", { error = tostring(err) }))
    end

    sl.log.info("")
    sl.log.info("========== " .. sl.i18n.t("server-demo.plugin.demoComplete") .. " ==========")
end

-- 插件禁用时调用
function plugin.onDisable()
    sl.log.info(sl.i18n.t("server-demo.plugin.disabled"))
end

return plugin
