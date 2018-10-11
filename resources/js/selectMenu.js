/*TODO mehrere Dateien daraus machen und Funktionen erläutern:
- Menü Handling Datei
- Popup Lemma Datei
 * 
 * Umbenennen zu richtigen Funktionen und in main.js zusammenführen 
 * */


function personPopup() {
    $("a.person").each(function () {
        $(this).click(function () {
            // Wenn je ein Personenlink geklickt wird, dann sieh erst nach, ob es noch aktive Popups gibt und setze sie wieder unsichtbar, damit immer nicht mehr als ein Popup aktiv ist
            filterForActivePopups(".person.overlay");

            // Vom aktuell geklickten Link, nimm die Info aus @data-key (= key) und benutze diesen Key, um die passende Personeninfo anzuzeigen
            var currentKey = $(this).attr("data-key");
            $("#" + currentKey).removeClass("invisible");
        });
    });

    // Funktion zum Schließen des Popups
    $(".popup-exit").each(function () {
        // Wenn ein Popup-Exit-Link (= Kreuz-Icon) geklickt wird, fuege wieder invisible-Class hinzu und setze das Popup so unsichtbar
        $(this).click(function () {
            $(this).parent().addClass("invisible");
        })
    });
}

// Hilfsfunktion, die aktive Overlays gegebenenfalls wieder unsichtbar setzt, auch ohne dass der User einen "Exit"-Button betätigt
function filterForActivePopups(classToFilter) {
    // Durchsuche alle Elemente einer Klasse und checke, ob sie die "invisible"-Class haben und ergänze sie im Zweifelsfall
    $(classToFilter).each(function () {
        if ($(this).hasClass("invisible") == false) {
            $(this).addClass("invisible");
        }
    });
}


/*Makes use of chosen select plugin; makes the whole select thing rather pleasant */

/*$(function () {
    $('.chosen-select').chosen();
});*/

/*$(function () {
    $('#json3').change(function () {
        $('.chapterL').hide();
        $('#' + $(this).val()).show();
    });
});*/

/*According to what the user clicks on the second select will be changed; uses values from a json file*/
/*$(function () {
    $(".json1").change(function () {
        
        var $dropdown = $(this);
        
        $.getJSON("resources/json/output.json", function (data) {
            var key = $dropdown.val();
            var vals =[];
            
            switch (key) {
                case 'reg':
                vals = data.reg.split(",");
                break;
                case 'orig':
                vals = data.orig.split(",");
                break;
                case 'facs':
                vals = data.facs.split(",");
                break
            }
            
            var $jsontwo = $(".json2");
            
            $jsontwo.empty();
            $jsontwo.append("<option value=''></option>")
            $.each(vals, function (index, value) {
            
                /\*Creates a new value for select menu with regular expression*\/
                $jsontwo.append("<option value=" + value + ">" + value.replace(/(GW[0-9]+).+/g, "$1") + "</option>");
            });
            
            /\*chosen select needs an updated trigger so that new data will be visible in the browser*\/
            $jsontwo.trigger("chosen:updated");
        });
    });
});*/

/*same function as above, only used for the third menu*/
/*$(function () {
    
    $(".json2").change(function () {
        
        var $dropdown = $(this);
        
        $.getJSON("resources/json/output.json", function (data) {
            
            var key = $dropdown.val();
            var vals =[];
            
            switch (key) {
                case 'GW5041reg':
                vals = data.GW5041reg.split(",");
                break;
                case 'GW5041orig':
                vals = data.GW5041orig.split(",");
                break;
                case 'GW5041facs':
                vals = data.GW5041facs.split(",");
                break;
                case 'GW5046reg':
                vals = data.GW5046reg.split(",");
                break;
                case 'GW5046orig':
                vals = data.GW5046orig.split(",");
                break;
                case 'GW5046facs':
                vals = data.GW5046facs.split(",");
                break;
            }
            
            var $jsonthree = $(".json3");
            $jsonthree.empty();
            $jsonthree.append("<option value=''></option>")
            $.each(vals, function (index, value) {
                $jsonthree.append("<option value=" + value + ">Kapitel " + value.replace(/GW[0-9]+([A-Z][0-9]+).+/g, "$1") + "</option>");
            });
            
            $jsonthree.trigger("chosen:updated");
        });
    });
});*/

/*$(function () {
    $(".json4").change(function () {
        
        var $dropdown = $(this);
        
        $.getJSON("resources/json/output.json", function (data) {
            var key = $dropdown.val();
            var vals =[];
            
            switch (key) {
                case 'reg':
                vals = data.reg.split(",");
                break;
                case 'orig':
                vals = data.orig.split(",");
                break;
                case 'facs':
                vals = data.facs.split(",");
                break
            }
            
            var $jsontwo = $(".json5");
            
            $jsontwo.empty();
            $jsontwo.append("<option value=''></option>")
            $.each(vals, function (index, value) {
            
                /\*Creates a new value for select menu with regular expression*\/
                $jsontwo.append("<option value=" + value + ">" + value.replace(/(GW[0-9]+).+/g, "$1") + "</option>");
            });
            
            /\*chosen select needs an updated trigger so that new data will be visible in the browser*\/
            $jsontwo.trigger("chosen:updated");
        });
    });
});*/

/*same function as above, only used for the third menu*/
/*$(function () {
    
    $(".json5").change(function () {
        
        var $dropdown = $(this);
        
        $.getJSON("resources/json/output.json", function (data) {
            
            var key = $dropdown.val();
            var vals =[];
            
            switch (key) {
                case 'GW5041reg':
                vals = data.GW5041reg.split(",");
                break;
                case 'GW5041orig':
                vals = data.GW5041orig.split(",");
                break;
                case 'GW5041facs':
                vals = data.GW5041facs.split(",");
                break;
                case 'GW5046reg':
                vals = data.GW5046reg.split(",");
                break;
                case 'GW5046orig':
                vals = data.GW5046orig.split(",");
                break;
                case 'GW5046facs':
                vals = data.GW5046facs.split(",");
                break;
            }
            
            var $jsonthree = $(".json6");
            $jsonthree.empty();
            $jsonthree.append("<option value=''></option>")
            $.each(vals, function (index, value) {
                $jsonthree.append("<option value=" + value + ">Kapitel " + value.replace(/GW[0-9]+([A-Z][0-9]+).+/g, "$1") + "</option>");
            });
            
            $jsonthree.trigger("chosen:updated");
        });
    });
});*/


