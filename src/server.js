const express = require('express');
const compression = require('compression');
const path = require('path');
const fs = require('fs');

function createServer() {
  const app = express();
  app.use(compression());

  let cachedData = null;
  let htmlTemplate = null;

  function friendlyError(err) {
    const msg = err.message || String(err);
    if (err.code === 'ENOENT') return { error: 'Claude Code data directory not found. Have you used Claude Code yet?', code: 'ENOENT' };
    if (err.code === 'EPERM' || err.code === 'EACCES') return { error: 'Permission denied reading Claude Code data. Try running with elevated permissions.', code: err.code };
    return { error: msg };
  }

  function buildLitePayload() {
    return {
      ...cachedData,
      sessions: cachedData.sessions.map(s => {
        const { queries, ...rest } = s;
        return rest;
      })
    };
  }

  async function ensureData() {
    if (!cachedData) {
      cachedData = await require('./parser').parseAllSessions();
    }
  }

  // Serve index.html with data injected inline (main entry point)
  app.get('/', async (req, res) => {
    try {
      await ensureData();
      if (!htmlTemplate) {
        htmlTemplate = fs.readFileSync(path.join(__dirname, 'public', 'index.html'), 'utf-8');
      }
      const payload = JSON.stringify(buildLitePayload());
      const injected = htmlTemplate.replace(
        '</head>',
        `<script>window.__PRELOADED_DATA__=${payload};</script>\n</head>`
      );
      res.set('Content-Type', 'text/html');
      res.set('Cache-Control', 'no-store');
      res.send(injected);
    } catch (err) {
      res.status(500).send('Error: ' + err.message);
    }
  });

  // Also serve at /dashboard for convenience
  app.get('/dashboard', async (req, res) => {
    try {
      await ensureData();
      if (!htmlTemplate) {
        htmlTemplate = fs.readFileSync(path.join(__dirname, 'public', 'index.html'), 'utf-8');
      }
      const payload = JSON.stringify(buildLitePayload());
      const injected = htmlTemplate.replace(
        '</head>',
        `<script>window.__PRELOADED_DATA__=${payload};</script>\n</head>`
      );
      res.set('Content-Type', 'text/html');
      res.set('Cache-Control', 'no-store');
      res.send(injected);
    } catch (err) {
      res.status(500).send('Error: ' + err.message);
    }
  });

  // API endpoints (kept for direct access / refresh)
  app.get('/api/data', async (req, res) => {
    try {
      await ensureData();
      res.set('Cache-Control', 'no-store');
      res.json(buildLitePayload());
    } catch (err) {
      res.status(500).json(friendlyError(err));
    }
  });

  app.get('/api/session/:id', async (req, res) => {
    try {
      await ensureData();
      const session = cachedData.sessions.find(s => s.sessionId === req.params.id);
      if (!session) return res.status(404).json({ error: 'Session not found' });
      res.json(session);
    } catch (err) {
      res.status(500).json(friendlyError(err));
    }
  });

  app.get('/api/refresh', async (req, res) => {
    try {
      delete require.cache[require.resolve('./parser')];
      cachedData = await require('./parser').parseAllSessions();
      htmlTemplate = null; // force re-read
      res.json({ ok: true, sessions: cachedData.sessions.length });
    } catch (err) {
      res.status(500).json(friendlyError(err));
    }
  });

  // Serve other static assets (CSS, JS, images — but NOT index.html at /)
  app.use(express.static(path.join(__dirname, 'public')));

  return app;
}

module.exports = { createServer };
