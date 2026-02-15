/**
 * Mock database for testing
 */
class MockDb {
  constructor() {
    this.data = new Map();
    this.queries = [];
  }

  query(sql, params = []) {
    this.queries.push({ sql, params, timestamp: new Date() });

    // Mock successful response
    return Promise.resolve({
      rows: this.data.get('mockRows') || [],
      rowCount: (this.data.get('mockRows') || []).length,
      command: 'SELECT'
    });
  }

  async getClient() {
    const client = {
      query: this.query.bind(this),
      release: jest.fn()
    };
    return client;
  }

  async end() {
    return Promise.resolve();
  }

  setMockRows(rows) {
    this.data.set('mockRows', rows);
  }

  clearMockRows() {
    this.data.delete('mockRows');
  }

  getLastQuery() {
    return this.queries[this.queries.length - 1];
  }

  getAllQueries() {
    return this.queries;
  }

  clearQueries() {
    this.queries = [];
  }

  reset() {
    this.data.clear();
    this.queries = [];
  }
}

module.exports = new MockDb();
