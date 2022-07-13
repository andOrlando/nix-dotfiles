// ==UserScript==
// @name                UMass Amherst Next U Thing Skipper
// @description         Skips that godawful timer
// @version             1.0
// @include             https://orientation.umass.edu/*
// ==/UserScript==

document.addEventListener("keydown", handlePressedKey);

function handlePressedKey(event) {

  // If the pressed key is coming from any input field, do nothing.
  const target = event.target;
  if (target.localName === "input" || target.localName === "textarea" || target.isContentEditable) return;

  // Mapping keys with actions.
  const key = event.key;
  if (key === "!") document.querySelector("#arrowRight").classList.remove("disabled");
}

console.log("running skipper thing")
