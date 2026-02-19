-- ============================================================
-- 音乐播放器插件 - SeaLantern 插件示例
-- ============================================================
-- 这个插件展示了如何通过 CSS 注入创建一个浮动的音乐播放器 UI
-- 主要演示：
--   1. 基本的生命周期钩子使用
--   2. 日志 API 的使用
--   3. 存储 API 保存播放状态和歌曲列表
--   4. 文件系统 API 扫描音乐目录
--   5. 可选依赖 theme-palette 的适配
--   6. i18n API 实现多语言支持
--
-- 版本 1.2.0 新增：
--   - 使用 sl.fs.list 扫描 music 目录获取真实歌曲列表
--   - 可选适配 theme-palette 插件，自动跟随主题色
--
-- 版本 1.2.0 新增：
--   - 使用 sl.i18n API 实现多语言支持
-- ============================================================

local plugin = {}

-- ============================================================
-- 翻译表
-- ============================================================
local translations = {
    -- UI 相关
    ["music-player.ui.unknownSong"] = "未知歌曲",
    ["music-player.ui.unknownArtist"] = "未知歌手",

    -- 日志消息 - 通用
    ["music-player.log.pluginLoading"] = "插件加载中...",
    ["music-player.log.versionInfo"] = "版本 1.3.0 - 支持 i18n 多语言",
    ["music-player.log.enabling"] = "正在启用...",
    ["music-player.log.scanningDirectory"] = "正在扫描音乐目录...",
    ["music-player.log.enableComplete"] = "启用完成！共 %d 首歌曲",
    ["music-player.log.disabling"] = "正在禁用...",
    ["music-player.log.uiRemoved"] = "悬浮播放器 UI 已移除",
    ["music-player.log.playbackStateSaved"] = "播放状态已保存",
    ["music-player.log.pluginUnloaded"] = "插件已卸载",

    -- 日志消息 - 目录扫描
    ["music-player.log.directoryNotExist"] = "music 目录不存在，使用默认歌曲列表",
    ["music-player.log.directoryEmpty"] = "music 目录为空，使用默认歌曲列表",
    ["music-player.log.songFound"] = "发现歌曲: %s - %s",
    ["music-player.log.noValidMp3"] = "未找到有效的 mp3 文件，使用默认歌曲列表",
    ["music-player.log.scanComplete"] = "扫描完成，共发现 %d 首歌曲",

    -- 日志消息 - 播放控制
    ["music-player.log.paused"] = "已暂停",
    ["music-player.log.startPlaying"] = "开始播放",
    ["music-player.log.switchedToSong"] = "切换到第 %d 首歌曲",

    -- 日志消息 - 主题适配
    ["music-player.log.apiNotEnabled"] = "API 权限未启用，跳过主题检测",
    ["music-player.log.detectingThemePalette"] = "检测到主题调色板插件，正在获取主题色...",
    ["music-player.log.primaryColor"] = "主色调: %s",
    ["music-player.log.backgroundColor"] = "背景色: %s",
    ["music-player.log.preset"] = "当前主题预设: %s",
    ["music-player.log.themeSynced"] = "主题色已同步，播放器将跟随主题调色板",
    ["music-player.log.noThemePalette"] = "未检测到主题调色板插件，使用默认配色",
    ["music-player.log.currentSong"] = "当前歌曲: %s - %s",
    ["music-player.log.themeEnabled"] = "主题适配: 已启用 (主色调: %s)",
    ["music-player.log.themeUsingDefault"] = "主题适配: 使用默认配色",

    -- 日志消息 - UI
    ["music-player.log.uiApiUnavailable"] = "UI API 不可用，无法注入悬浮播放器",
    ["music-player.log.uiInjected"] = "悬浮播放器 UI 已注入",
    ["music-player.log.uiInjectFailed"] = "悬浮播放器 UI 注入失败"
}

-- ============================================================
-- 翻译辅助函数
-- ============================================================
local function t(key, vars)
    if not sl.i18n then
        -- 如果 i18n 不可用，返回中文默认值
        local text = translations[key] or key
        if vars then
            for k, v in pairs(vars) do
                text = text:gsub("%%" .. k, tostring(v))
            end
        end
        return text
    end

    -- 使用 sl.i18n.t() 获取翻译
    local text = sl.i18n.t(key)

    -- 如果返回的 key 不存在（可能翻译表未加载），使用本地翻译表
    if text == key and translations[key] then
        text = translations[key]
    end

    -- 变量替换
    if vars then
        for k, v in pairs(vars) do
            text = text:gsub("%%" .. k, tostring(v))
        end
    end

    return text
end

-- ============================================================
-- 生成带前缀的日志消息
-- ============================================================
local function logWithPrefix(key, vars)
    local prefix = "[music-player] "
    local msg = t(key, vars)
    return prefix .. msg
end

-- ============================================================
-- 默认歌曲列表（当 music 目录为空或不存在时使用）
-- ============================================================
local defaultPlaylist = {}

-- ============================================================
-- 主题色配置（默认值，可被 theme-palette 覆盖）
-- ============================================================
local themeConfig = {
    primaryColor = "#64ffda",    -- 主色调
    backgroundColor = "#0a0e14", -- 背景色
    themePaletteAvailable = false -- 是否检测到 theme-palette
}

-- ============================================================
-- 缓存播放列表长度（避免在 nextSong/prevSong 中重复计算）
-- ============================================================
local playlistLength = 0
local currentPlaylist = {} -- 缓存当前播放列表，用于语言变化时重新初始化 UI

-- ============================================================
-- 辅助函数：URL 编码（处理中文和特殊字符）
-- ============================================================
local function urlEncode(str)
    if str then
        str = str:gsub("\n", "\r\n")
        str = str:gsub("([^%w%-%.%_%~%/])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
    end
    return str
end

-- ============================================================
-- 辅助函数：生成播放器 HTML
-- 使用与 style.css 匹配的类名，并包含音频播放功能
-- ============================================================
local function generatePlayerHtml(playlist, currentIndex, isPlaying, pluginDir)
    local song = playlist[currentIndex] or {
        name = t("music-player.ui.unknownSong"),
        artist = t("music-player.ui.unknownArtist"),
        filename = nil
    }
    local playingClass = isPlaying and "playing" or ""
    
    -- 构建音频源 URL（使用 Tauri v2 asset protocol）
    local audioSrc = ""
    if song.filename then
        -- 将 Windows 路径转换为 asset URL
        local fullPath = pluginDir .. "/music/" .. song.filename
        -- 替换反斜杠为正斜杠
        fullPath = fullPath:gsub("\\", "/")
        -- URL 编码路径（保留斜杠和冒号）
        local encodedPath = urlEncode(fullPath)
        -- Tauri v2 使用 http://asset.localhost/ 格式
        audioSrc = "http://asset.localhost/" .. encodedPath
    end
    
    -- 生成播放列表 JSON 供 JavaScript 使用
    local playlistJson = "["
    for i, s in ipairs(playlist) do
        if i > 1 then playlistJson = playlistJson .. "," end
        local fn = s.filename or ""
        local fp = ""
        if fn ~= "" then
            fp = pluginDir .. "/music/" .. fn
            fp = fp:gsub("\\", "/")
            fp = "http://asset.localhost/" .. urlEncode(fp)
        end
        playlistJson = playlistJson .. string.format(
            '{"name":"%s","artist":"%s","src":"%s"}',
            s.name:gsub('"', '\\"'):gsub("\\", "\\\\"), 
            s.artist:gsub('"', '\\"'):gsub("\\", "\\\\"),
            fp:gsub("\\", "\\\\")
        )
    end
    playlistJson = playlistJson .. "]"
    
    return string.format([[
<div class="music-player-container" id="music-player-widget">
    <audio id="music-player-audio" src="%s" preload="auto"></audio>
    <div class="music-player-disc %s" onclick="window.__musicPlayerToggle && window.__musicPlayerToggle()">
        <span class="music-player-icon">%s</span>
    </div>
    <div class="music-player-info">
        <div class="song-name">%s</div>
        <div class="song-artist">%s</div>
    </div>
    <div class="music-player-controls">
        <button class="music-player-btn" onclick="window.__musicPlayerPrev && window.__musicPlayerPrev()">&#9664;&#9664;</button>
        <button class="music-player-btn" onclick="window.__musicPlayerNext && window.__musicPlayerNext()">&#9654;&#9654;</button>
    </div>
    <div class="music-player-progress">
        <div class="music-player-progress-bar" id="music-player-progress-bar"></div>
    </div>
    <script>
    (function() {
        var playlist = %s;
        var currentIndex = %d - 1;
        var audio = document.getElementById('music-player-audio');
        var disc = document.querySelector('.music-player-disc');
        var icon = document.querySelector('.music-player-icon');
        var progressBar = document.getElementById('music-player-progress-bar');
        var songName = document.querySelector('.music-player-info .song-name');
        var songArtist = document.querySelector('.music-player-info .song-artist');
        
        function updateUI() {
            var song = playlist[currentIndex];
            if (song) {
                songName.textContent = song.name;
                songArtist.textContent = song.artist;
            }
            if (audio.paused) {
                disc.classList.remove('playing');
                icon.innerHTML = '&#9654;';
            } else {
                disc.classList.add('playing');
                icon.innerHTML = '&#10074;&#10074;';
            }
        }
        
        function loadSong(index) {
            if (index >= 0 && index < playlist.length) {
                currentIndex = index;
                var song = playlist[currentIndex];
                if (song && song.src) {
                    audio.src = song.src;
                    audio.load();
                }
                updateUI();
            }
        }
        
        window.__musicPlayerToggle = function() {
            if (audio.paused) {
                audio.play().catch(function(e) { console.error('Play error:', e); });
            } else {
                audio.pause();
            }
            updateUI();
        };
        
        window.__musicPlayerNext = function() {
            var nextIndex = (currentIndex + 1) %% playlist.length;
            loadSong(nextIndex);
            audio.play().catch(function(e) { console.error('Play error:', e); });
        };
        
        window.__musicPlayerPrev = function() {
            var prevIndex = (currentIndex - 1 + playlist.length) %% playlist.length;
            loadSong(prevIndex);
            audio.play().catch(function(e) { console.error('Play error:', e); });
        };
        
        audio.addEventListener('play', updateUI);
        audio.addEventListener('pause', updateUI);
        audio.addEventListener('ended', function() {
            window.__musicPlayerNext();
        });
        audio.addEventListener('timeupdate', function() {
            if (audio.duration) {
                var percent = (audio.currentTime / audio.duration) * 100;
                progressBar.style.width = percent + '%%';
            }
        });
        
        updateUI();
    })();
    </script>
</div>
]], audioSrc, playingClass, isPlaying and "&#10074;&#10074;" or "&#9654;", 
    song.name, song.artist, playlistJson, currentIndex)
end

-- ============================================================
-- 辅助函数：注入播放器 UI
-- ============================================================
local function injectPlayerUi(playlist)
    if not sl.ui then
        sl.log.warn(logWithPrefix("music-player.log.uiApiUnavailable"))
        return false
    end

    local currentIndex = tonumber(sl.storage.get("current_index")) or 1
    local isPlaying = sl.storage.get("is_playing") == "true"

    -- 获取插件目录路径
    local pluginDir = PLUGIN_DIR or ""

    local html = generatePlayerHtml(playlist, currentIndex, isPlaying, pluginDir)
    local success = sl.ui.inject_html("player", html)

    if success then
        sl.log.info(logWithPrefix("music-player.log.uiInjected"))
    else
        sl.log.error(logWithPrefix("music-player.log.uiInjectFailed"))
    end

    return success
end

-- ============================================================
-- 辅助函数：移除播放器 UI
-- ============================================================
local function removePlayerUi()
    if not sl.ui then
        return
    end

    sl.ui.remove_html("player")
    sl.log.info(logWithPrefix("music-player.log.uiRemoved"))
end

-- ============================================================
-- 辅助函数：从文件名解析歌曲信息
-- 支持格式：
--   - "歌曲名 - 歌手.mp3"
--   - "歌曲名.mp3"（歌手显示为"未知歌手"）
-- ============================================================
local function parseSongInfo(filename)
    -- 移除扩展名
    local name = filename:match("(.+)%.mp3$") or filename:match("(.+)%.MP3$")
    if not name then
        return nil
    end
    
    -- 尝试解析 "歌曲名 - 歌手" 格式
    local songName, artist = name:match("(.+)%s*[%-–—]%s*(.+)")
    if songName and artist then
        return {
            name = songName:match("^%s*(.-)%s*$"), -- 去除首尾空格
            artist = artist:match("^%s*(.-)%s*$"),
            duration = "0:00", -- 无法从文件名获取时长
            filename = filename
        }
    end
    
    -- 如果没有分隔符，整个名称作为歌曲名
    return {
        name = name:match("^%s*(.-)%s*$"),
        artist = t("music-player.ui.unknownArtist"),
        duration = "0:00",
        filename = filename
    }
end

-- ============================================================
-- 辅助函数：扫描音乐目录
-- 使用 sl.fs.list API 获取 music 目录下的所有 mp3 文件
-- ============================================================
local function scanMusicDirectory()
    local playlist = {}

    -- 检查 music 目录是否存在
    if not sl.fs.exists("music") then
        sl.log.info(logWithPrefix("music-player.log.directoryNotExist"))
        return defaultPlaylist
    end

    -- 列出 music 目录内容
    local files = sl.fs.list("music")
    if not files or #files == 0 then
        sl.log.info(logWithPrefix("music-player.log.directoryEmpty"))
        return defaultPlaylist
    end

    -- 解析每个文件
    local count = 0
    for i, filename in ipairs(files) do
        -- 只处理 mp3 文件
        if filename:lower():match("%.mp3$") then
            local songInfo = parseSongInfo(filename)
            if songInfo then
                table.insert(playlist, songInfo)
                count = count + 1
                sl.log.debug(logWithPrefix("music-player.log.songFound", {s = songInfo.name, a = songInfo.artist}))
            end
        end
    end

    if count == 0 then
        sl.log.info(logWithPrefix("music-player.log.noValidMp3"))
        return defaultPlaylist
    end

    sl.log.info(logWithPrefix("music-player.log.scanComplete", {d = count}))
    return playlist
end

-- ============================================================
-- 辅助函数：检测并适配 theme-palette 插件
-- 如果 theme-palette 可用，获取其主题色配置
-- ============================================================
local function detectThemePalette()
    -- 检查 sl.api 是否可用（需要 api 权限）
    if not sl.api then
        sl.log.debug(logWithPrefix("music-player.log.apiNotEnabled"))
        return
    end

    -- 检查 theme-palette 的 get_primary_color API 是否可用
    local hasThemePalette = sl.api.has("theme-palette", "get_primary_color")

    if hasThemePalette then
        sl.log.info(logWithPrefix("music-player.log.detectingThemePalette"))
        themeConfig.themePaletteAvailable = true

        -- 获取主色调
        local primaryColor = sl.api.call("theme-palette", "get_primary_color")
        if primaryColor then
            themeConfig.primaryColor = primaryColor
            sl.log.info(logWithPrefix("music-player.log.primaryColor", {s = primaryColor}))
        end

        -- 获取背景色
        local bgColor = sl.api.call("theme-palette", "get_background_color")
        if bgColor then
            themeConfig.backgroundColor = bgColor
            sl.log.info(logWithPrefix("music-player.log.backgroundColor", {s = bgColor}))
        end

        -- 获取当前预设名称
        local preset = sl.api.call("theme-palette", "get_preset")
        if preset then
            sl.log.info(logWithPrefix("music-player.log.preset", {s = preset}))
        end

        -- 保存主题配置到存储
        sl.storage.set("theme_primary", themeConfig.primaryColor)
        sl.storage.set("theme_bg", themeConfig.backgroundColor)
        sl.storage.set("theme_palette_available", "true")

        sl.log.info(logWithPrefix("music-player.log.themeSynced"))
    else
        sl.log.info(logWithPrefix("music-player.log.noThemePalette"))
        sl.storage.set("theme_palette_available", "false")
    end
end

-- ============================================================
-- 生命周期钩子：onLoad
-- 插件被加载时调用（此时插件尚未启用）
-- ============================================================
function plugin.onLoad()
    sl.log.info(logWithPrefix("music-player.log.pluginLoading"))
    sl.log.debug(logWithPrefix("music-player.log.versionInfo"))
end

-- ============================================================
-- 生命周期钩子：onEnable
-- 插件被启用时调用
-- ============================================================
function plugin.onEnable()
    sl.log.info(logWithPrefix("music-player.log.enabling"))

    -- 1. 检测并适配 theme-palette
    detectThemePalette()

    -- 2. 扫描音乐目录
    sl.log.info(logWithPrefix("music-player.log.scanningDirectory"))
    local playlist = scanMusicDirectory()

    -- 3. 保存歌曲列表到存储
    -- 将播放列表转换为 JSON 格式存储
    local playlistJson = "["
    for i, song in ipairs(playlist) do
        if i > 1 then playlistJson = playlistJson .. "," end
        playlistJson = playlistJson .. string.format(
            '{"name":"%s","artist":"%s","duration":"%s"}',
            song.name, song.artist, song.duration
        )
    end
    playlistJson = playlistJson .. "]"
    sl.storage.set("playlist", playlistJson)

    -- 4. 初始化播放状态
    local currentIndex = sl.storage.get("current_index")
    if not currentIndex then
        sl.storage.set("current_index", "1")
        currentIndex = "1"
    end

    local isPlaying = sl.storage.get("is_playing")
    if not isPlaying then
        sl.storage.set("is_playing", "false")
    end

    -- 5. 输出当前状态
    local idx = tonumber(currentIndex) or 1
    if playlist[idx] then
        sl.log.info(logWithPrefix("music-player.log.currentSong", {s = playlist[idx].name, a = playlist[idx].artist}))
    end

    -- 6. 输出主题状态
    if themeConfig.themePaletteAvailable then
        sl.log.info(logWithPrefix("music-player.log.themeEnabled", {s = themeConfig.primaryColor}))
    else
        sl.log.info(logWithPrefix("music-player.log.themeUsingDefault"))
    end

    -- 7. 缓存播放列表长度（供 nextSong/prevSong 使用）
    playlistLength = #playlist
    currentPlaylist = playlist -- 缓存播放列表用于语言变化时重新初始化

    -- 8. 注入悬浮播放器 UI
    injectPlayerUi(playlist)

    -- 9. 注册语言变化监听器
    if sl.i18n and sl.i18n.onLocaleChange then
        sl.i18n.onLocaleChange(function()
            -- 语言变化时重新注入 UI 以更新翻译
            injectPlayerUi(currentPlaylist)
        end)
    end

    sl.log.info(logWithPrefix("music-player.log.enableComplete", {d = #playlist}))
end

-- ============================================================
-- 生命周期钩子：onDisable
-- 插件被禁用时调用
-- ============================================================
function plugin.onDisable()
    sl.log.info(logWithPrefix("music-player.log.disabling"))
    -- 移除悬浮播放器 UI
    removePlayerUi()
    -- 保存当前播放状态
    sl.log.info(logWithPrefix("music-player.log.playbackStateSaved"))
end

-- ============================================================
-- 生命周期钩子：onUnload
-- 插件被卸载时调用
-- ============================================================
function plugin.onUnload()
    sl.log.info(logWithPrefix("music-player.log.pluginUnloaded"))
end

-- ============================================================
-- 播放控制函数
-- ============================================================

-- 切换播放/暂停状态
function plugin.togglePlay()
    local isPlaying = sl.storage.get("is_playing") == "true"
    sl.storage.set("is_playing", tostring(not isPlaying))

    if isPlaying then
        sl.log.info(logWithPrefix("music-player.log.paused"))
    else
        sl.log.info(logWithPrefix("music-player.log.startPlaying"))
    end
end

-- 下一曲
function plugin.nextSong()
    local currentIndex = tonumber(sl.storage.get("current_index")) or 1

    -- 使用缓存的播放列表长度
    if playlistLength > 0 then
        currentIndex = currentIndex + 1
        if currentIndex > playlistLength then
            currentIndex = 1
        end
        sl.storage.set("current_index", tostring(currentIndex))
        sl.log.info(logWithPrefix("music-player.log.switchedToSong", {d = currentIndex}))
    end
end

-- 上一曲
function plugin.prevSong()
    local currentIndex = tonumber(sl.storage.get("current_index")) or 1

    -- 使用缓存的播放列表长度
    if playlistLength > 0 then
        currentIndex = currentIndex - 1
        if currentIndex < 1 then
            currentIndex = playlistLength
        end
        sl.storage.set("current_index", tostring(currentIndex))
        sl.log.info(logWithPrefix("music-player.log.switchedToSong", {d = currentIndex}))
    end
end

-- 获取当前播放信息
function plugin.getCurrentInfo()
    return {
        index = tonumber(sl.storage.get("current_index")) or 1,
        isPlaying = sl.storage.get("is_playing") == "true",
        themePrimary = sl.storage.get("theme_primary") or "#64ffda",
        themePaletteAvailable = sl.storage.get("theme_palette_available") == "true"
    }
end

return plugin
