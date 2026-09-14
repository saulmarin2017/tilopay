/* Page 3 Execute when Page Loads — app 110. Ítems P3_*. No pintar token. */
(function () {
  var code = ($v("P3_CODE") || "").trim();
  var estado = ($v("P3_ESTADO") || "").trim();
  var err = ($v("P3_ERROR") || "").trim();
  var box = document.getElementById("tp_receipt");
  var title = document.getElementById("tp_receipt_title");
  var sub = document.getElementById("tp_receipt_sub");
  if (!box) return;

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
