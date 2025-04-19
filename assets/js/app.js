import "@fortawesome/fontawesome-free/js/fontawesome";
import "@fortawesome/fontawesome-free/js/solid";
import "@fortawesome/fontawesome-free/js/regular";
import "@fortawesome/fontawesome-free/js/brands";

import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "topbar";

import React from "react";
import ReactDOM from "react-dom";

import { App } from "./client";

window.Components = {
  App,
};

/**
 * ReactPhoenix
 *
 * Copied from https://github.com/geolessel/react-phoenix/blob/master/src/react_phoenix.js
 */
class ReactPhoenix {
  static init() {
    const elements = document.querySelectorAll("[data-react-class]");
    Array.prototype.forEach.call(elements, (e) => {
      const targetId = document.getElementById(e.dataset.reactTargetId);
      const targetDiv = targetId ? targetId : e;
      const reactProps = e.dataset.reactProps ? e.dataset.reactProps : "{}";
      const reactElement = React.createElement(window.eval(e.dataset.reactClass), JSON.parse(reactProps));
      ReactDOM.render(reactElement, targetDiv);
    });
  }
}

document.addEventListener("DOMContentLoaded", () => {
  ReactPhoenix.init();
});

// LiveView setup with topbar progress indicator
topbar.config({barColors: {0: "#ff79c6"}, shadowColor: "rgba(0, 0, 0, .3)"});
window.addEventListener("phx:page-loading-start", _info => topbar.show(300));
window.addEventListener("phx:page-loading-stop", _info => topbar.hide());

// Connect LiveView with default options
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}});
liveSocket.connect();
window.liveSocket = liveSocket;
