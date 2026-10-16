(function() {
  initMata();

  function initMata() {
    const retryDelayBase = parseInt(document.currentScript.dataset.mataRetry) || 1000;
    const maximumRetryDelay = 30000;
    let retryDelay = retryDelayBase;

    const silent = (document.currentScript.dataset.mataLogLevel || "verbose").toLowerCase() === "silent";

    function log(...arguments) {
      if (!silent) console.log("[Mata]", ...arguments);
    }

    function error(...arguments) {
      if (!silent) console.error("[Mata]", ...arguments);
    }

    const channel = "BroadcastChannel" in window ? new BroadcastChannel("mata") : null;

    if (channel && navigator.locks) {
      // Browsers allow ~6 HTTP/1.1 connections per host, so one tab holds the
      // live reload connection and relays its events to the other tabs.
      channel.onmessage = (event) => handle(event.data);

      navigator.locks.request("mata", () => new Promise(() => connect()));
    } else {
      connect();
    }

    function connect() {
      const eventSource = new EventSource("/__mata/events");

      eventSource.onmessage = function(event) {
        const data = JSON.parse(event.data);

        channel?.postMessage(data);
        handle(data);
      };

      eventSource.onerror = function() {
        eventSource.close();

        log(`Connection lost, retrying in ${retryDelay}ms…`);

        setTimeout(connect, retryDelay);
        retryDelay = Math.min(retryDelay * 2, maximumRetryDelay);
      };
    }

    function handle(data) {
      switch(data.type) {
        case "reload":
          if (data.files?.some((file) => file.endsWith(".js"))) {
            log("JS file changed, reloading…");

            window.location.reload();
          } else {
            morphPage();
          }

          break;
        case "connected":
          retryDelay = retryDelayBase;

          log("Connected with DOM morphing");

          break;
      }
    }

    async function morphPage() {
      try {
        log("Fetching updated page…");
        const response = await fetch(window.location.href);

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }

        const html = await response.text();
        const parser = new DOMParser();
        const updatedDocument = parser.parseFromString(html, "text/html");

        if (!updatedDocument.body) {
          throw new Error("Invalid HTML response");
        }

        Idiomorph.morph(document.documentElement, updatedDocument.documentElement, __MATA_IDIOMORPH_OPTIONS__);

        log("Page morphed successfully");
      } catch (error) {
        error("Morph failed:", error.message);
        log("Falling back to full reload");

        window.location.reload();
      }
    }
  }
})();
