const fs = require('fs').promises;
const path = require('path');
const logger = require('../utils/logger');

class ExerciseCatalogService {
  constructor() {
    this.catalog = null;
    this.byId = new Map();
  }

  async load() {
    if (this.catalog) return this.catalog;
    try {
      const filePath = path.resolve(__dirname, '../../../mobile/assets/data/exercises_catalog_v1.json');
      const raw = await fs.readFile(filePath, 'utf8');
      const data = JSON.parse(raw);
      this.catalog = data;
      this.byId = new Map();
      (data.exercises || []).forEach((ex) => {
        if (ex && ex.ex_id) {
          this.byId.set(ex.ex_id, ex);
        }
      });
      return data;
    } catch (error) {
      logger.warn('Exercise catalog not available:', error.message);
      this.catalog = null;
      this.byId = new Map();
      return null;
    }
  }

  async getById(exId) {
    await this.load();
    return this.byId.get(exId) || null;
  }
}

module.exports = new ExerciseCatalogService();
