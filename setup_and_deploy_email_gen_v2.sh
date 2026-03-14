#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/deenxyz/email-gen.git"
REPO_DIR="email-gen"
BRANCH="main"

if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is required but not installed."
  exit 1
fi

if [ -d "$REPO_DIR/.git" ]; then
  echo "Repo '$REPO_DIR' exists. Pulling latest..."
  cd "$REPO_DIR"
  git checkout "$BRANCH" || true
  git pull origin "$BRANCH" || true
else
  echo "Cloning $REPO_URL..."
  git clone "$REPO_URL"
  cd "$REPO_DIR"
fi

cat > index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Email Suffix Generator</title>
  <link rel="stylesheet" href="styles.css" />
</head>
<body>
  <main class="app-shell">
    <section class="card">
      <h1>Email Suffix Generator</h1>
      <p class="subtitle">
        Enter multiple emails, choose suffix digit length, generate readable output, and download.
      </p>

      <form id="generatorForm" novalidate>
        <div class="field">
          <label for="emails">Email addresses</label>
          <textarea
            id="emails"
            name="emails"
            rows="6"
            placeholder="one@example.com&#10;two@example.com&#10;three@example.com"
            aria-describedby="emailsHelp"
          ></textarea>
          <small id="emailsHelp" class="hint">You can separate emails by new lines, commas, or spaces.</small>
          <small id="emailsError" class="error" aria-live="polite"></small>
        </div>

        <div class="field-grid">
          <div class="field">
            <label for="count">How many per email (1–20)</label>
            <input id="count" name="count" type="number" min="1" max="20" value="1" required />
            <small id="countError" class="error" aria-live="polite"></small>
          </div>

          <div class="field">
            <label for="digits">Digits at end (1–12)</label>
            <input id="digits" name="digits" type="number" min="1" max="12" value="4" required />
            <small id="digitsError" class="error" aria-live="polite"></small>
          </div>

          <div class="field">
            <label for="downloadFormat">Download format</label>
            <select id="downloadFormat" name="downloadFormat">
              <option value="txt" selected>TXT (readable)</option>
              <option value="csv">CSV (spreadsheet)</option>
              <option value="json">JSON (structured)</option>
            </select>
          </div>
        </div>

        <div class="actions">
          <button id="generateBtn" type="submit">Generate</button>
          <button id="copyBtn" type="button" class="ghost" disabled>Copy All</button>
          <button id="downloadBtn" type="button" class="ghost" disabled>Download</button>
        </div>
      </form>
    </section>

    <section class="card">
      <h2>Preview</h2>
      <div id="results" class="results" aria-live="polite" aria-atomic="true">
        <p class="empty">No results yet.</p>
      </div>
    </section>
  </main>

  <script src="script.js"></script>
</body>
</html>
HTML

cat > styles.css <<'CSS'
:root {
  --bg: #f6f8fc;
  --card: #ffffff;
  --text: #111827;
  --muted: #6b7280;
  --primary: #1d4ed8;
  --primary-dark: #1e40af;
  --border: #e5e7eb;
  --error: #dc2626;
  --success: #15803d;
  --radius: 14px;
  --shadow: 0 12px 28px rgba(17, 24, 39, 0.08);
}

* { box-sizing: border-box; }

body {
  margin: 0;
  font-family: Inter, system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
  color: var(--text);
  background: linear-gradient(180deg, #f8fafc 0%, var(--bg) 100%);
}

.app-shell {
  width: min(980px, 94%);
  margin: 28px auto;
  display: grid;
  gap: 16px;
}

.card {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  padding: 18px;
}

h1, h2 { margin: 0 0 10px; }

.subtitle {
  margin: 0 0 16px;
  color: var(--muted);
}

.field {
  display: flex;
  flex-direction: column;
  gap: 7px;
  margin-bottom: 12px;
}

.field-grid {
  display: grid;
  gap: 12px;
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

label {
  font-weight: 600;
  font-size: 0.94rem;
}

textarea, input, select, button {
  font: inherit;
}

textarea, input, select {
  width: 100%;
  border: 1px solid var(--border);
  border-radius: 10px;
  padding: 10px 12px;
  background: #fff;
  outline: none;
  transition: border-color .2s, box-shadow .2s;
}

textarea {
  resize: vertical;
}

textarea:focus, input:focus, select:focus, button:focus-visible {
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(29, 78, 216, .15);
}

.hint {
  color: var(--muted);
  font-size: .82rem;
}

.error {
  color: var(--error);
  min-height: 1em;
  font-size: .82rem;
}

.actions {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 4px;
}

button {
  border: 0;
  border-radius: 10px;
  padding: 10px 14px;
  cursor: pointer;
  transition: opacity .2s, transform .08s, background-color .2s;
}

button:active { transform: translateY(1px); }

#generateBtn {
  background: var(--primary);
  color: #fff;
  font-weight: 600;
}
#generateBtn:hover { background: var(--primary-dark); }

button.ghost {
  background: #eef2ff;
  border: 1px solid #c7d2fe;
  color: #1e3a8a;
}

button:disabled {
  opacity: .5;
  cursor: not-allowed;
}

.results {
  display: grid;
  gap: 8px;
}

.result-item {
  border: 1px solid var(--border);
  background: #fcfcff;
  border-radius: 10px;
  padding: 9px 12px;
  animation: fadeUp .2s ease;
  font-weight: 550;
}

.empty {
  margin: 0;
  color: var(--muted);
}

.copy-success {
  color: var(--success);
  font-size: .88rem;
  margin-top: 6px;
}

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(5px); }
  to { opacity: 1; transform: translateY(0); }
}

@media (max-width: 760px) {
  .field-grid { grid-template-columns: 1fr; }
}
CSS

cat > script.js <<'JS'
(() => {
  const form = document.getElementById("generatorForm");
  const emailsInput = document.getElementById("emails");
  const countInput = document.getElementById("count");
  const digitsInput = document.getElementById("digits");
  const downloadFormatSelect = document.getElementById("downloadFormat");

  const generateBtn = document.getElementById("generateBtn");
  const copyBtn = document.getElementById("copyBtn");
  const downloadBtn = document.getElementById("downloadBtn");

  const resultsEl = document.getElementById("results");

  const emailsErrorEl = document.getElementById("emailsError");
  const countErrorEl = document.getElementById("countError");
  const digitsErrorEl = document.getElementById("digitsError");

  let currentRows = []; // [{email, suffix, output}]

  function clearErrors() {
    emailsErrorEl.textContent = "";
    countErrorEl.textContent = "";
    digitsErrorEl.textContent = "";
  }

  function parseEmails(raw) {
    return raw
      .split(/[\n,\s]+/g)
      .map(v => v.trim())
      .filter(Boolean);
  }

  function isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(email);
  }

  function unique(arr) {
    return [...new Set(arr)];
  }

  function randomDigits(digits) {
    const max = 10 ** digits;
    const value = Math.floor(Math.random() * max);
    return String(value).padStart(digits, "0");
  }

  function validateInputs() {
    clearErrors();

    const rawEmails = emailsInput.value.trim();
    const count = Number(countInput.value);
    const digits = Number(digitsInput.value);

    let valid = true;

    const emails = unique(parseEmails(rawEmails));

    if (!emails.length) {
      emailsErrorEl.textContent = "Please enter at least one email.";
      valid = false;
    } else {
      const invalidEmails = emails.filter(e => !isValidEmail(e));
      if (invalidEmails.length) {
        emailsErrorEl.textContent = `Invalid email(s): ${invalidEmails.join(", ")}`;
        valid = false;
      }
    }

    if (!Number.isInteger(count) || count < 1 || count > 20) {
      countErrorEl.textContent = "Count must be an integer from 1 to 20.";
      valid = false;
    }

    if (!Number.isInteger(digits) || digits < 1 || digits > 12) {
      digitsErrorEl.textContent = "Digits must be an integer from 1 to 12.";
      valid = false;
    }

    return { valid, emails, count, digits };
  }

  function renderResults(rows) {
    resultsEl.innerHTML = "";
    if (!rows.length) {
      resultsEl.innerHTML = `<p class="empty">No results yet.</p>`;
      copyBtn.disabled = true;
      downloadBtn.disabled = true;
      return;
    }

    const frag = document.createDocumentFragment();
    rows.forEach(row => {
      const div = document.createElement("div");
      div.className = "result-item";
      div.textContent = row.output;
      frag.appendChild(div);
    });

    resultsEl.appendChild(frag);
    copyBtn.disabled = false;
    downloadBtn.disabled = false;
  }

  function generateRows(emails, count, digits) {
    const rows = [];
    for (const email of emails) {
      for (let i = 0; i < count; i++) {
        const suffix = randomDigits(digits);
        rows.push({
          email,
          suffix,
          output: `${email}${suffix}`
        });
      }
    }
    return rows;
  }

  async function copyAll() {
    if (!currentRows.length) return;
    const text = currentRows.map(r => r.output).join("\n");
    try {
      await navigator.clipboard.writeText(text);
      const ok = document.createElement("div");
      ok.className = "copy-success";
      ok.textContent = "Copied to clipboard!";
      resultsEl.appendChild(ok);
      setTimeout(() => ok.remove(), 1400);
    } catch {
      alert("Clipboard copy failed. Please copy manually.");
    }
  }

  function downloadFile() {
    if (!currentRows.length) return;

    const format = downloadFormatSelect.value;
    let content = "";
    let mime = "text/plain;charset=utf-8";
    let filename = "email_suffix_results";

    if (format === "txt") {
      content = currentRows.map(r => r.output).join("\n");
      filename += ".txt";
    } else if (format === "csv") {
      const header = "email,suffix,output";
      const body = currentRows
        .map(r => `${escapeCsv(r.email)},${escapeCsv(r.suffix)},${escapeCsv(r.output)}`)
        .join("\n");
      content = `${header}\n${body}`;
      mime = "text/csv;charset=utf-8";
      filename += ".csv";
    } else {
      content = JSON.stringify(currentRows, null, 2);
      mime = "application/json;charset=utf-8";
      filename += ".json";
    }

    const blob = new Blob([content], { type: mime });
    const url = URL.createObjectURL(blob);

    const a = document.createElement("a");
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    a.remove();

    URL.revokeObjectURL(url);
  }

  function escapeCsv(value) {
    const str = String(value);
    if (/[",\n]/.test(str)) {
      return `"${str.replace(/"/g, '""')}"`;
    }
    return str;
  }

  function onGenerate(e) {
    e.preventDefault();
    const { valid, emails, count, digits } = validateInputs();
    if (!valid) {
      currentRows = [];
      renderResults(currentRows);
      return;
    }

    currentRows = generateRows(emails, count, digits);
    renderResults(currentRows);
  }

  function updateGenerateState() {
    const { valid } = validateInputs();
    generateBtn.disabled = !valid;
  }

  [emailsInput, countInput, digitsInput].forEach(el => {
    el.addEventListener("input", updateGenerateState);
  });

  form.addEventListener("submit", onGenerate);
  copyBtn.addEventListener("click", copyAll);
  downloadBtn.addEventListener("click", downloadFile);

  renderResults([]);
  updateGenerateState();
})();
JS

git add index.html styles.css script.js
if git diff --cached --quiet; then
  echo "No changes to commit."
else
  git commit -m "Add multi-email suffix generator with digit length and file download"
  git push origin "$BRANCH"
fi

echo ""
echo "Done. If GitHub Pages is enabled, your site will update at:"
echo "https://deenxyz.github.io/email-gen/"