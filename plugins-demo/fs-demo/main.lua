-- FS API 示例插件
-- 展示 sl.fs 命名空间下所有文件系统操作方法的用法
-- 注意: 所有路径都相对于插件目录，不能访问插件目录外的文件

local plugin = {}

-- 插件启用时调用
function plugin.onEnable()
    sl.log.info("========== " .. sl.i18n.t("fs-demo.plugin.enabled") .. " ==========")

    -- 测试文件路径
    local test_file = "test.txt"
    local test_dir = "test_dir"
    local test_subfile = "test_dir/subfile.txt"

    -- sl.fs.mkdir(path)
    -- 创建目录，支持递归创建
    -- 参数: path - 相对于插件目录的路径
    sl.log.info("[mkdir] " .. sl.i18n.t("fs-demo.mkdir.creating", { path = test_dir }))
    local ok, err = pcall(function()
        sl.fs.mkdir(test_dir)
    end)
    if ok then
        sl.log.info("[mkdir] " .. sl.i18n.t("fs-demo.mkdir.success"))
    else
        sl.log.warn("[mkdir] " .. sl.i18n.t("fs-demo.mkdir.exists", { error = tostring(err) }))
    end

    -- sl.fs.write(path, content)
    -- 写入文本文件
    -- 参数: path - 文件路径, content - 文件内容
    sl.log.info("[write] " .. sl.i18n.t("fs-demo.write.file", { path = test_file }))
    sl.fs.write(test_file, "Hello, SeaLantern!\n" .. sl.i18n.t("fs-demo.write.content"))
    sl.log.info("[write] " .. sl.i18n.t("fs-demo.write.success"))

    -- 写入子目录中的文件
    sl.log.info("[write] " .. sl.i18n.t("fs-demo.write.subfile", { path = test_subfile }))
    sl.fs.write(test_subfile, sl.i18n.t("fs-demo.write.subfile_content"))

    -- sl.fs.exists(path)
    -- 检查文件或目录是否存在
    -- 参数: path - 文件或目录路径
    -- 返回: boolean
    sl.log.info("[exists] " .. sl.i18n.t("fs-demo.exists.check_file", { path = test_file }))
    local exists = sl.fs.exists(test_file)
    sl.log.info("[exists] " .. sl.i18n.t("fs-demo.exists.file_result", { exists = tostring(exists) }))

    sl.log.info("[exists] " .. sl.i18n.t("fs-demo.exists.check_dir", { path = test_dir }))
    local dir_exists = sl.fs.exists(test_dir)
    sl.log.info("[exists] " .. sl.i18n.t("fs-demo.exists.dir_result", { exists = tostring(dir_exists) }))

    -- sl.fs.read(path)
    -- 读取文本文件内容
    -- 参数: path - 文件路径
    -- 返回: string - 文件内容
    sl.log.info("[read] " .. sl.i18n.t("fs-demo.read.file", { path = test_file }))
    local content = sl.fs.read(test_file)
    sl.log.info("[read] " .. sl.i18n.t("fs-demo.read.content") .. "\n" .. content)

    -- sl.fs.list(path)
    -- 列出目录内容
    -- 参数: path - 目录路径 (可选，默认为插件根目录 ".")
    -- 返回: table - 文件和目录名列表
    sl.log.info("[list] " .. sl.i18n.t("fs-demo.list.root"))
    local files = sl.fs.list(".")
    for i, name in ipairs(files) do
        sl.log.info("  " .. tostring(i) .. ". " .. name)
    end

    sl.log.info("[list] " .. sl.i18n.t("fs-demo.list.subdir", { path = test_dir }))
    local subfiles = sl.fs.list(test_dir)
    for i, name in ipairs(subfiles) do
        sl.log.info("  " .. tostring(i) .. ". " .. name)
    end

    -- sl.fs.info(path)
    -- 获取文件信息
    -- 参数: path - 文件路径
    -- 返回: table - 包含 size, is_file, is_dir 等信息
    sl.log.info("[info] " .. sl.i18n.t("fs-demo.info.get", { path = test_file }))
    local info = sl.fs.info(test_file)
    if info then
        sl.log.info("  " .. sl.i18n.t("fs-demo.info.size", { size = tostring(info.size) }))
        sl.log.info("  " .. sl.i18n.t("fs-demo.info.is_file", { is_file = tostring(info.is_file) }))
        sl.log.info("  " .. sl.i18n.t("fs-demo.info.is_dir", { is_dir = tostring(info.is_dir) }))
    end

    -- sl.fs.read_binary(path)
    -- 读取二进制文件，返回 base64 编码
    -- 参数: path - 文件路径
    -- 返回: string - base64 编码的文件内容
    sl.log.info("[read_binary] " .. sl.i18n.t("fs-demo.read_binary.file", { path = test_file }))
    local binary_content = sl.fs.read_binary(test_file)
    sl.log.info("[read_binary] " .. sl.i18n.t("fs-demo.read_binary.length", { length = tostring(#binary_content) }))

    -- sl.fs.remove(path)
    -- 删除文件 (不能删除目录)
    -- 参数: path - 文件路径
    sl.log.info("[remove] " .. sl.i18n.t("fs-demo.remove.file", { path = test_subfile }))
    sl.fs.remove(test_subfile)
    sl.log.info("[remove] " .. sl.i18n.t("fs-demo.remove.success"))

    -- 验证删除
    local still_exists = sl.fs.exists(test_subfile)
    sl.log.info("[exists] " .. sl.i18n.t("fs-demo.exists.after_remove", { exists = tostring(still_exists) }))

    sl.log.info("========== " .. sl.i18n.t("fs-demo.plugin.completed") .. " ==========")
end

-- 插件禁用时调用
function plugin.onDisable()
    sl.log.info(sl.i18n.t("fs-demo.plugin.disabling"))

    -- 清理测试文件
    local test_file = "test.txt"
    if sl.fs.exists(test_file) then
        sl.fs.remove(test_file)
        sl.log.info(sl.i18n.t("fs-demo.plugin.cleaned", { path = test_file }))
    end

    sl.log.info(sl.i18n.t("fs-demo.plugin.disabled"))
end

return plugin
