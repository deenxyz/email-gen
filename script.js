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
      .split(/[,\s]+/g)
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
    if (/[",\n\r]/.test(str)) {
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
