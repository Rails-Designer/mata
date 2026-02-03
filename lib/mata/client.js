(function() {
  initMata();

  function initMata() {
    const eventSource = new EventSource("/__mata/events");

    eventSource.onmessage = function(event) {
      const data = JSON.parse(event.data);

      switch(data.type) {
        case "reload":
          morphPage();

          break;
        case "connected":
          console.log("[Mata] Connected with DOM morphing");

          break;
      }
    };

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

    eventSource.onerror = function() {
      console.log("[Mata] Connection lost, retrying…");
    };
  }
})();
