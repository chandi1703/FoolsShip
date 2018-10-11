/* Handles lemma and marginal note popups */

function lemPopup() {
/*Click function, toggles between visible and unvisible lem content. Creates exit-button.*/
/*Input: 'a'-tags with class 'lem'
Output: visible content of connected lem-div*/

    $("a.lem").each(function () {
        $(this).click(function () {
        
            // Checking for active popups
            filterForActivePopups(".lem.overlay");

            // Compare current key with data-key and remove class invisible if they are the same
            var currentKey = $(this).attr("data-key");
            $("#" + currentKey).removeClass("invisible");
        });
    });

    // function for closing popup
    $(".popup-exit").each(function () {
    
        // if popup-exit icon is clicked, make content invisible again
        $(this).click(function () {
            $(this).parent().addClass("invisible");
        })
    });
}

function filterForActivePopups(classToFilter) {
/*Check for elements with invisible class and add it if it is not already there*/

    $(classToFilter).each(function () {
        if ($(this).hasClass("invisible") == false) {
            $(this).addClass("invisible");
        }
    });
}