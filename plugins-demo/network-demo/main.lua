-- Network API 示例插件
-- 展示 sl.http 命名空间下所有网络请求方法的实际用法

local plugin = {}

-- 插件启用时调用
function plugin.onEnable()
    sl.log.info("========== [Network Demo] 插件已启用 ==========")
    sl.log.info("")

    -- ==========================================
    -- sl.http.get(url, options?)
    -- 发送 HTTP GET 请求
    -- 参数:
    --   url     - 请求 URL (string)
    --   options - 可选配置 {headers = {}, timeout = 30}
    -- 返回: response, err
    --   response: {status, body, headers}
    --   err: 错误信息字符串 (请求失败时)
    -- ==========================================
    sl.log.info("[1] sl.http.get() - GET 请求")
    local response, err = sl.http.get("https://httpbin.org/get")
    if response then
        sl.log.info("  状态码: " .. tostring(response.status))
        -- 截断过长的响应体
        local body_preview = response.body
        if #body_preview > 200 then
            body_preview = body_preview:sub(1, 200) .. "..."
        end
        sl.log.info("  响应体: " .. body_preview)
    else
        sl.log.warn("  请求失败: " .. tostring(err))
        sl.log.info("  (这可能是网络不可用，属于正常情况)")
    end
    sl.log.info("")

    -- 带自定义头和超时的 GET 请求
    sl.log.info("[2] sl.http.get() - 带 headers 和 timeout")
    local response2, err2 = sl.http.get("https://httpbin.org/headers", {
        headers = {
            ["Accept"] = "application/json",
            ["X-Custom-Header"] = "SeaLantern-Plugin"
        },
        timeout = 10
    })
    if response2 then
        sl.log.info("  状态码: " .. tostring(response2.status))
        local body_preview = response2.body
        if #body_preview > 200 then
            body_preview = body_preview:sub(1, 200) .. "..."
        end
        sl.log.info("  响应体: " .. body_preview)
    else
        sl.log.warn("  请求失败: " .. tostring(err2))
    end
    sl.log.info("")

    -- ==========================================
    -- sl.http.post(url, body, options?)
    -- 发送 HTTP POST 请求
    -- 参数:
    --   url     - 请求 URL (string)
    --   body    - 请求体 (string 或 table，table 会自动序列化为 JSON)
    --   options - 可选配置 {headers = {}, timeout = 30}
    -- 返回: response, err
    -- ==========================================
    sl.log.info("[3] sl.http.post() - POST JSON 数据")
    local response3, err3 = sl.http.post("https://httpbin.org/post", {
        name = "SeaLantern",
        version = "1.0",
        type = "plugin-test"
    })
    if response3 then
        sl.log.info("  状态码: " .. tostring(response3.status))
        local body_preview = response3.body
        if #body_preview > 200 then
            body_preview = body_preview:sub(1, 200) .. "..."
        end
        sl.log.info("  响应体: " .. body_preview)
    else
        sl.log.warn("  请求失败: " .. tostring(err3))
    end
    sl.log.info("")

    -- POST 字符串数据
    sl.log.info("[4] sl.http.post() - POST 字符串数据")
    local response4, err4 = sl.http.post("https://httpbin.org/post", "key=value&foo=bar", {
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded"
        }
    })
    if response4 then
        sl.log.info("  状态码: " .. tostring(response4.status))
    else
        sl.log.warn("  请求失败: " .. tostring(err4))
    end
    sl.log.info("")

    -- ==========================================
    -- sl.http.put(url, body, options?)
    -- 发送 HTTP PUT 请求
    -- 参数同 post
    -- ==========================================
    sl.log.info("[5] sl.http.put() - PUT 请求")
    local response5, err5 = sl.http.put("https://httpbin.org/put", {
        updated = true,
        message = "Hello from SeaLantern plugin"
    })
    if response5 then
        sl.log.info("  状态码: " .. tostring(response5.status))
    else
        sl.log.warn("  请求失败: " .. tostring(err5))
    end
    sl.log.info("")

    -- ==========================================
    -- sl.http.delete(url, options?)
    -- 发送 HTTP DELETE 请求
    -- 参数:
    --   url     - 请求 URL (string)
    --   options - 可选配置 {headers = {}, timeout = 30}
    -- 返回: response, err
    -- ==========================================
    sl.log.info("[6] sl.http.delete() - DELETE 请求")
    local response6, err6 = sl.http.delete("https://httpbin.org/delete")
    if response6 then
        sl.log.info("  状态码: " .. tostring(response6.status))
    else
        sl.log.warn("  请求失败: " .. tostring(err6))
    end
    sl.log.info("")

    -- ==========================================
    -- 实际应用场景
    -- ==========================================
    sl.log.info("[实际应用场景]")
    sl.log.info("  - 查询 Minecraft 服务器在线状态")
    sl.log.info("  - 获取玩家皮肤/头像")
    sl.log.info("  - 与第三方服务集成 (Discord, Webhook 等)")
    sl.log.info("  - 下载远程配置或资源")
    sl.log.info("  - 上报统计数据")

    sl.log.info("")
    sl.log.info("========== [Network Demo] 演示完成 ==========")
end

-- 插件禁用时调用
function plugin.onDisable()
    sl.log.info("[Network Demo] 插件已禁用")
end

return plugin
