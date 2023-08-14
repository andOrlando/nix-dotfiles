// ==UserScript==
// @name         SPIRE Redirect
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  Redirects from the ugly SPIRE interface to the new mobile one
// @author       Elijah Sippel
// @match        https://www.spire.umass.edu/psp/heproda/EMPLOYEE/SA/c/SA_LEARNER_SERVICES.SSS_STUDENT_CENTER.GBL?FolderPath=PORTAL_ROOT_OBJECT.HCCC_ACADEMIC_RECORDS.HC_SSS_STUDENT_CENTER&IsFolder=false&IgnoreParamTempl=FolderPath%2cIsFolder
// @match
// @icon         https://www.google.com/s2/favicons?sz=64&domain=umass.edu
// @grant        none
// ==/UserScript==

(function() {
    'use strict';
    const oldUrlPath = window.location.href;
    const newURL = oldUrlPath + "&gsmobile=1";
    window.location.replace (newURL);
})();
