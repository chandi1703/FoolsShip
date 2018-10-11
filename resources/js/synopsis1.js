/* This file handles dynamic menu structure in synopsis.html */

function chosenSelect(){
 /* Activates chosen-select plugin which makes menus searchable
    Uses class "chosen-select" */    
    $(function () {  
        $('.chosen-select').chosen();
})};

function menuVers1(){
/* Changes second menu according to the choice of the version (normalisierte Lesefassung,
OCR Version, Faksimile) */
/* Input: resource/json/output.json , generated by documentToJson.xsl 
Ouput: generated second menu with class json2 */

    $(function () {
        $(".json1").change(function () {       
            var $dropdown = $(this);
            
            //takes json-data 
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
                
                //creates first empty option. Chosen select will fill it with data-placeholder from synopsis.html
                $jsontwo.append("<option value=''></option>")
                $.each(vals, function (index, value) {
                
                    //Creates a new value for select menu with regular expression
                    $jsontwo.append("<option value=" + value + ">" + value.replace(/(GW[0-9]+).+/g, "$1") + "</option>");
                });
                
                //chosen select needs an updated trigger so that new data will be visible in the browser
                $jsontwo.trigger("chosen:updated");
            });
        });
})};

function menuBook1(){
/* Changes third menu according to the choice of the book */
/* Input: resource/json/output.json , generated by documentToJson.xsl 
Ouput: generated third menu with class json3 */

    $(function () {
    
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
})};

function menuVers2(){
/* Changes fifth menu according to the choice of the version (normalisierte Lesefassung,
OCR Version, Faksimile) */
/* Input: resource/json/output.json , generated by documentToJson.xsl 
Ouput: generated second menu with class json5 */

    $(function () {
        $(".json4").change(function () {       
            var $dropdown = $(this);
            
            //takes json-data 
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
                
                var $jsonfive = $(".json5");             
                $jsonfive.empty();
                
                //creates first empty option. Chosen select will fill it with data-placeholder from synopsis.html
                $jsonfive.append("<option value=''></option>")
                $.each(vals, function (index, value) {
                
                    //Creates a new value for select menu with regular expression
                    $jsonfive.append("<option value=" + value + ">" + value.replace(/(GW[0-9]+).+/g, "$1") + "</option>");
                });
                
                //chosen select needs an updated trigger so that new data will be visible in the browser
                $jsonfive.trigger("chosen:updated");
            });
        });
})};

function menuBook2(){
/* Changes sixth menu according to the choice of the book */
/* Input: resource/json/output.json , generated by documentToJson.xsl 
Ouput: generated third menu with class json6 */

    $(function () {
    
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
            
            var $jsonsix = $(".json6");
            $jsonsix.empty();
            $jsonsix.append("<option value=''></option>")
            $.each(vals, function (index, value) {
                $jsonsix.append("<option value=" + value + ">Kapitel " + value.replace(/GW[0-9]+([A-Z][0-9]+).+/g, "$1") + "</option>");
            });
            
            $jsonsix.trigger("chosen:updated");
        });
    });
})};