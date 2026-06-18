-- ============================================================
-- 播客订阅器 FINAL
-- ============================================================

local plugin = {}
local APP_CORE = "pr-core"
local STORAGE_PODS = "podcast_feeds"
local STORAGE_EPS = "podcast_episodes"
local STORAGE_HEARD = "podcast_heard"

local state = { podcasts = {}, episodes = {}, heard = {}, currentPod = nil, currentEp = nil, showAdd = false, playerOpen = true }
local coreInjected = false

-- ============================================================
-- 工具
-- ============================================================
local function esc(s)
  if not s then return "" end
  return s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;")
end
local function trim(s) return s and s:match("^%s*(.-)%s*$") or "" end
local function mkId(s)
  if not s or #s == 0 then return "id_" .. math.random(100000, 999999) end
  local id = s:gsub("[^%w%-_]", "_"):lower()
  return #id > 64 and id:sub(1, 64) or id
end
local function fmtDur(s)
  s = tonumber(s) or 0
  local h = math.floor(s / 3600); local m = math.floor((s % 3600) / 60); local sec = math.floor(s % 60)
  if h > 0 then return string.format("%d:%02d:%02d", h, m, sec) end
  return string.format("%d:%02d", m, sec)
end
local function parseDur(s)
  if not s or #s == 0 then return 0 end
  local h, m, s2 = s:match("^(%d+):(%d+):(%d+)$")
  if h then return tonumber(h)*3600+tonumber(m)*60+tonumber(s2) end
  local m2, s2 = s:match("^(%d+):(%d+)$")
  if m2 then return tonumber(m2)*60+tonumber(s2) end
  return tonumber(s) or 0
end
local function fmtDate(s)
  if not s or #s == 0 then return "" end
  local y, m, d = s:match("(%d+)%-(%d+)%-(%d+)")
  if y then return string.format("%d-%02d-%02d", tonumber(y), tonumber(m), tonumber(d)) end
  local months = {Jan = 1, Feb = 2, Mar = 3, Apr = 4, May = 5, Jun = 6, Jul = 7, Aug = 8, Sep = 9, Oct = 10, Nov = 11, Dec = 12}
  local dd, mmm, yyyy = s:match("(%d+)%s+(%a%a%a)%s+(%d+)")
  if dd and mmm and months[mmm] and yyyy then return string.format("%d-%02d-%02d", tonumber(yyyy), months[mmm], tonumber(dd)) end
  return s:sub(1, 10)
end
local function parseTime(s)
  if not s or #s == 0 then return 0 end
  local y, m, d = s:match("(%d+)%-(%d+)%-(%d+)")
  if y then return tonumber(y)*10000+tonumber(m)*100+tonumber(d) end
  local months = {Jan=1,Feb=2,Mar=3,Apr=4,May=5,Jun=6,Jul=7,Aug=8,Sep=9,Oct=10,Nov=11,Dec=12}
  local dd, mmm, yyyy = s:match("(%d+)%s+(%a%a%a)%s+(%d+)")
  if dd and mmm and months[mmm] and yyyy then return tonumber(yyyy)*10000+months[mmm]*100+tonumber(dd) end
  return 0
end
local function deepCopy(t)
  if type(t) ~= "table" then return t end
  local r = {}; for k, v in pairs(t) do r[k] = deepCopy(v) end
  return r
end
-- JS 字符串安全转义（处理所有破坏 JS 字符串的字符）
local function jsStr(s)
  if not s then return "" end
  s = s:gsub("\\", "\\\\")
  s = s:gsub("'", "\\'")
  s = s:gsub('"', '\\"')
  s = s:gsub("\n", "\\n")
  s = s:gsub("\r", "\\r")
  s = s:gsub("\t", "\\t")
  s = s:gsub("</script>", '</scr"+"ipt>')
  return s
end

-- ============================================================
-- XML / RSS
-- ============================================================
local function parseXml(xml)
  if not xml or #xml == 0 then return nil end
  xml = xml:gsub("<%?xml.-%?>", "")
  local root, stack, i, len = nil, {}, 1, #xml
  while i <= len do
    local ts = xml:find("<", i); if not ts then break end
    if ts > i and #stack > 0 then
      local txt = trim(xml:sub(i, ts - 1))
      if #txt > 0 then table.insert(stack[#stack].children, {type = "text", content = txt}) end
    end
    if ts + 1 > len then break end
    local nc = xml:sub(ts + 1, ts + 1)
    if nc == "/" then
      local ce = xml:find(">", ts); if not ce then break end
      local tn = trim(xml:sub(ts + 2, ce - 1))
      if #stack > 0 and stack[#stack].tag == tn then table.remove(stack) end; i = ce + 1
    elseif nc == "?" or nc == "!" then
      if xml:sub(ts + 2, ts + 4) == "--" then local ce = xml:find("-->", ts); i = (ce or ts) + 3
      elseif xml:sub(ts + 2, ts + 8) == "[CDATA[" then
        local ce = xml:find("]]>", ts)
        if ce and #stack > 0 then table.insert(stack[#stack].children, {type = "text", content = xml:sub(ts + 9, ce - 1)}) end
        i = (ce or ts) + 3
      else local ce = xml:find(">", ts); i = (ce or ts) + 1 end
    else
      local ce = xml:find(">", ts); if not ce then break end
      local tc = xml:sub(ts + 1, ce - 1)
      if tc:match("^%s*$") then i = ce + 1; break end
      local sc = tc:sub(-1) == "/"
      if sc then tc = tc:sub(1, -2) end
      local tn = tc:match("^([%w:_%-]+)"); if not tn then i = ce + 1; break end
      local attrs = {}
      for k, v in tc:gmatch('([%w:_%-]+)%s*=%s*"([^"]*)"') do attrs[k] = v end
      for k, v in tc:gmatch("([%w:_%-]+)%s*=%s*'([^']*)'") do attrs[k] = v end
      local node = {tag = tn, attrs = attrs, children = {}}
      if #stack == 0 then root = node else table.insert(stack[#stack].children, node) end
      if not sc then table.insert(stack, node) end; i = ce + 1
    end
  end
  return root
end
local function getText(node, tag)
  if not node or not node.children then return nil end
  for _, c in ipairs(node.children) do
    if c.tag == tag then
      local t = ""
      for _, x in ipairs(c.children or {}) do if x.type == "text" then t = t .. (x.content or "") end end
      return trim(t)
    end
  end
  return nil
end
local function getNodes(node, tag)
  local r = {}
  if node and node.children then for _, c in ipairs(node.children) do if c.tag == tag then table.insert(r, c) end end end
  return r
end
local function getAttr(node, tag, attr)
  for _, c in ipairs(node.children or {}) do if c.tag == tag and c.attrs then return c.attrs[attr] end end
  return nil
end
local function parseFeed(xml, url)
  local p = parseXml(xml); if not p then return nil end
  local info = {title = url, author = "", artwork = "", desc = "", episodes = {}}
  if p.tag == "rss" then
    local chs = getNodes(p, "channel"); if #chs == 0 then return nil end
    local ch = chs[1]
    info.title = getText(ch, "title") or url
    info.author = getAttr(ch, "itunes:author", "content") or getText(ch, "itunes:author") or getText(ch, "author") or ""
    info.artwork = getAttr(ch, "itunes:image", "href") or getText(ch, "itunes:image") or ((getNodes(ch, "image") or {})[1] and getText((getNodes(ch, "image"))[1], "url")) or ""
    info.desc = (getText(ch, "description") or ""):gsub("<[^>]+>", " "):gsub("%s+", " "):sub(1, 500)
    for _, item in ipairs(getNodes(ch, "item")) do
      local eUrl = ""
      for _, c in ipairs(item.children or {}) do if c.tag == "enclosure" and c.attrs then eUrl = c.attrs.url or "" end end
      if eUrl ~= "" then
        local guid = getText(item, "guid") or eUrl
        table.insert(info.episodes, {
          id = mkId(guid), title = getText(item, "title") or "无标题",
          desc = (getText(item, "description") or ""):gsub("<[^>]+>", " "):gsub("%s+", " "):sub(1, 300),
          url = eUrl, pubDate = getText(item, "pubDate") or "",
          duration = parseDur(getAttr(item, "itunes:duration", "content") or getText(item, "itunes:duration") or getText(item, "duration") or ""),
          artwork = getAttr(item, "itunes:image", "href") or getText(item, "itunes:image") or info.artwork,
        })
      end
    end
    table.sort(info.episodes, function(a, b) return parseTime(a.pubDate) > parseTime(b.pubDate) end)
  end
  return info
end

-- ============================================================
-- 存储
-- ============================================================
local function loadState()
  local ok1, p = pcall(sl.storage.get, STORAGE_PODS)
  local ok2, e = pcall(sl.storage.get, STORAGE_EPS)
  local ok3, h = pcall(sl.storage.get, STORAGE_HEARD)
  state.podcasts = (ok1 and p) and deepCopy(p) or {}
  state.episodes = (ok2 and e) and deepCopy(e) or {}
  state.heard = (ok3 and h) and deepCopy(h) or {}
  state.playerOpen = sl.storage.get("show_player") ~= false
end
local function saveAll()
  pcall(function() sl.storage.set(STORAGE_PODS, deepCopy(state.podcasts)) end)
  pcall(function() sl.storage.set(STORAGE_EPS, deepCopy(state.episodes)) end)
  pcall(function() sl.storage.set(STORAGE_HEARD, deepCopy(state.heard)) end)
end

-- ============================================================
-- 播客管理
-- ============================================================
function addPodcast(url)
  url = trim(url)
  if not url or #url == 0 then return false, "请输入地址" end
  if not url:match("^https?://") then return false, "请输入有效地址" end
  for _, p in ipairs(state.podcasts) do if p.url == url then return false, "已添加过" end end
  local pod = {id = mkId(url), url = url, title = url, author = "", artwork = "", desc = ""}
  table.insert(state.podcasts, pod); saveAll()
  local ok, msg = fetchPod(pod)
  return true, ok and "已添加" or "添加失败: " .. tostring(msg)
end
function removePodcast(id)
  local np = {}; for _, p in ipairs(state.podcasts) do if p.id ~= id then table.insert(np, p) end end
  state.podcasts = np
  local ne = {}; for _, e in ipairs(state.episodes) do if e.podId ~= id then table.insert(ne, e) end end
  state.episodes = ne; saveAll()
  if state.currentPod == id then state.currentPod = nil end
  if state.currentEp then
    local found = false; for _, e in ipairs(state.episodes) do if e.id == state.currentEp then found = true; break end end
    if not found then state.currentEp = nil end
  end
end
function fetchPod(pod)
  local resp, err = sl.http.get(pod.url, {timeout = 20})
  if not resp then return false, tostring(err) end
  if resp.status ~= 200 then return false, "HTTP " .. tostring(resp.status) end
  local info = parseFeed(resp.body, pod.url)
  if not info then return false, "无法解析 RSS" end
  pod.title = info.title or pod.title; pod.author = info.author or pod.author
  pod.artwork = info.artwork or pod.artwork; pod.desc = info.desc or ""
  local exist = {}; for _, e in ipairs(state.episodes) do if e.podId == pod.id then exist[e.id] = true end end
  local n = 0
  for _, ed in ipairs(info.episodes) do
    if not exist[ed.id] then ed.podId = pod.id; table.insert(state.episodes, 1, ed); n = n + 1 end
  end
  saveAll(); return true, n
end
function refreshPod(podId)
  for _, p in ipairs(state.podcasts) do if p.id == podId then return fetchPod(p) end end
  return false, "未找到"
end
function getEps(podId)
  local r = {}; for _, e in ipairs(state.episodes) do if e.podId == podId then table.insert(r, e) end end
  table.sort(r, function(a, b) return parseTime(a.pubDate) > parseTime(b.pubDate) end)
  return r
end
function getUnheard(podId)
  local c = 0; for _, e in ipairs(state.episodes) do if e.podId == podId and not state.heard[e.id] then c = c + 1 end end
  return c
end
function getPodById(podId)
  for _, p in ipairs(state.podcasts) do if p.id == podId then return p end end
  return nil
end
function getCurrentEpData()
  if not state.currentEp then return nil end
  for _, e in ipairs(state.episodes) do if e.id == state.currentEp then return e end end
  return nil
end

-- ============================================================
-- UI 生成
-- ============================================================
function genWelcome()
  return '<div class="pr-welcome"><div class="pr-welcome-bg"></div><div class="pr-welcome-content">'
    .. '<div class="pr-welcome-icon"><svg viewBox="0 0 64 64" fill="none" stroke="currentColor" stroke-width="1.2" width="64" height="64">'
    .. '<circle cx="32" cy="32" r="28" stroke-width="1"/><path d="M24 20v24l16-12z" fill="currentColor" stroke="none" opacity="0.85"/>'
    .. '</svg></div><h2 class="pr-welcome-title">欢迎使用播客订阅器</h2>'
    .. '<p class="pr-welcome-text">添加 RSS 订阅地址，自动获取最新剧集</p>'
    .. '<button class="pr-add-btn pr-primary-btn"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg> 添加 RSS</button></div></div>'
end
function genHeader()
  local title = state.currentPod and (getPodById(state.currentPod) or {}).title or "播客"
  local left = ""
  if state.currentPod then left = '<button class="pr-back-btn"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="18" height="18"><polyline points="15 18 9 12 15 6"/></svg></button>' end
  left = left .. '<span class="pr-title">' .. esc(title) .. '</span>'
  local right = ""
  if not state.currentPod then right = '<button class="pr-add-btn pr-primary-btn"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg> 添加</button>'
  else right = '<button class="pr-refresh-btn" value="' .. esc(state.currentPod) .. '"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg></button>' end
  return '<div class="pr-header">' .. left .. right .. '</div>'
end
function genGrid()
  if #state.podcasts == 0 then return "" end
  local html = '<div class="pr-grid">'
  for _, p in ipairs(state.podcasts) do
    local art = ""
    if p.artwork and #p.artwork > 0 then art = '<img src="' .. esc(p.artwork) .. '" alt="" class="pr-card-img" loading="lazy">'
    else art = '<div class="pr-card-placeholder"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M9 18V5l12-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="18" cy="16" r="3"/></svg></div>' end
    html = html .. '<div class="pr-card-wrap"><button class="pr-card' .. (p.id == state.currentPod and " pr-card-selected" or "") .. '" value="' .. esc(p.id) .. '">'
      .. '<span class="pr-card-art">' .. art .. (getUnheard(p.id) > 0 and '<span class="pr-badge">' .. getUnheard(p.id) .. '</span>' or "") .. '</span>'
      .. '<span class="pr-card-body"><span class="pr-card-name">' .. esc(p.title) .. '</span><span class="pr-card-meta">' .. esc(p.author) .. '</span></span></button>'
      .. '<button class="pr-remove-btn" value="' .. esc(p.id) .. '"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="14" height="14"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg></button></div>'
  end
  return html .. '</div>'
end
function genEpisodeList()
  if not state.currentPod then return "" end
  local eps = getEps(state.currentPod); local pod = getPodById(state.currentPod)
  if #eps == 0 then return '<div class="pr-empty"><div class="pr-empty-desc">还没有剧集</div></div>' end
  local html = '<div class="pr-ep-list">'
  for _, e in ipairs(eps) do
    local src = e.artwork or (pod and pod.artwork) or ""
    local art = ""
    if src and #src > 0 then art = '<img src="' .. esc(src) .. '" alt="" class="pr-ep-img" loading="lazy">'
    else art = '<div class="pr-ep-img-placeholder"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 18V5l12-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="18" cy="16" r="3"/></svg></div>' end
    html = html .. '<div class="pr-ep' .. (state.heard[e.id] and " pr-ep-heard" or "") .. (e.id == state.currentEp and " pr-ep-playing" or "") .. '" id="pr-ep-' .. esc(e.id) .. '">'
      .. '<span class="pr-ep-art">' .. art .. '</span>'
      .. '<span class="pr-ep-body"><span class="pr-ep-title">' .. esc(e.title) .. '</span>'
      .. '<span class="pr-ep-meta"><span>' .. fmtDate(e.pubDate) .. '</span>'
      .. (e.duration and e.duration > 0 and ' <span class="pr-ep-dot">·</span> <span>' .. fmtDur(e.duration) .. '</span>' or "")
      .. (e.id == state.currentEp and ' <span class="pr-ep-dot">·</span> <span class="pr-ep-now">播放中</span>' or "")
      .. '</span>' .. (e.desc and #e.desc > 0 and '<span class="pr-ep-desc">' .. esc(e.desc) .. '</span>' or '') .. '</span>'
      .. '<button class="pr-play-btn" value="' .. esc(e.url) .. '"><svg viewBox="0 0 24 24" fill="currentColor" width="16" height="16"><polygon points="8,5 19,12 8,19 8,5"/></svg></button></div>'
  end
  return html .. '</div>'
end
function genContent()
  local body = ""
  if #state.podcasts == 0 then body = genWelcome()
  else
    body = genHeader()
    local pod = getPodById(state.currentPod)
    if state.currentPod and pod then
      if (pod.author and #pod.author > 0) or (pod.desc and #pod.desc > 0) then
        body = body .. '<div class="pr-pod-info">'
        if pod.author and #pod.author > 0 then body = body .. '<span class="pr-pod-author">' .. esc(pod.author) .. '</span>' end
        if pod.desc and #pod.desc > 0 then body = body .. '<span class="pr-pod-desc">' .. esc(pod.desc) .. '</span>' end
        body = body .. '</div>'
      end
    end
    body = body .. '<div class="pr-content">' .. (state.currentPod and genEpisodeList() or genGrid()) .. '</div>'
  end
  if state.showAdd then
    body = body .. '<div class="pr-dialog"><div class="pr-dialog-inner">'
      .. '<div class="pr-dialog-title">添加播客</div>'
      .. '<input type="url" class="pr-input" id="pr-add-url" placeholder="https://example.com/feed.xml">'
      .. '<div class="pr-dialog-actions">'
      .. '<button class="pr-cancel-btn" id="pr-cancel-add">取消</button>'
      .. '<button class="pr-primary-btn" id="pr-confirm-add">确认添加</button></div></div></div>'
  end
  return '<div class="pr-app">' .. body .. '</div>'
end

-- ============================================================
-- 播放器 UI 更新（注入脚本直接操作 DOM）
-- ============================================================
function syncPlayerUI(url)
  local ep = nil
  for _, e in ipairs(state.episodes) do if e.url == url or e.id == url then ep = e; break end end
  if not ep then return end
  local pod = getPodById(ep.podId) or {}
  local art = ep.artwork or pod.artwork or ""
  local artJS = ""
  if art and #art > 0 then
    artJS = "ar.innerHTML='<img src=\"" .. jsStr(art) .. "\" class=\"pr-pb-img\" onerror=\"this.remove()\">';"
  else
    artJS = "ar.innerHTML='<span class=\"pr-pb-img ph\"><svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.5\"><path d=\"M9 18V5l12-2v13\"/><circle cx=\"6\" cy=\"18\" r=\"3\"/><circle cx=\"18\" cy=\"16\" r=\"3\"/></svg></span>';"
  end
  local js = "try{var d=document;"
  -- 注意：不设 audio.src！播放由点击事件直接处理，这里只更新 UI
  js = js .. "var t=d.getElementById('pr-pb-title');if(t)t.textContent='" .. jsStr(ep.title) .. "';"
  js = js .. "var p=d.getElementById('pr-pb-pod');if(p)p.textContent='" .. jsStr(pod.title or "") .. "';"
  js = js .. "var u=d.getElementById('pr-pb-total');if(u)u.textContent='" .. (ep.duration and fmtDur(ep.duration) or "0:00") .. "';"
  js = js .. "var ar=d.getElementById('pr-pb-art');" .. artJS
  if state.playerOpen ~= false then
    js = js .. "var b=d.getElementById('pr-player-bar');if(b)b.style.display='flex';"
  end
  js = js .. "}catch(e){}"
  pcall(function() sl.ui.inject_html("pr-pb-upd", "<script>" .. js .. "</script>") end)
end

-- ============================================================
-- 核心脚本
-- ============================================================
function genCoreHtml()
  return [==[<input type="hidden" id="pr-cmd">
<audio id="pr-audio" preload="metadata"></audio>
<div class="pr-player-bar" id="pr-player-bar">
  <span class="pr-pb-left"><span class="pr-pb-img ph" id="pr-pb-art"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M9 18V5l12-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="18" cy="16" r="3"/></svg></span></span>
  <span class="pr-pb-center"><span class="pr-pb-title" id="pr-pb-title">未播放</span><span class="pr-pb-pod" id="pr-pb-pod"></span></span>
  <span class="pr-pb-controls">
    <button class="pr-prev-btn"><svg viewBox="0 0 24 24" fill="currentColor" width="18" height="18"><path d="M6 6h2v12H6zm3.5 6l8.5 6V6z"/></svg></button>
    <button class="pr-toggle-play" id="pr-play-btn"><svg viewBox="0 0 24 24" fill="currentColor" width="22" height="22"><polygon points="8,5 19,12 8,19 8,5"/></svg></button>
    <button class="pr-next-btn"><svg viewBox="0 0 24 24" fill="currentColor" width="18" height="18"><path d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z"/></svg></button>
  </span>
  <span class="pr-pb-seek"><span class="pr-time" id="pr-pb-cur">0:00</span><span class="pr-seek-bar" id="pr-seek-bar"><span class="pr-seek-fill" id="pr-seek-fill"></span></span><span class="pr-time" id="pr-pb-total">0:00</span></span>
  <button class="pr-speed-btn" id="pr-speed-btn">1.0x</button>
</div>
<script id="pr-js">(function(){
if(window.__prReady)return;window.__prReady=true;
function ipc(c,a){try{var p="//pr/"+c;if(a)for(var k in a)p+="|"+k+"="+encodeURIComponent((a[k]||""));window.__TAURI_INTERNALS__.invoke("on_page_changed",{path:p});}catch(e){}}
var A=document.getElementById("pr-audio");
var PB=document.getElementById("pr-player-bar");
A.addEventListener("ended",function(){ipc("next");});
A.addEventListener("play",function(){var p=document.getElementById("pr-play-btn");if(p)p.innerHTML='<svg viewBox="0 0 24 24" fill="currentColor" width="22" height="22"><rect x="6" y="4" width="4" height="16"/><rect x="14" y="4" width="4" height="16"/></svg>';});
A.addEventListener("pause",function(){var p=document.getElementById("pr-play-btn");if(p)p.innerHTML='<svg viewBox="0 0 24 24" fill="currentColor" width="22" height="22"><polygon points="8,5 19,12 8,19 8,5"/></svg>';});
// 进度条轮询
setInterval(function(){
  try{
    if(!A||!A.duration||isNaN(A.duration))return;
    var cur=A.currentTime||0,pct=cur/A.duration*100;
    var f=document.getElementById("pr-seek-fill"),c=document.getElementById("pr-pb-cur");
    if(f)f.style.width=Math.min(pct,100)+"%";
    if(c){var m=Math.floor(cur/60),s=Math.floor(cur%60);c.textContent=m+":"+(s<10?"0":"")+s;}
  }catch(e){}
},200);
// 播放栏跟随侧栏（轮询 offsetWidth + resize）
function alignPlayer(){
  var s=document.querySelector('.sidebar');
  if(s){var w=s.offsetWidth;PB.style.left=w+'px';PB.style.width=(window.innerWidth-w)+'px';}
  else{PB.style.left='0px';PB.style.width='100%';}
}
window.addEventListener('resize',alignPlayer);
setInterval(alignPlayer,500);
PB.style.display="none";
// 防抖 MutationObserver
var dt;
var mo=new MutationObserver(function(){clearTimeout(dt);dt=setTimeout(function(){
  var all=document.querySelectorAll('.pr-app');
  if(all.length>1)for(var i=1;i<all.length;i++){var w=all[i].closest('[data-plugin-inserted]');if(w)w.remove();}
  var pg=document.querySelector('.plugin-page-view');
  if(pg)pg.querySelectorAll('.info-card,.settings-card,.presets-card,.action-buttons,.page-header').forEach(function(el){el.style.display='none';});
},100);});
mo.observe(document.body,{childList:true,subtree:true});
// 事件代理
document.body.addEventListener("click",function(e){
  var t=e.target.closest("button,.pr-ep,.pr-seek-bar");
  if(!t)return;
  if(t.classList.contains("pr-ep")){var eid=t.id.substring(6);if(eid)ipc("select_ep",{id:eid});return;}
  if(t.classList.contains("pr-seek-bar")){
    if(!A||!A.duration)return;
    var r=t.getBoundingClientRect(),p=(e.clientX-r.left)/r.width;
    if(p<0)p=0;if(p>1)p=1;A.currentTime=p*A.duration;return;
  }
  if(t.tagName==="BUTTON"){
    var v=t.getAttribute("value")||"";
    if(t.classList.contains("pr-card"))return ipc("select",{id:v});
    if(t.classList.contains("pr-play-btn")){A.src=v;A.play();ipc("play",{url:v});return;}
    if(t.classList.contains("pr-remove-btn"))return ipc("remove",{id:v});
    if(t.classList.contains("pr-refresh-btn"))return ipc("refresh",{id:v});
    if(t.classList.contains("pr-back-btn"))return ipc("back");
    if(t.classList.contains("pr-add-btn"))return ipc("show-add");
    if(t.id==="pr-cancel-add")return ipc("hide-add");
    if(t.id==="pr-confirm-add"){var el=document.getElementById("pr-add-url");ipc("add-podcast",{url:el?el.value:""});return;}
    if(t.classList.contains("pr-prev-btn"))return ipc("prev");
    if(t.classList.contains("pr-next-btn"))return ipc("next");
    if(t.classList.contains("pr-toggle-play")){A.paused?A.play():A.pause();return;}
    if(t.classList.contains("pr-speed-btn")){
      var sp=[0.5,0.75,1,1.25,1.5,1.75,2,3],c=parseFloat(t.textContent)||1,i=sp.indexOf(c),n=sp[(i+1)%sp.length];
      t.textContent=n.toFixed(2).replace(/\.?0+$/,"")+"x";A.playbackRate=n;return;
    }
  }
});
document.body.addEventListener("keydown",function(e){
  if(e.key==="Enter"&&e.target.id==="pr-add-url"){
    var el=document.getElementById("pr-add-url");ipc("add-podcast",{url:el?el.value:""});}
});
if(document.querySelector(".plugin-content"))ipc("page-ready");
else{var mo2=new MutationObserver(function(){if(document.querySelector(".plugin-content")){ipc("page-ready");mo2.disconnect();}});mo2.observe(document.body,{childList:true,subtree:true});}
})();</script>]==]
end

-- ============================================================
-- 命令处理
-- ============================================================
local function processCmd(cmd, args)
  if cmd == "page-ready" then renderUI(); return end
  if cmd == "show-add" then state.showAdd = true; renderUI(); return end
  if cmd == "hide-add" then state.showAdd = false; renderUI(); return end
  if cmd == "add-podcast" then
    state.showAdd = false
    local url = args.url or ""
    if url and #url > 0 then local ok2, msg = addPodcast(url); sl.ui.toast(ok2 and "success" or "error", msg or "") end
    renderUI(); return
  end
  if cmd == "select" then state.currentPod = args.id; state.currentEp = nil; renderUI(); return end
  if cmd == "back" then state.currentPod = nil; state.currentEp = nil; renderUI(); return end
  if cmd == "remove" then removePodcast(args.id); sl.ui.toast("info", "已取消订阅"); renderUI(); return end
  if cmd == "refresh" then
    local ok2, msg = refreshPod(args.id)
    sl.ui.toast(ok2 and "success" or "error", ok2 and ((tonumber(msg) or 0) > 0 and "新增 " .. msg .. " 集" or "没有新剧集") or "失败: " .. tostring(msg))
    renderUI(); return
  end
  if cmd == "play" then
    local url = args.url or ""
    for _, e in ipairs(state.episodes) do if e.url == url then state.currentEp = e.id; state.heard[e.id] = true; saveAll(); break end end
    syncPlayerUI(url); return
  end
  if cmd == "select_ep" then
    state.currentEp = args.id; state.heard[args.id] = true; saveAll()
    syncPlayerUI(args.id); renderUI(); return
  end
  if cmd == "prev" or cmd == "next" then
    if not state.currentEp or not state.currentPod then return end
    local eps = getEps(state.currentPod); local idx = -1
    for i, e in ipairs(eps) do if e.id == state.currentEp then idx = i; break end end
    if idx >= 0 then
      local ni = (cmd == "next") and idx + 1 or idx - 1
      if ni >= 1 and ni <= #eps then
        state.currentEp = eps[ni].id; state.heard[eps[ni].id] = true; saveAll()
        for _, e in ipairs(state.episodes) do if e.id == eps[ni].id then
          syncPlayerUI(e.url)
          local u = jsStr(e.url)
          pcall(function() sl.ui.inject_html("pr-pb-switch", "<script>try{var a=document.getElementById('pr-audio');if(a){a.src='" .. u .. "';a.play();}}catch(ex){}</script>") end)
          break
        end end
      end
    end
    return
  end
end

-- ============================================================
-- UI
-- ============================================================
function renderUI()
  sl.ui.insert("prepend", ".plugin-content", genContent())
  pcall(function() sl.ui.inject_css("pr-hide", [[
    .plugin-page-view .page-header { display: none !important; }
    .plugin-page-view .plugin-content > .info-card { display: none !important; }
    .plugin-page-view .plugin-content > .settings-card { display: none !important; }
    .plugin-page-view .plugin-content > .presets-card { display: none !important; }
    .plugin-page-view .plugin-content > .action-buttons { display: none !important; }
  ]]) end)
end
function injectUI()
  if not coreInjected then
    sl.ui.inject_html(APP_CORE, genCoreHtml())
    coreInjected = true
  end
  renderUI()
  if state.currentEp then
    for _, e in ipairs(state.episodes) do if e.id == state.currentEp then syncPlayerUI(e.url); break end end
  end
end
function removeUI()
  pcall(function() sl.ui.remove_html(APP_CORE) end)
  pcall(function() sl.ui.remove_selector('[data-plugin-inserted="podcast-reader"]') end)
  pcall(function() sl.ui.remove_css("pr-hide") end)
end

-- ============================================================
-- 生命周期
-- ============================================================
function plugin.onLoad()
  pcall(function() sl.log.info("播客订阅器加载中"); loadState(); sl.log.debug("加载 " .. tostring(#state.podcasts) .. " 播客") end)
end
function plugin.onEnable()
  pcall(function() sl.log.info("播客订阅器已启用"); injectUI() end)
end
function plugin.onDisable()
  pcall(function() sl.log.warn("播客订阅器已禁用"); removeUI(); saveAll() end)
end
function plugin.onUnload()
  pcall(function() sl.log.info("播客订阅器已卸载") end)
end
function plugin.onPageChanged(path)
  local ok, err = pcall(function()
    local cmdData = path:match("^//pr/(.+)$")
    if cmdData then
      local parts = {}; for part in cmdData:gmatch("[^|]+") do parts[#parts+1] = part end
      local args = {}
      for i = 2, #parts do
        local k, v = parts[i]:match("^([^=]+)=(.*)$")
        if k then v = v:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end); args[k] = v end
      end
      processCmd(parts[1], args)
      return
    end
    if not path or not path:find("podcast%-reader") then return end
    injectUI()
  end)
  if not ok then sl.log.error("onPageChanged 错误: " .. tostring(err)) end
end

return plugin
