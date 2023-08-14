// ==UserScript==
// @name HTML Regex
// @description Performs a regex search raw html
// @author Bennett Gillig
// @grant GM_setClipboard
// ==/UserScript==

const bind = ""
let ctrl_down = false

document.addEventListener("keydown", event => { ctrl_down = event.key == "Control" ? true : ctrl_down })
document.addEventListener("keyup", event => { ctrl_down = event.key == "Control" ? false : ctrl_down })

document.addEventListener("keydown", event => {
	// we don't care if you don't press ctrl-bind
	if (!ctrl_down || event.key != bind) return

	let doc = new XMLSerializer().serializeToString(document)
	let re = new RegExp(prompt("Enter regular expression"), "g")
	let res = Array.from(doc.matchAll(re))
	console.log(re)
	console.log(res)
	res = res.map(a => a[1])
	console.log(res)

	let tocopy = res.reduce((b, a) => b + "\n" + a)
	GM_setClipboard(tocopy)
	alert("Copied to clipboard: \n" + tocopy)
	console.log(tocopy)
})
