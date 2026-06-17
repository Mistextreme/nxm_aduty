(function () {
    const RESOURCE = 'NXM_Aduty';

    const $  = (sel) => document.querySelector(sel);
    const $$ = (sel) => document.querySelectorAll(sel);

    const els = {
        app:           $('#app'),
        // Brand
        logoImg:       $('#logoImg'),
        logoText:      $('#logoText'),
        brandName:     $('#brandName'),
        brandSubtitle: $('#brandSubtitle'),
        // Nav
        navBtns:       $$('.nav-btn'),
        navRanks:      $('#navRanks'),
        navList:       $('#navList'),
        navLogs:       $('#navLogs'),
        listBadge:     $('#listBadge'),
        // Sidebars
        sideRanks:     $('#sideRanks'),
        sideList:      $('#sideList'),
        sideLogs:      $('#sideLogs'),
        // Ranks
        rankList:      $('#rankList'),
        search:        $('#search'),
        empty:         $('#empty'),
        editor:        $('#editor'),
        rankKey:       $('#rankKey'),
        rankLabel:     $('#rankLabel'),
        rankPriority:  $('#rankPriority'),
        fields:        $('#fields'),
        // Settings
        setGod:        $('#setGod'),
        setHeal:       $('#setHeal'),
        setArmor:      $('#setArmor'),
        setBlipColor:  $('#setBlipColor'),
        setBlipSprite: $('#setBlipSprite'),
        colorDot:      $('#colorDot'),
        // Buttons (Editor)
        btnAdd:        $('#btnAdd'),
        btnClose:      $('#btnClose'),
        btnClose2:     $('#btnClose2'),
        btnClose3:     $('#btnClose3'),
        btnSave:       $('#btnSave'),
        btnDelete:     $('#btnDelete'),
        btnImport:     $('#btnImport'),
        btnCopy:       $('#btnCopy'),
        btnPreview:    $('#btnPreview'),
        btnPreviewRst: $('#btnPreviewReset'),
        btn3D:         $('#btn3D'),
        btn3DClose:    $('#btn3DClose'),
        preview3D:     $('#preview3D'),
        // List View
        listView:      $('#listView'),
        listTable:     $('#listTable'),
        listCount:     $('#listCount'),
        listSearch:    $('#listSearch'),
        btnListRefresh:$('#btnListRefresh'),
        // Logs
        logs:          $('#logs'),
        logTable:      $('#logTable'),
        logCount:      $('#logCount'),
        logSearch:     $('#logSearch'),
        btnLogRefresh: $('#btnLogRefresh'),
        // Generic
        tabs:          document.querySelectorAll('#editor .tab'),
        tabs3D:        document.querySelectorAll('#preview3D .tab'),
        toast:         $('#toast'),
        confirm:       $('#confirm'),
        confirmTitle:  $('#confirmTitle'),
        confirmText:   $('#confirmText'),
        confirmOk:     $('#confirmOk'),
        confirmCancel: $('#confirmCancel'),
    };

    // ====================================================
    // State
    // ====================================================
    let outfits      = [];
    let fieldsList   = [];
    let activeList   = [];
    let selectedKey  = null;
    let currentSex   = 'male';
    let isNew        = false;
    let workingData  = { male: {}, female: {} };
    let view         = 'ranks';
    let canManage    = true;
    let in3D         = false;
    let logDebounce  = null;
    let listDebounce = null;
    let i18n         = {};

    // ====================================================
    // Translation
    // ====================================================
    function t(key, ...args) {
        let str = i18n[key] || key;
        for (let i = 0; i < args.length; i++) {
            str = str.replace(/%s|%d/, args[i]);
        }
        return str;
    }

    function applyI18n() {
        // textContent for elements with data-i18n
        document.querySelectorAll('[data-i18n]').forEach(el => {
            const k = el.getAttribute('data-i18n');
            if (i18n[k]) el.textContent = i18n[k];
        });
        // placeholder for elements with data-i18n-ph
        document.querySelectorAll('[data-i18n-ph]').forEach(el => {
            const k = el.getAttribute('data-i18n-ph');
            if (i18n[k]) el.placeholder = i18n[k];
        });
        // title attribute for elements with data-i18n-title
        document.querySelectorAll('[data-i18n-title]').forEach(el => {
            const k = el.getAttribute('data-i18n-title');
            if (i18n[k]) el.title = i18n[k];
        });
    }

    // ====================================================
    // NUI helpers
    // ====================================================
    async function post(endpoint, data = {}) {
        try {
            const res = await fetch(`https://${RESOURCE}/${endpoint}`, {
                method:  'POST',
                headers: { 'Content-Type': 'application/json' },
                body:    JSON.stringify(data),
            });
            return await res.json().catch(() => ({}));
        } catch (e) { return {}; }
    }

    let toastTimer = null;
    function toast(msg, type = 'info') {
        els.toast.className = 'toast ' + type;
        els.toast.textContent = msg;
        els.toast.classList.remove('hidden');
        clearTimeout(toastTimer);
        toastTimer = setTimeout(() => els.toast.classList.add('hidden'), 2500);
    }

    function confirmModal(title, text) {
        return new Promise((resolve) => {
            els.confirmTitle.textContent = title;
            els.confirmText.textContent  = text;
            els.confirm.classList.remove('hidden');
            const onOk = () => { cleanup(); resolve(true);  };
            const onNo = () => { cleanup(); resolve(false); };
            const cleanup = () => {
                els.confirm.classList.add('hidden');
                els.confirmOk.removeEventListener('click', onOk);
                els.confirmCancel.removeEventListener('click', onNo);
            };
            els.confirmOk.addEventListener('click', onOk);
            els.confirmCancel.addEventListener('click', onNo);
        });
    }

    function escapeHtml(s) {
        return String(s ?? '').replace(/[&<>"']/g, c => ({
            '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;',
        }[c]));
    }

    function hexToRgba(hex, a = 1) {
        const m = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex || '');
        if (!m) return null;
        return `rgba(${parseInt(m[1],16)}, ${parseInt(m[2],16)}, ${parseInt(m[3],16)}, ${a})`;
    }

    // ====================================================
    // Theme & Branding injection
    // ====================================================
    function applyUI(ui) {
        ui = ui || {};

        if (ui.brandName)     els.brandName.textContent = ui.brandName;
        if (ui.brandSubtitle) els.brandSubtitle.textContent = ui.brandSubtitle;

        if (ui.logoImage) {
            els.logoImg.src = ui.logoImage;
            els.logoImg.classList.remove('hidden');
            els.logoText.classList.add('hidden');
        } else {
            els.logoImg.classList.add('hidden');
            els.logoText.classList.remove('hidden');
            if (ui.logoText) els.logoText.textContent = ui.logoText;
        }

        const t = ui.theme || {};
        const root = document.documentElement.style;
        const map = {
            bg0: '--bg-0', bg1: '--bg-1', bg2: '--bg-2', bg3: '--bg-3',
            border: '--border', text: '--text', textDim: '--text-dim',
            textMute: '--text-mute', accent: '--accent', accent2: '--accent-2',
            success: '--success', danger: '--danger', warn: '--warn',
        };
        for (const [key, cssVar] of Object.entries(map)) {
            if (t[key]) root.setProperty(cssVar, t[key]);
        }
        if (t.accent) {
            const glow = hexToRgba(t.accent, .35);
            if (glow) root.setProperty('--accent-glow', glow);
        }
    }

    // ====================================================
    // View Switch (ranks <-> list <-> logs)
    // ====================================================
    function switchView(v) {
        view = v;
        els.navBtns.forEach(b => b.classList.toggle('active', b.dataset.view === v));

        els.sideRanks.classList.add('hidden');
        els.sideList.classList.add('hidden');
        els.sideLogs.classList.add('hidden');
        els.empty.classList.add('hidden');
        els.editor.classList.add('hidden');
        els.listView.classList.add('hidden');
        els.logs.classList.add('hidden');

        if (v === 'ranks') {
            els.sideRanks.classList.remove('hidden');
            if (selectedKey || isNew) {
                els.editor.classList.remove('hidden');
            } else {
                els.empty.classList.remove('hidden');
            }
        } else if (v === 'list') {
            els.sideList.classList.remove('hidden');
            els.listView.classList.remove('hidden');
            renderActiveList();
        } else if (v === 'logs') {
            els.sideLogs.classList.remove('hidden');
            els.logs.classList.remove('hidden');
            loadLogs(els.logSearch.value || '');
        }
    }
    els.navBtns.forEach(b => b.addEventListener('click', () => {
        if (b.hasAttribute('disabled')) return;
        switchView(b.dataset.view);
    }));

    // ====================================================
    // Rank list (sidebar)
    // ====================================================
    function renderRankList(filter = '') {
        const f = filter.toLowerCase();
        els.rankList.innerHTML = '';

        const filtered = outfits.filter(o =>
            o.rank_key.toLowerCase().includes(f) ||
            (o.label || '').toLowerCase().includes(f)
        );

        if (filtered.length === 0) {
            const empty = document.createElement('div');
            empty.style.cssText = 'padding:20px;text-align:center;color:var(--text-mute);font-size:12px;';
            empty.textContent = outfits.length === 0 ? t('ui_empty_no_ranks') : t('ui_empty_no_matches');
            els.rankList.appendChild(empty);
            return;
        }

        for (const o of filtered) {
            const item = document.createElement('div');
            item.className = 'rank-item' + (o.rank_key === selectedKey ? ' active' : '');
            item.innerHTML = `
                <div>
                    <div class="label">${escapeHtml(o.label || o.rank_key)}</div>
                    <div class="key">${escapeHtml(o.rank_key)}</div>
                </div>
                <span class="prio">P:${o.priority ?? 100}</span>
            `;
            item.addEventListener('click', () => selectRank(o.rank_key));
            els.rankList.appendChild(item);
        }
    }

    function renderFields() {
        els.fields.innerHTML = '';
        const data = workingData[currentSex] || {};
        for (const key of fieldsList) {
            const wrap = document.createElement('div');
            wrap.className = 'comp';
            wrap.innerHTML = `
                <label>${key}</label>
                <input type="number" data-key="${key}"
                       value="${(data[key] !== undefined && data[key] !== null) ? data[key] : 0}" />
            `;
            const input = wrap.querySelector('input');
            input.addEventListener('input', (e) => {
                const v = parseInt(e.target.value, 10);
                workingData[currentSex][key] = Number.isFinite(v) ? v : 0;
                if (in3D) push3DUpdate();
            });
            els.fields.appendChild(wrap);
        }
    }

    const BLIP_COLORS = {
        0: '#ffffff', 1: '#ef4444', 2: '#22c55e', 3: '#3b82f6', 4: '#06b6d4',
        5: '#eab308', 6: '#f97316', 7: '#a855f7', 8: '#ec4899', 9: '#92400e',
        10:'#78716c', 11:'#84cc16', 12:'#6b7280', 13:'#1e3a8a', 14:'#0ea5e9',
        17:'#fbbf24', 25:'#000000', 38:'#fde047',
    };
    function updateColorDot() {
        const c = parseInt(els.setBlipColor.value, 10);
        els.colorDot.style.background = BLIP_COLORS[c] || '#cbd5e1';
    }

    // ====================================================
    // Rank select / new
    // ====================================================
    function selectRank(key) {
        const o = outfits.find(x => x.rank_key === key);
        if (!o) return;

        selectedKey = key;
        isNew = false;

        els.rankKey.value      = o.rank_key;
        els.rankLabel.value    = o.label || '';
        els.rankPriority.value = o.priority ?? 100;
        els.rankKey.disabled   = true;

        els.setGod.checked     = !!o.god_mode;
        els.setHeal.checked    = !!o.auto_heal;
        els.setArmor.checked   = !!o.auto_armor;
        els.setBlipColor.value = o.blip_color ?? 3;
        els.setBlipSprite.value= o.blip_sprite ?? 1;
        updateColorDot();

        workingData = {
            male:   { ...(o.male_data   || {}) },
            female: { ...(o.female_data || {}) },
        };

        els.empty.classList.add('hidden');
        els.editor.classList.remove('hidden');

        renderRankList(els.search.value);
        renderFields();
    }

    function newRank() {
        selectedKey = null;
        isNew = true;

        els.rankKey.value       = '';
        els.rankLabel.value     = '';
        els.rankPriority.value  = 100;
        els.rankKey.disabled    = false;

        els.setGod.checked      = false;
        els.setHeal.checked     = true;
        els.setArmor.checked    = true;
        els.setBlipColor.value  = 3;
        els.setBlipSprite.value = 1;
        updateColorDot();

        const empty = {};
        for (const k of fieldsList) empty[k] = 0;
        workingData = { male: { ...empty }, female: { ...empty } };

        els.empty.classList.add('hidden');
        els.editor.classList.remove('hidden');

        renderRankList(els.search.value);
        renderFields();
        els.rankKey.focus();
    }

    // ====================================================
    // Tabs (sex)
    // ====================================================
    els.tabs.forEach(t => {
        t.addEventListener('click', () => {
            els.tabs.forEach(x => x.classList.remove('active'));
            t.classList.add('active');
            currentSex = t.dataset.sex;
            renderFields();
            if (in3D) push3DUpdate();
        });
    });
    els.tabs3D.forEach(t => {
        t.addEventListener('click', () => {
            els.tabs3D.forEach(x => x.classList.remove('active'));
            t.classList.add('active');
            currentSex = t.dataset.sex;
            els.tabs.forEach(x => x.classList.toggle('active', x.dataset.sex === currentSex));
            renderFields();
            push3DUpdate();
        });
    });

    // ====================================================
    // CRUD
    // ====================================================
    function collectPayload() {
        const key = (els.rankKey.value || '').trim().toLowerCase().replace(/[^a-z0-9_]/g, '');
        return {
            rank_key:    key,
            label:       (els.rankLabel.value || '').trim() || key,
            priority:    parseInt(els.rankPriority.value, 10) || 100,
            male_data:   workingData.male,
            female_data: workingData.female,
            god_mode:    !!els.setGod.checked,
            auto_heal:   !!els.setHeal.checked,
            auto_armor:  !!els.setArmor.checked,
            blip_color:  parseInt(els.setBlipColor.value, 10)  || 3,
            blip_sprite: parseInt(els.setBlipSprite.value, 10) || 1,
        };
    }

    els.btnAdd.addEventListener('click', newRank);
    els.btnClose.addEventListener('click',  () => post('close'));
    els.btnClose2.addEventListener('click', () => post('close'));
    els.btnClose3.addEventListener('click', () => post('close'));

    els.btnSave.addEventListener('click', async () => {
        const payload = collectPayload();
        if (!payload.rank_key) { toast(t('ui_toast_key_missing'), 'error'); return; }
        await post('save', payload);
        toast(t('ui_toast_saved'), 'success');
        await refreshOutfits();
        selectedKey = payload.rank_key;
        isNew = false;
        els.rankKey.disabled = true;
        renderRankList(els.search.value);
    });

    els.btnDelete.addEventListener('click', async () => {
        if (!selectedKey) { toast(t('ui_toast_nothing_delete'), 'warn'); return; }
        const ok = await confirmModal(
            t('ui_confirm_delete_title'),
            t('ui_confirm_delete_text', selectedKey)
        );
        if (!ok) return;
        await post('delete', { rank_key: selectedKey });
        toast(t('ui_toast_deleted'), 'success');
        selectedKey = null;
        els.editor.classList.add('hidden');
        els.empty.classList.remove('hidden');
        await refreshOutfits();
    });

    els.btnImport.addEventListener('click', async () => {
        const res = await post('importCurrent');
        if (!res || !res.components) { toast(t('ui_toast_outfit_load_failed'), 'error'); return; }
        const sex = res.sex === 1 ? 'female' : 'male';
        currentSex = sex;
        els.tabs.forEach(tab => tab.classList.toggle('active', tab.dataset.sex === sex));
        for (const [k, v] of Object.entries(res.components)) {
            workingData[currentSex][k] = (typeof v === 'number') ? v : 0;
        }
        renderFields();
        toast(sex === 'female' ? t('ui_toast_imported_female') : t('ui_toast_imported_male'), 'success');
    });

    els.btnCopy.addEventListener('click', () => {
        const other = currentSex === 'male' ? 'female' : 'male';
        workingData[other] = { ...workingData[currentSex] };
        toast(other === 'female' ? t('ui_toast_copied_to_female') : t('ui_toast_copied_to_male'), 'info');
    });

    els.btnPreview.addEventListener('click', async () => {
        await post('preview', { components: workingData[currentSex] });
        toast(t('ui_toast_preview_active'), 'info');
    });
    els.btnPreviewRst.addEventListener('click', async () => {
        await post('previewReset');
        toast(t('ui_toast_preview_reset'), 'info');
    });

    // 3D
    async function start3D() {
        in3D = true;
        els.app.classList.add('hidden');
        els.preview3D.classList.remove('hidden');
        els.tabs3D.forEach(x => x.classList.toggle('active', x.dataset.sex === currentSex));
        await post('preview3DStart', { components: workingData[currentSex] });
    }
    async function stop3D() {
        in3D = false;
        els.preview3D.classList.add('hidden');
        els.app.classList.remove('hidden');
        await post('preview3DStop');
    }
    async function push3DUpdate() {
        if (!in3D) return;
        await post('preview3DUpdate', { components: workingData[currentSex] });
    }
    els.btn3D.addEventListener('click', start3D);
    els.btn3DClose.addEventListener('click', stop3D);

    els.search.addEventListener('input', (e) => renderRankList(e.target.value));
    els.setBlipColor.addEventListener('input', updateColorDot);

    async function refreshOutfits() {
        const res = await post('refresh');
        outfits = (res && res.outfits) || [];
        renderRankList(els.search.value);
    }

    // ====================================================
    // Active List
    // ====================================================
    function getInitials(name) {
        const parts = String(name).split(/\s+/).filter(Boolean);
        if (parts.length === 0) return '?';
        if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
        return (parts[0][0] + parts[1][0]).toUpperCase();
    }

    function renderActiveList() {
        const filter = (els.listSearch.value || '').toLowerCase().trim();
        els.listTable.innerHTML = '';

        const filtered = activeList.filter(p => !filter ||
            String(p.src).includes(filter) ||
            (p.name || '').toLowerCase().includes(filter) ||
            (p.rank_label || '').toLowerCase().includes(filter)
        );

        els.listCount.textContent = t('ui_list_count', filtered.length);
        els.listBadge.textContent = activeList.length;

        if (filtered.length === 0) {
            const empty = document.createElement('div');
            empty.className = 'empty-state';
            empty.textContent = activeList.length === 0
                ? t('ui_list_count_empty')
                : t('ui_list_count_no_match');
            els.listTable.appendChild(empty);
            return;
        }

        for (const p of filtered) {
            const card = document.createElement('div');
            card.className = 'player-card';
            const offBtn = canManage
                ? `<button class="btn-danger" data-id="${p.src}">${escapeHtml(t('ui_list_btn_force_off'))}</button>`
                : '';
            card.innerHTML = `
                <div class="player-card-head">
                    <div class="player-avatar">${escapeHtml(getInitials(p.name))}</div>
                    <div class="player-info">
                        <div class="player-name">${escapeHtml(p.name)}</div>
                        <div class="player-rank">${escapeHtml(p.rank_label)}</div>
                    </div>
                    <span class="player-id-chip">#${p.src}</span>
                </div>
                <div class="player-actions">
                    ${offBtn}
                    <button class="btn-secondary" data-logs="${p.src}">${escapeHtml(t('ui_list_btn_logs'))}</button>
                </div>
            `;
            const off = card.querySelector('[data-id]');
            if (off) off.addEventListener('click', async () => {
                const ok = await confirmModal(
                    t('ui_confirm_forceoff_title'),
                    t('ui_confirm_forceoff_text', p.name, p.src)
                );
                if (!ok) return;
                await post('forceOff', { id: p.src });
                toast(t('ui_toast_forceoff_sent'), 'success');
            });
            const logBtn = card.querySelector('[data-logs]');
            if (logBtn) logBtn.addEventListener('click', () => {
                els.logSearch.value = String(p.src);
                switchView('logs');
            });
            els.listTable.appendChild(card);
        }
    }

    els.listSearch.addEventListener('input', () => {
        clearTimeout(listDebounce);
        listDebounce = setTimeout(renderActiveList, 150);
    });
    els.btnListRefresh.addEventListener('click', async () => {
        const res = await post('refreshActive');
        activeList = (res && res.activeList) || [];
        renderActiveList();
        toast(t('ui_toast_list_refreshed'), 'info');
    });

    // ====================================================
    // Logs
    // ====================================================
    async function loadLogs(query) {
        const res = await post('getLogs', { query: query || '', limit: 100 });
        const rows = (res && res.logs) || [];
        const suffix = rows.length === 1 ? t('ui_logs_count_singular') : t('ui_logs_count_plural');
        els.logCount.textContent = t('ui_logs_count', rows.length, suffix);
        els.logTable.innerHTML = '';
        if (rows.length === 0) {
            const empty = document.createElement('div');
            empty.style.cssText = 'text-align:center;padding:50px;color:var(--text-mute);font-family:inherit;';
            empty.textContent = t('ui_logs_empty');
            els.logTable.appendChild(empty);
            return;
        }
        for (const r of rows) {
            const row = document.createElement('div');
            row.className = 'log-row';
            row.innerHTML = `
                <div class="log-time">${escapeHtml(r.created_at)}</div>
                <div class="log-action ${escapeHtml(r.action)}">${escapeHtml(r.action)}</div>
                <div class="log-player">${escapeHtml(r.player_name)}</div>
                <div class="log-rank">${escapeHtml(r.rank_key || '-')}</div>
                <div class="log-actor">${escapeHtml(r.actor || '')}</div>
            `;
            els.logTable.appendChild(row);
        }
    }
    els.logSearch.addEventListener('input', (e) => {
        clearTimeout(logDebounce);
        const v = e.target.value;
        logDebounce = setTimeout(() => loadLogs(v), 250);
    });
    els.btnLogRefresh.addEventListener('click', () => loadLogs(els.logSearch.value));

    // ====================================================
    // NUI Listener
    // ====================================================
    window.addEventListener('message', (ev) => {
        const data = ev.data || {};
        if (data.action === 'open') {
            outfits     = data.outfits || [];
            fieldsList  = data.fields  || [];
            activeList  = data.activeList || [];
            canManage   = data.canManage !== false;
            selectedKey = null;
            isNew       = false;
            els.search.value    = '';
            els.logSearch.value = data.logFilter || '';
            els.listSearch.value= '';
            i18n        = data.i18n || {};
            applyI18n();
            applyUI(data.ui || {});

            // Tabs sichtbar/disabled je nach Permission
            els.navRanks.toggleAttribute('disabled', !canManage);
            els.navLogs.toggleAttribute('disabled',  !canManage);

            els.toast.classList.add('hidden');
            els.app.classList.remove('hidden');

            // Initial-Tab
            const tab = data.initTab || 'ranks';
            switchView(tab);
            renderRankList();
            els.listBadge.textContent = activeList.length;
            updateColorDot();
        } else if (data.action === 'close') {
            els.app.classList.add('hidden');
            els.preview3D.classList.add('hidden');
            in3D = false;
        } else if (data.action === 'updateActiveList') {
            activeList = data.activeList || [];
            els.listBadge.textContent = activeList.length;
            if (view === 'list') renderActiveList();
        } else if (data.action === '3dPreviewClosed') {
            in3D = false;
            els.preview3D.classList.add('hidden');
            els.app.classList.remove('hidden');
        }
    });

    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            if (in3D) return;
            post('close');
        }
    });
})();
