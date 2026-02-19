/**
 * SeaLantern Plugin Market
 * 加载流程：api/plugins.json（路径列表）→ 并发 fetch 各插件 JSON
 * 分类由插件自身 categories[] 字段声明，categories.json 仅做 i18n
 */

const state = {
  plugins: [],
  categories: {},   // { key: { "zh-CN": "...", "en-US": "..." } }
  activeCategory: '',
  searchQuery: '',
  sortBy: 'name'
};

const $ = sel => document.querySelector(sel);

// ==================== 数据加载 ====================

async function fetchJSON(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${url}`);
  return res.json();
}

async function loadData() {
  const grid = $('#pluginsGrid');
  try {
    const [catData, pluginsIndex] = await Promise.all([
      fetchJSON('./api/categories.json'),
      fetchJSON('./api/plugins.json')
    ]);

    state.categories = catData;

    const paths = Array.isArray(pluginsIndex?.paths) ? pluginsIndex.paths : [];
    const results = await Promise.allSettled(paths.map(p => fetchJSON(`./${p}`).then(data => ({ ...data, _path: p }))));
    state.plugins = results
      .filter(r => r.status === 'fulfilled' && r.value?.id)
      .map(r => {
        const p = r.value;
        // 从路径 plugins/username/plugin-id.json 推断 github 和 author
        const parts = p._path?.split('/'); // ["plugins","username","plugin-id","plugin-id.json"]
        const username = parts?.[1];
        const pluginFile = parts?.[2];
        if (username && pluginFile) {
          if (!p.github) p.github = `${username}/${pluginFile}`;
          if (!p.author) p.author = { name: username, url: `https://github.com/${username}` };
        }
        return p;
      });

    renderCategories();
    renderPlugins();
  } catch (e) {
    console.error('加载数据失败:', e);
    if (grid) grid.innerHTML = '<div class="empty-state"><h3>加载失败</h3><p>请检查 api/plugins.json 和 api/categories.json</p></div>';
  }
}

function getUserLang() {
  const lang = navigator.language || 'zh-CN';
  return lang.startsWith('zh') ? 'zh-CN' : 'en-US';
}

function getCategoryLabel(key) {
  const lang = getUserLang();
  const cat = state.categories[key];
  if (!cat) return key;
  return typeof cat === 'string' ? cat : (cat[lang] || cat['zh-CN'] || key);
}

// ==================== 渲染 ====================

function renderCategories() {
  // 从插件数据中收集实际存在的分类
  const usedCats = new Set();
  state.plugins.forEach(p => (p.categories || []).forEach(c => usedCats.add(c)));

  const tabs = ['<button class="tab active" data-category="">全部</button>'];
  for (const key of usedCats) {
    tabs.push(`<button class="tab" data-category="${key}">${escapeHtml(getCategoryLabel(key))}</button>`);
  }
  const container = $('#categoryTabs');
  if (container) container.innerHTML = tabs.join('');
}

function renderPlugins() {
  const list = filterAndSort(state.plugins);
  const grid = $('#pluginsGrid');
  const count = $('#pluginCount');
  if (!grid) return;

  grid.innerHTML = list.length
    ? list.map(p => createCard(p)).join('')
    : '<div class="empty-state"><h3>没有找到插件</h3></div>';

  if (count) {
    const total = state.plugins.length;
    const shown = list.length;
    count.textContent = shown === total ? `共 ${total} 个插件` : `显示 ${shown} / ${total}`;
  }
}

function createCard(plugin) {
  const lang = getUserLang();
  const name = plugin.name?.[lang] || plugin.name?.['zh-CN'] || plugin.id;
  const desc = plugin.description?.[lang] || plugin.description?.['zh-CN'] || '';
  const cats = (plugin.categories || []).map(c => escapeHtml(getCategoryLabel(c))).join(', ');

  const iconHtml = plugin.icon_url
    ? `<img src="./${plugin._path?.replace(/\/[^/]+$/, '')}/${plugin.icon_url}" alt="" onerror="this.parentElement.innerHTML='${getDefaultIconSvg()}'">`
    : getDefaultIconSvg();

  return `
    <article class="plugin-card" data-id="${plugin.id}">
      <div class="card-header">
        <div class="card-icon">${iconHtml}</div>
        <div class="card-info">
          <div class="card-name">${escapeHtml(name)}</div>
          <div class="card-version">${plugin.version ? 'v' + escapeHtml(plugin.version) : ''}</div>
        </div>
      </div>
      <p class="card-desc">${escapeHtml(desc)}</p>
      <div class="card-footer">
        <span class="card-author">${escapeHtml(plugin.author?.name || 'Unknown')}</span>
        <span class="card-category">${cats}</span>
      </div>
    </article>
  `;
}

function getDefaultIconSvg() {
  return `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>`;
}

function renderModal(plugin) {
  const body = $('#modalBody');
  if (!body) return;

  const lang = getUserLang();
  const name = plugin.name?.[lang] || plugin.name?.['zh-CN'] || plugin.id;
  const desc = plugin.description?.[lang] || plugin.description?.['zh-CN'] || '';

  const iconHtml = plugin.icon_url
    ? `<img src="./${plugin._path?.replace(/\/[^/]+$/, '')}/${plugin.icon_url}" alt="" onerror="this.parentElement.innerHTML='${getDefaultIconSvg()}'">`
    : getDefaultIconSvg();

  const permissionsHtml = (plugin.permissions || []).map(p =>
    `<span class="permission ${getPermissionClass(p)}">${escapeHtml(p)}</span>`
  ).join('');

  const cats = (plugin.categories || []).map(c => escapeHtml(getCategoryLabel(c))).join(', ');
  const downloadUrl = plugin.download_url || (plugin.github ? `https://github.com/${plugin.github}/releases/latest` : '#');

  body.innerHTML = `
    <div class="detail-header">
      <div class="detail-icon">${iconHtml}</div>
      <div class="detail-info">
        <h2>${escapeHtml(name)}</h2>
        <div class="detail-meta">
          ${plugin.version ? 'v' + escapeHtml(plugin.version) + ' · ' : ''}${cats} ·
          by <a href="${escapeHtml(plugin.author?.url || '#')}" target="_blank">${escapeHtml(plugin.author?.name || 'Unknown')}</a>
        </div>
      </div>
    </div>
    <div class="detail-section"><h3>简介</h3><p class="detail-desc">${escapeHtml(desc)}</p></div>
    ${plugin.github ? `<div class="detail-section"><h3>源代码</h3><p><a href="https://github.com/${escapeHtml(plugin.github)}" target="_blank">${escapeHtml(plugin.github)}</a></p></div>` : ''}
    ${permissionsHtml ? `<div class="detail-section"><h3>所需权限</h3><div class="detail-permissions">${permissionsHtml}</div></div>` : ''}
    <div class="detail-actions">
      <a href="${downloadUrl}" class="btn-download" target="_blank" rel="noreferrer">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
        查看最新版本
      </a>
    </div>
  `;
}

// ==================== 筛选 ====================

function filterAndSort(plugins) {
  const lang = getUserLang();
  let list = [...plugins];

  if (state.activeCategory) {
    list = list.filter(p => (p.categories || []).includes(state.activeCategory));
  }

  if (state.searchQuery) {
    const q = state.searchQuery.toLowerCase();
    list = list.filter(p => {
      const name = (p.name?.[lang] || p.name?.['zh-CN'] || p.id).toLowerCase();
      const desc = (p.description?.[lang] || p.description?.['zh-CN'] || '').toLowerCase();
      return name.includes(q) || desc.includes(q);
    });
  }

  if (state.sortBy === 'name') {
    list.sort((a, b) =>
      (a.name?.[lang] || a.name?.['zh-CN'] || a.id)
        .localeCompare(b.name?.[lang] || b.name?.['zh-CN'] || b.id, lang)
    );
  }

  return list;
}

function getPermissionClass(perm) {
  const dangerous = ['fs', 'network', 'server', 'console'];
  const critical = ['execute_program', 'plugin_folder_access'];
  if (critical.includes(perm)) return 'permission--critical';
  if (dangerous.includes(perm)) return 'permission--dangerous';
  return '';
}

function escapeHtml(text) {
  if (!text) return '';
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

// ==================== 事件 ====================

function setupEvents() {
  const searchInput = $('#searchInput');
  if (searchInput) {
    let timer;
    searchInput.addEventListener('input', e => {
      clearTimeout(timer);
      timer = setTimeout(() => { state.searchQuery = e.target.value.trim(); renderPlugins(); }, 250);
    });
  }

  const sortSelect = $('#sortSelect');
  if (sortSelect) {
    sortSelect.addEventListener('change', e => { state.sortBy = e.target.value; renderPlugins(); });
  }

  const categoryTabs = $('#categoryTabs');
  if (categoryTabs) {
    categoryTabs.addEventListener('click', e => {
      if (e.target.classList.contains('tab')) {
        categoryTabs.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        e.target.classList.add('active');
        state.activeCategory = e.target.dataset.category;
        renderPlugins();
      }
    });
  }

  const pluginsGrid = $('#pluginsGrid');
  if (pluginsGrid) {
    pluginsGrid.addEventListener('click', e => {
      const card = e.target.closest('.plugin-card');
      if (!card) return;
      const plugin = state.plugins.find(p => p.id === card.dataset.id);
      if (plugin) { renderModal(plugin); openModal(); }
    });
  }

  const modal = $('#pluginModal');
  if (modal) {
    modal.addEventListener('click', e => {
      if (e.target.classList.contains('modal-backdrop') || e.target.dataset.close) closeModal();
    });
    const closeBtn = modal.querySelector('.modal-close');
    if (closeBtn) closeBtn.addEventListener('click', closeModal);
  }

  document.addEventListener('keydown', e => {
    if (e.key === 'Escape') {
      const m = $('#pluginModal');
      if (m && m.getAttribute('aria-hidden') === 'false') closeModal();
    }
  });
}

function openModal() {
  const modal = $('#pluginModal');
  if (modal) { modal.setAttribute('aria-hidden', 'false'); document.body.style.overflow = 'hidden'; }
}

function closeModal() {
  const modal = $('#pluginModal');
  if (modal) { modal.setAttribute('aria-hidden', 'true'); document.body.style.overflow = ''; }
}

setupEvents();
loadData();
