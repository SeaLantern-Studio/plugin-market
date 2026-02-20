-- Element API 增强示例插件
-- 开启后：随机跳转到一个侧边栏页面，弹出弹窗展示当前页面元素信息，并演示修改元素值

local plugin = {}

-- ============================================================
-- 辅助：注入弹窗样式
-- ============================================================
local function inject_modal_css()
    sl.ui.inject_css("element-demo-modal-css", [[
        #element-demo-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.55);
            z-index: 9998;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        #element-demo-modal {
            background: var(--sl-surface, #1e1e2e);
            border: 1px solid var(--sl-border, #333);
            border-radius: 12px;
            padding: 24px 28px;
            min-width: 340px;
            max-width: 520px;
            max-height: 70vh;
            overflow-y: auto;
            z-index: 9999;
            box-shadow: 0 8px 32px rgba(0,0,0,0.4);
            color: var(--sl-text-primary, #cdd6f4);
            font-size: 13px;
            line-height: 1.6;
        }
        #element-demo-modal h3 {
            margin: 0 0 12px 0;
            font-size: 15px;
            font-weight: 600;
            color: var(--sl-primary, #89b4fa);
            border-bottom: 1px solid var(--sl-border, #333);
            padding-bottom: 8px;
        }
        #element-demo-modal .el-section {
            margin-bottom: 14px;
        }
        #element-demo-modal .el-label {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--sl-text-secondary, #a6adc8);
            margin-bottom: 4px;
        }
        #element-demo-modal .el-value {
            background: var(--sl-bg-secondary, #181825);
            border-radius: 6px;
            padding: 6px 10px;
            font-family: monospace;
            font-size: 12px;
            word-break: break-all;
            color: var(--sl-text-primary, #cdd6f4);
        }
        #element-demo-modal .el-changed {
            color: var(--sl-success, #a6e3a1);
            font-weight: 600;
        }
        #element-demo-modal .el-footer {
            margin-top: 16px;
            font-size: 11px;
            color: var(--sl-text-secondary, #a6adc8);
            text-align: center;
        }
        #element-demo-close-label {
            display: inline-block;
            margin-top: 14px;
            padding: 6px 18px;
            background: var(--sl-primary, #89b4fa);
            color: #1e1e2e;
            border-radius: 6px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            user-select: none;
        }
        #element-demo-close-toggle {
            display: none;
        }
        #element-demo-close-toggle:checked + #element-demo-overlay {
            display: none;
        }
    ]])
end

-- ============================================================
-- 辅助：构建弹窗 HTML
-- ============================================================
local function build_modal_html(info)
    local rows = ""
    for _, item in ipairs(info) do
        rows = rows ..
            '<div class="el-section">' ..
            '<div class="el-label">' .. item.label .. '</div>' ..
            '<div class="el-value">' .. item.value .. '</div>' ..
            '</div>'
    end

    return [[
        <input type="checkbox" id="element-demo-close-toggle">
        <div id="element-demo-overlay">
          <div id="element-demo-modal">
            <h3>Element Demo — 当前页面元素快照</h3>
    ]] .. rows .. [[
            <div class="el-footer">插件已通过 sl.element API 读取以上信息，并修改了页面中的输入框值</div>
            <div style="text-align:center">
              <label id="element-demo-close-label" for="element-demo-close-toggle">关闭</label>
            </div>
          </div>
        </div>
    ]]
end

-- ============================================================
-- 插件启用
-- ============================================================
function plugin.onEnable()
    sl.log.info("========== [Element Demo] 插件已启用 ==========")

    -- ----------------------------------------------------------
    -- 步骤 1：随机跳转到一个侧边栏导航项
    -- ----------------------------------------------------------
    sl.log.info("[Step 1] 随机跳转侧边栏...")

    local nav_count = 5  -- home / console / players / paint / plugins
    local rand_index = math.random(1, nav_count)
    local nav_selector = ".nav-item:nth-child(" .. rand_index .. ")"

    sl.log.info("  随机选中导航项索引: " .. rand_index .. "  selector: " .. nav_selector)

    local ok_nav = sl.element.click(nav_selector)
    sl.log.info("  click 结果: " .. tostring(ok_nav))

    -- ----------------------------------------------------------
    -- 步骤 2：同步读取页面元素（阻塞等待前端响应）
    -- get_* 函数现在返回实际的 DOM 值字符串，超时返回 nil
    -- ----------------------------------------------------------
    sl.log.info("[Step 2] 同步读取页面元素...")

    local title_text = sl.element.get_text("h1")
    sl.log.info("  get_text(h1) = " .. tostring(title_text))

    local body_attrs = sl.element.get_attributes("body")
    sl.log.info("  get_attributes(body) = " .. tostring(body_attrs))

    local input_val = sl.element.get_value("input")
    sl.log.info("  get_value(input) = " .. tostring(input_val))

    local link_href = sl.element.get_attribute("a", "href")
    sl.log.info("  get_attribute(a, href) = " .. tostring(link_href))

    -- ----------------------------------------------------------
    -- 步骤 3：修改页面中第一个 input 的值（同步写入）
    -- ----------------------------------------------------------
    sl.log.info("[Step 3] 修改 input 值...")

    local new_value = "element-demo-" .. math.random(100000, 999999)
    local ok_set = sl.element.set_value("input", new_value)
    sl.log.info("  set_value 结果: " .. tostring(ok_set) .. "  新值: " .. new_value)

    -- ----------------------------------------------------------
    -- 步骤 4：监听 input 值变化
    -- ----------------------------------------------------------
    sl.log.info("[Step 4] 注册 on_change 监听...")

    sl.element.on_change("input", function(value)
        sl.log.info("  [on_change] input 值变化 -> " .. tostring(value))
    end)

    -- ----------------------------------------------------------
    -- 步骤 5：注入弹窗展示以上信息
    -- ----------------------------------------------------------
    sl.log.info("[Step 5] 注入弹窗...")

    inject_modal_css()

    local info = {
        {
            label = "click(nav_selector) — 随机跳转",
            value = "索引 " .. rand_index .. " → " .. nav_selector .. " (触发: " .. tostring(ok_nav) .. ")"
        },
        {
            label = "get_text(&quot;h1&quot;) — 同步返回",
            value = title_text or "(nil — 未找到元素或超时)"
        },
        {
            label = "get_attributes(&quot;body&quot;) — 同步返回",
            value = body_attrs or "(nil — 未找到元素或超时)"
        },
        {
            label = "get_value(&quot;input&quot;) — 同步返回",
            value = input_val or "(nil — 未找到元素或超时)"
        },
        {
            label = "get_attribute(&quot;a&quot;, &quot;href&quot;) — 同步返回",
            value = link_href or "(nil — 未找到元素或超时)"
        },
        {
            label = "set_value(&quot;input&quot;, new_value) — 同步写入",
            value = '<span class="el-changed">' .. new_value .. '</span> (触发: ' .. tostring(ok_set) .. ')'
        },
        {
            label = "on_change(&quot;input&quot;, fn) — 监听已注册",
            value = "input 值变化时将在日志中输出新值"
        },
    }

    local modal_html = build_modal_html(info)
    sl.ui.inject_html("element-demo-modal-wrapper", modal_html)

    sl.log.info("========== [Element Demo] 演示完成 ==========")
end

-- ============================================================
-- 插件禁用
-- ============================================================
function plugin.onDisable()
    sl.ui.remove_html("element-demo-modal-wrapper")
    sl.ui.remove_css("element-demo-modal-css")
    sl.log.info("[Element Demo] 插件已禁用，弹窗已移除")
end

return plugin
