// ==UserScript==
// @name        popup example
// @include     http://stackoverflow.com/*
// @require     http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js
// @grant       GM_addStyle
// ==/UserScript==
/*- The @grant directive is needed to work around a design change
    introduced in GM 1.0.   It restores the sandbox.
*/

//--- Use jQuery to add the form in a "popup" dialog.
$("body").append ( '                                                          \
    <div id="gmPopupContainer">                                               \
    <form> <!-- For true form use method="POST" action="YOUR_DESIRED_URL" --> \
        <input type="text" id="myNumber1" value="">                           \
        <input type="text" id="myNumber2" value="">                           \
                                                                              \
        <p id="myNumberSum">&nbsp;</p>                                        \
        <button id="gmAddNumsBtn" type="button">Add the two numbers</button>  \
        <button id="gmCloseDlgBtn" type="button">Close popup</button>         \
    </form>                                                                   \
    </div>                                                                    \
' );


//--- Use jQuery to activate the dialog buttons.
$("#gmAddNumsBtn").click ( function () {
    var A   = $("#myNumber1").val ();
    var B   = $("#myNumber2").val ();
    var C   = parseInt(A, 10) + parseInt(B, 10);

    $("#myNumberSum").text ("The sum is: " + C);
} );

$("#gmCloseDlgBtn").click ( function () {
    $("#gmPopupContainer").hide ();
} );


//--- CSS styles make it work...
GM_addStyle ( "                                                 \
    #gmPopupContainer {                                         \
        position:               fixed;                          \
        top:                    30%;                            \
        left:                   20%;                            \
        padding:                2em;                            \
        background:             powderblue;                     \
        border:                 3px double black;               \
        border-radius:          1ex;                            \
        z-index:                777;                            \
    }                                                           \
    #gmPopupContainer button{                                   \
        cursor:                 pointer;                        \
        margin:                 1em 1em 0;                      \
        border:                 1px outset buttonface;          \
    }                                                           \
" );
