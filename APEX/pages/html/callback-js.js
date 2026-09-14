/* Page 3 Execute when Page Loads. No hace falta Hidden en cada ítem. */
(function () {
  function val() {
    for (var i = 0; i < arguments.length; i += 1) {
      var v = $v(arguments[i]);
      if (v && String(v).trim() && String(v).indexOf("&") !== 0) return String(v).trim();
    }
    return "";
  }

  function setText(id, text) {
    var el = document.getElementById(id);
    if (!el) return;
    var row = el.closest ? el.closest(".tp-row") : el.parentElement;
    if (!text) {
      if (row && row.classList && row.classList.contains("tp-row")) row.style.display = "none";
      else el.textContent = "";
      return;
    }
    el.textContent = text;
  }

  var code = val("P3_CODE", "CODE");
  var estado = val("P3_ESTADO");
  var err = val("ERROR", "P3_ERROR");
  var box = document.getElementById("tp_receipt");
  var title = document.getElementById("tp_receipt_title");
  var sub = document.getElementById("tp_receipt_sub");
  if (!box) return;

  setText("tp_r_order", val("P3_ORDER", "ORDER"));
  setText("tp_r_auth", val("P3_AUTH", "AUTH"));
  setText("tp_r_code", code);
  setText("tp_r_desc", val("P3_DESC", "DESCRIPTION"));
  setText("tp_r_brand", val("BRAND"));
  setText("tp_r_estado", estado);

  var errEl = document.getElementById("tp_r_error");
  if (errEl) errEl.textContent = err;

  box.classList.remove("is-ok", "is-pending", "is-fail");

  if (code === "1") {
    box.classList.add("is-ok");
    if (title) title.textContent = "Pago aprobado";
    if (sub) {
      sub.textContent = estado === "PENDIENTE_HASH"
        ? "Tilopay aprobó el cobro. El estado en BD queda PENDIENTE_HASH hasta el HMAC."
        : "Retorno procesado. Estado: " + (estado || "OK");
    }
    return;
  }

  if (code && code !== "1") {
    box.classList.add("is-fail");
    if (title) title.textContent = "Pago no aprobado";
    if (sub) sub.textContent = err || "Tilopay devolvió un código distinto de 1.";
    return;
  }

  box.classList.add("is-pending");
  if (title) title.textContent = "Sin retorno";
  if (sub) sub.textContent = err || "No hay code en la URL.";
})();
