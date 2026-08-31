(function() {
  initMata();

  function initMata() {
    const retryDelayBase = parseInt(document.currentScript.dataset.mataRetry) || 1000;
    const maximumRetryDelay = 30000;
    let retryDelay = retryDelayBase;

    connect();

    function connect() {
      const eventSource = new EventSource("/__mata/events");

      eventSource.onmessage = function(event) {
        const data = JSON.parse(event.data);

        switch(data.type) {
          case "reload":
            if (data.files?.some((file) => file.endsWith(".js"))) {
              console.log("[Mata] JS file changed, reloading…");

              window.location.reload();
            } else {
              morphPage();
            }

            break;
          case "connected":
            retryDelay = retryDelayBase;

            console.log("[Mata] Connected with DOM morphing");

            break;
        }
      };

      eventSource.onerror = function() {
        eventSource.close();

        console.log(`[Mata] Connection lost, retrying in ${retryDelay}ms…`);

        setTimeout(connect, retryDelay);
        retryDelay = Math.min(retryDelay * 2, maximumRetryDelay);
      };
    }

    async function morphPage() {
      try {
        console.log("[Mata] Fetching updated page…");
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

        Idiomorph.morph(document.documentElement, updatedDocument.documentElement, {
          ignoreActiveValue: true,
          callbacks: {
            beforeNodeMorphed: function(oldNode, _) {
              if (oldNode.tagName && oldNode.tagName.includes("-")) { // skip custom elements
                return false;
              }

              return true;
            }
          }
        });

        console.log("[Mata] Page morphed successfully");
      } catch (error) {
        console.error("[Mata] Morph failed:", error.message);
        console.log("[Mata] Falling back to full reload");

        window.location.reload();
      }
    }
  }
})();
