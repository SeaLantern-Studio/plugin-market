-- System API 示例插件
-- 展示 sl.system 命名空间下所有系统信息方法的实际用法

local plugin = {}

-- 格式化字节数为可读字符串
local function format_bytes(bytes)
    if bytes >= 1024 * 1024 * 1024 then
        return string.format("%.2f GB", bytes / (1024 * 1024 * 1024))
    elseif bytes >= 1024 * 1024 then
        return string.format("%.2f MB", bytes / (1024 * 1024))
    elseif bytes >= 1024 then
        return string.format("%.2f KB", bytes / 1024)
    else
        return tostring(bytes) .. " B"
    end
end

-- 插件启用时调用
function plugin.onEnable()
    sl.log.info("========== [System Demo] 插件已启用 ==========")
    sl.log.info("")

    -- ==========================================
    -- sl.system.get_os()
    -- 获取操作系统名称
    -- 返回: string - "windows", "macos", "linux"
    -- ==========================================
    sl.log.info("[1] sl.system.get_os() - 获取操作系统")
    local ok, os_name = pcall(function()
        return sl.system.get_os()
    end)
    if ok then
        sl.log.info("  操作系统: " .. tostring(os_name))
    else
        sl.log.error("  调用失败: " .. tostring(os_name))
    end
    sl.log.info("")

    -- ==========================================
    -- sl.system.get_arch()
    -- 获取系统架构
    -- 返回: string - "x86_64", "aarch64" 等
    -- ==========================================
    sl.log.info("[2] sl.system.get_arch() - 获取系统架构")
    local ok, arch = pcall(function()
        return sl.system.get_arch()
    end)
    if ok then
        sl.log.info("  系统架构: " .. tostring(arch))
    else
        sl.log.error("  调用失败: " .. tostring(arch))
    end
    sl.log.info("")

    -- ==========================================
    -- sl.system.get_app_version()
    -- 获取 SeaLantern 应用版本号
    -- 返回: string - 版本号如 "1.0.0"
    -- ==========================================
    sl.log.info("[3] sl.system.get_app_version() - 获取应用版本")
    local ok, version = pcall(function()
        return sl.system.get_app_version()
    end)
    if ok then
        sl.log.info("  SeaLantern 版本: " .. tostring(version))
    else
        sl.log.error("  调用失败: " .. tostring(version))
    end
    sl.log.info("")

    -- ==========================================
    -- sl.system.get_memory()
    -- 获取系统内存信息
    -- 返回: table - {total, used, free} (单位: 字节)
    -- ==========================================
    sl.log.info("[4] sl.system.get_memory() - 获取内存信息")
    local ok, mem = pcall(function()
        return sl.system.get_memory()
    end)
    if ok and mem then
        sl.log.info("  总内存: " .. format_bytes(mem.total))
        sl.log.info("  已使用: " .. format_bytes(mem.used))
        sl.log.info("  可用:   " .. format_bytes(mem.free))
        if mem.total > 0 then
            local usage = math.floor(mem.used / mem.total * 100)
            sl.log.info("  使用率: " .. tostring(usage) .. "%")
        end
    else
        sl.log.error("  调用失败: " .. tostring(mem))
    end
    sl.log.info("")

    -- ==========================================
    -- sl.system.get_cpu()
    -- 获取 CPU 信息
    -- 返回: table - {name, cores, usage}
    -- ==========================================
    sl.log.info("[5] sl.system.get_cpu() - 获取 CPU 信息")
    local ok, cpu = pcall(function()
        return sl.system.get_cpu()
    end)
    if ok and cpu then
        sl.log.info("  CPU 名称: " .. tostring(cpu.name or "未知"))
        sl.log.info("  核心数:   " .. tostring(cpu.cores or "未知"))
        sl.log.info("  使用率:   " .. tostring(cpu.usage or "未知") .. "%")
    else
        sl.log.error("  调用失败: " .. tostring(cpu))
    end
    sl.log.info("")

    -- ==========================================
    -- 实际应用场景示例
    -- ==========================================
    sl.log.info("[实际应用场景]")
    sl.log.info("  - 根据操作系统调整插件行为")
    sl.log.info("  - 显示系统资源使用情况")
    sl.log.info("  - 检查应用版本兼容性")
    sl.log.info("  - 优化内存使用策略")
    sl.log.info("  - 生成系统诊断报告")

    sl.log.info("")
    sl.log.info("========== [System Demo] 演示完成 ==========")
end

-- 插件禁用时调用
function plugin.onDisable()
    sl.log.info("[System Demo] 插件已禁用")
end

return plugin
