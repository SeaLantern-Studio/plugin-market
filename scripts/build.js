const fs = require('fs/promises');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const PLUGINS_ROOT = path.join(ROOT, 'plugins');
const API_ROOT = path.join(ROOT, 'api');

async function collectPluginPaths() {
  const entries = await fs.readdir(PLUGINS_ROOT, { withFileTypes: true });
  const userFolders = entries.filter(e => e.isDirectory()).map(e => e.name).sort();
  const paths = [];

  for (const user of userFolders) {
    const userDir = path.join(PLUGINS_ROOT, user);
    const pluginDirs = (await fs.readdir(userDir, { withFileTypes: true }))
      .filter(e => e.isDirectory())
      .map(e => e.name)
      .sort();
    for (const pluginId of pluginDirs) {
      const jsonFile = `${pluginId}.json`;
      const jsonPath = path.join(userDir, pluginId, jsonFile);
      try {
        await fs.access(jsonPath);
        paths.push(`plugins/${user}/${pluginId}/${jsonFile}`);
      } catch {
        // 没有对应 JSON 文件则跳过
      }
    }
  }

  return paths;
}

async function main() {
  await fs.mkdir(API_ROOT, { recursive: true });

  const paths = await collectPluginPaths();
  const output = {
    paths,
    total: paths.length,
    updated_at: new Date().toISOString()
  };

  await fs.writeFile(
    path.join(API_ROOT, 'plugins.json'),
    JSON.stringify(output, null, 2) + '\n',
    'utf8'
  );

  console.log(`Generated api/plugins.json (${paths.length} plugin paths)`);
}

main().catch(e => { console.error(e); process.exit(1); });
