-- API 跨插件通信示例插件
-- 展示 sl.api 命名空间下所有跨插件通信方法的实际用法

local plugin = {}

-- 插件启用时调用
function plugin.onEnable()
    sl.log.info("========== [API Demo] 插件已启用 ==========")
    sl.log.info("")

    -- ==========================================
    -- sl.api.register(api_name, handler)
    -- 注册一个 API 供其他插件调用
    -- 参数:
    --   api_name - API 名称 (string)
    --   handler  - 处理函数，接收参数并返回结果
    -- ==========================================
    sl.log.info("[1] sl.api.register() - 注册 API")

    -- 注册一个简单的 greet API
    sl.api.register("greet", function(name)
        return "Hello, " .. tostring(name) .. "! From api-demo plugin."
    end)
    sl.log.info("  已注册 API: greet(name)")

    -- 注册一个计算 API
    sl.api.register("add", function(a, b)
        return (tonumber(a) or 0) + (tonumber(b) or 0)
    end)
    sl.log.info("  已注册 API: add(a, b)")

    -- 注册一个返回插件信息的 API
    sl.api.register("get_info", function()
        return {
            name = "API Demo",
            version = "1.0.0",
            description = "跨插件通信示例"
        }
    end)
    sl.log.info("  已注册 API: get_info()")
    sl.log.info("")

    -- ==========================================
    -- sl.api.has(target_plugin, api_name)
    -- 检查目标插件是否注册了指定 API
    -- 参数:
    --   target_plugin - 目标插件 ID (string)
    --   api_name      - API 名称 (string)
    -- 返回: boolean
    -- ==========================================
    sl.log.info("[2] sl.api.has() - 检查 API 是否存在")

    local has_greet = sl.api.has("api-demo", "greet")
    sl.log.info("  api-demo.greet 存在: " .. tostring(has_greet))

    local has_unknown = sl.api.has("api-demo", "unknown_api")
    sl.log.info("  api-demo.unknown_api 存在: " .. tostring(has_unknown))

    local has_other = sl.api.has("non-existent-plugin", "some_api")
    sl.log.info("  non-existent-plugin.some_api 存在: " .. tostring(has_other))
    sl.log.info("")

    -- ==========================================
    -- sl.api.list(target_plugin)
    -- 列出目标插件注册的所有 API
    -- 参数: target_plugin - 目标插件 ID (string)
    -- 返回: table - API 名称数组
    -- ==========================================
    sl.log.info("[3] sl.api.list() - 列出插件的所有 API")

    local apis = sl.api.list("api-demo")
    if apis and #apis > 0 then
        sl.log.info("  api-demo 注册的 API:")
        for i, name in ipairs(apis) do
            sl.log.info("    " .. tostring(i) .. ". " .. tostring(name))
        end
    else
        sl.log.info("  api-demo 没有注册任何 API")
    end
    sl.log.info("")

    -- ==========================================
    -- sl.api.call(target_plugin, api_name, ...)
    -- 调用其他插件注册的 API
    -- 参数:
    --   target_plugin - 目标插件 ID (string)
    --   api_name      - API 名称 (string)
    --   ...           - 传递给 API 的参数
    -- 返回: API 的返回值，或 nil (API 不存在时)
    -- ==========================================
    sl.log.info("[4] sl.api.call() - 调用 API")

    -- 调用自己注册的 greet API
    local result = sl.api.call("api-demo", "greet", "SeaLantern")
    sl.log.info("  greet('SeaLantern') = " .. tostring(result))

    -- 调用自己注册的 add API
    local sum = sl.api.call("api-demo", "add", 10, 20)
    sl.log.info("  add(10, 20) = " .. tostring(sum))

    -- 调用不存在的 API（返回 nil）
    local nil_result = sl.api.call("api-demo", "non_existent")
    sl.log.info("  non_existent() = " .. tostring(nil_result) .. " (API 不存在时返回 nil)")
    sl.log.info("")

    -- ==========================================
    -- 跨插件通信场景说明
    -- ==========================================
    sl.log.info("[跨插件通信场景]")
    sl.log.info("  其他插件可以这样调用本插件的 API:")
    sl.log.info("    local msg = sl.api.call('api-demo', 'greet', '玩家名')")
    sl.log.info("    local sum = sl.api.call('api-demo', 'add', 1, 2)")
    sl.log.info("    local info = sl.api.call('api-demo', 'get_info')")
    sl.log.info("")
    sl.log.info("  调用前可先检查 API 是否可用:")
    sl.log.info("    if sl.api.has('api-demo', 'greet') then")
    sl.log.info("        local msg = sl.api.call('api-demo', 'greet', 'test')")
    sl.log.info("    end")

    sl.log.info("")
    sl.log.info("========== [API Demo] 演示完成 ==========")
end

-- 插件禁用时调用
function plugin.onDisable()
    sl.log.info("[API Demo] 插件已禁用，注册的 API 将自动注销")
end

return plugin
