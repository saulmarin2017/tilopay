/* Page 1 Execute when Page Loads — app 110. Ítems P1_*. */
(function move3ds() {
  var box = document.getElementById("responseTilopay");
  if (box && box.parentElement !== document.body) {
    document.body.appendChild(box);
  }
})();

(function fillSummary() {
  var monto = $v("P1_MONTO") || "100.00";
  var orden = $v("P1_ORDER_NUMBER") || "—";
  var moneda = $v("P1_MONEDA") || "CRC";
  var elM = document.getElementById("tp_monto_lbl");
  var elO = document.getElementById("tp_orden_lbl");
  if (elM) elM.textContent = monto;
  if (elO) elO.textContent = orden + " · " + moneda;
})();

(function () {
  var token = $v("P1_TOKEN");
  var err   = $v("P1_ERROR");
  var msg   = document.getElementById("tilopay_msg");
  var n = 0;

  function setMsg(text, isError) {
    if (!msg) return;
    msg.textContent = text;
    if (isError) msg.classList.add("is-error");
    else msg.classList.remove("is-error");
  }

  function go() {
    if (typeof Tilopay === "undefined") {
      n += 1;
      if (n > 50) {
        setMsg("No cargó sdk_tpay.min.js", true);
        return;
      }
      setTimeout(go, 100);
      return;
    }
    start();
  }

  function start() {
    if (err) {
      setMsg("No hay token: " + err, true);
      return;
    }
    if (!token) {
      setMsg("P1_TOKEN vacío.", true);
      return;
    }

    Tilopay.Init({
      token: token,
      currency: $v("P1_MONEDA") || "CRC",
      language: "es",
      amount: $v("P1_MONTO") || "100.00",
      billToFirstName: $v("P1_NOMBRE") || "Prueba",
      billToLastName: $v("P1_APELLIDO") || "Navasoft",
      billToAddress: "San Jose",
      billToAddress2: "",
      billToCity: "San Jose",
      billToState: "SJ",
      billToZipPostCode: "10101",
      billToCountry: "CR",
      billToTelephone: "88888888",
      billToEmail: $v("P1_EMAIL"),
      orderNumber: $v("P1_ORDER_NUMBER"),
      capture: 1,
      redirect: $v("P1_REDIRECT"),
      subscription: 0,
      hashVersion: "V2"
    }).then(function (initialize) {
      console.log("Tilopay.Init", initialize);
      setMsg("Listo para pagar", false);
      loadOptions("tlpy_payment_method", initialize.methods || []);
      loadOptions("tlpy_saved_cards", initialize.cards || []);
    }).catch(function (e) {
      setMsg("Init falló: " + e, true);
    });

    function loadOptions(selectId, items) {
      var sel = document.getElementById(selectId);
      if (!sel) return;
      items.forEach(function (item) {
        var opt = document.createElement("option");
        opt.value = item.id;
        opt.text = item.name;
        sel.appendChild(opt);
      });
    }

    var selMet = document.getElementById("tlpy_payment_method");
    if (selMet) {
      selMet.onchange = function () {
        var parts = (this.value || "").split(":");
        var isYappy = parts[1] === "18";
        document.getElementById("tlpy_card_payment_div").style.display = isYappy ? "none" : "block";
        document.getElementById("tlpy_phone_number_div").style.display = isYappy ? "block" : "none";
      };
    }

    var btnP = document.getElementById("btn_pagar");
    if (btnP) {
      btnP.onclick = function (ev) {
        if (ev) ev.preventDefault();
        var met = document.getElementById("tlpy_payment_method");
        if (!met || !met.value) {
          setMsg("Elegí el método de pago.", true);
          return false;
        }
        setMsg("Enviando a Tilopay…", false);
        Tilopay.startPayment()
          .then(function (p) {
            console.log("startPayment", p);
            setMsg((p && p.message) || "Procesando pago…", false);
          })
          .catch(function (e) {
            console.log("startPayment error", e);
            setMsg("Pagar error: " + e, true);
          });
        return false;
      };
    }

    var btnS = document.getElementById("btn_sinpe");
    if (btnS) {
      btnS.onclick = function () {
        Tilopay.getSinpeMovil().then(function (params) {
          var box = document.getElementById("sinpe_box");
          box.style.display = "block";
          box.textContent = "SINPE tel " + (params.number || "") +
            " monto " + (params.amount || "") +
            " código " + (params.code || "");
        });
      };
    }
  }

  go();
})();
