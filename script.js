(() => {
  const form = document.getElementById("generatorForm");
  const emailInput = document.getElementById("email");
  const countInput = document.getElementById("count");
  const rangeSelect = document.getElementById("range");
  const generateBtn = document.getElementById("generateBtn");
  const copyBtn = document.getElementById("copyBtn");
  const resultsEl = document.getElementById("results");
  const historyEl = document.getElementById("history");
  const emailErrorEl = document.getElementById("emailError");
  const countErrorEl = document.getElementById("countError");

  const MAX_HISTORY = 5;
  const history = [];
  let currentLines = [];

  function validateEmail(email) {
    // Simple, practical email validation
    return /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(email.trim());
  }

  function validateCount(count) {
    return Number.isInteger(count) && count >= 1 && count <= 10;
  }

  function randomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  function clearErrors() {
    emailErrorEl.textContent = "";
    countErrorEl.textContent = "";
  }

  function setError(el, message) {
    el.textContent = message;
  }

  function renderResults(lines) {
    resultsEl.innerHTML = "";

    if (!lines.length) {
      resultsEl.innerHTML = `<p class="empty">No results yet.</p>`;
      copyBtn.disabled = true;
      return;
    }

    const frag = document.createDocumentFragment();

    lines.forEach((line) => {
      const item = document.createElement("div");
      item.className = "result-item";
      item.textContent = line;
      frag.appendChild(item);
    });

    resultsEl.appendChild(frag);
    copyBtn.disabled = false;
  }

  function renderHistory() {
    historyEl.innerHTML = "";

    if (!history.length) {
      historyEl.innerHTML = `<p class="empty">No history yet.</p>`;
      return;
    }

    const frag = document.createDocumentFragment();

    history.forEach((entry) => {
      const wrapper = document.createElement("div");
      wrapper.className = "history-item";

      const header = document.createElement("div");
      header.innerHTML = `<strong>${entry.timestamp}</strong> — ${entry.email} (${entry.count} items, range 1-${entry.max})`;

      const list = document.createElement("div");
      list.style.marginTop = "6px";
      list.style.color = "#374151";
      list.style.fontSize = "0.92rem";
      list.textContent = entry.lines.join(" | ");

      wrapper.appendChild(header);
      wrapper.appendChild(list);
      frag.appendChild(wrapper);
    });

    historyEl.appendChild(frag);
  }

  function getTimestamp() {
    return new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", second: "2-digit" });
  }

  function updateGenerateButtonState() {
    const email = emailInput.value.trim();
    const count = Number(countInput.value);
    const isValid = validateEmail(email) && validateCount(count);
    generateBtn.disabled = !isValid;
  }

  async function copyAll() {
    if (!currentLines.length) return;
    const text = currentLines.join("\n");

    try {
      await navigator.clipboard.writeText(text);
      const msg = document.createElement("div");
      msg.className = "copy-success";
      msg.textContent = "Copied to clipboard!";
      resultsEl.appendChild(msg);

      setTimeout(() => {
        msg.remove();
      }, 1400);
    } catch (err) {
      alert("Could not copy automatically. Please copy manually.");
    }
  }

  function handleGenerate(event) {
    event.preventDefault();
    clearErrors();

    const email = emailInput.value.trim();
    const count = Number(countInput.value);
    const maxRange = Number(rangeSelect.value);

    let hasError = false;

    if (!validateEmail(email)) {
      setError(emailErrorEl, "Please enter a valid email address.");
      hasError = true;
    }

    if (!validateCount(count)) {
      setError(countErrorEl, "Count must be an integer from 1 to 10.");
      hasError = true;
    }

    if (hasError) {
      currentLines = [];
      renderResults(currentLines);
      updateGenerateButtonState();
      return;
    }

    const lines = Array.from({ length: count }, () => {
      const n = randomInt(1, maxRange);
      return `${email} — #${n}`;
    });

    currentLines = lines;
    renderResults(lines);

    history.unshift({
      timestamp: getTimestamp(),
      email,
      count,
      max: maxRange,
      lines
    });

    if (history.length > MAX_HISTORY) history.pop();
    renderHistory();
    updateGenerateButtonState();
  }

  // Live validation & button state
  [emailInput, countInput].forEach((input) => {
    input.addEventListener("input", () => {
      clearErrors();
      updateGenerateButtonState();
    });
  });

  form.addEventListener("submit", handleGenerate);
  copyBtn.addEventListener("click", copyAll);

  // Initial state
  updateGenerateButtonState();
  renderResults([]);
  renderHistory();
})();
