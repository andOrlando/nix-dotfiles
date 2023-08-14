// ==UserScript==
// @name         MoodleLogin
// @version      0.1
// @description  Clicks the login button in Moodle automatically
// @author       Elijah Sippel
// @match        https://umass.moonami.com/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=moonami.com
// @grant        none
// ==/UserScript==

const collection = document.getElementsByClassName("login");
collection[0].firstElementChild.click();
