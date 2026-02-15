const fs = require('fs');
const path = require('path');

const catalogPath = path.resolve(__dirname, '../../../mobile/assets/data/exercises_catalog_v1.json');
const templatesDir = path.resolve(__dirname, '../../../mobile/assets/data/new');

const collectExIds = (node, results) => {
  if (!node) return;

  if (Array.isArray(node)) {
    node.forEach((item) => collectExIds(item, results));
    return;
  }

  if (typeof node === 'object') {
    for (const [key, value] of Object.entries(node)) {
      if (key === 'ex_id' && typeof value === 'string') {
        results.add(value);
      } else {
        collectExIds(value, results);
      }
    }
  }
};

describe('Exercise Catalog Coverage', () => {
  it('contains all template exercise ex_id values', () => {
    const catalog = JSON.parse(fs.readFileSync(catalogPath, 'utf8'));
    const catalogSet = new Set((catalog.exercises || []).map((ex) => ex.ex_id));

    const templateFiles = fs
      .readdirSync(templatesDir)
      .filter((file) => file.endsWith('.json') && file !== 'injury_swap_table.json');

    const templateExIds = new Set();

    for (const file of templateFiles) {
      const content = JSON.parse(fs.readFileSync(path.join(templatesDir, file), 'utf8'));
      collectExIds(content, templateExIds);
    }

    const missing = [...templateExIds].filter((exId) => !catalogSet.has(exId));

    expect(missing).toEqual([]);
  });
});
