(:~
 : This is the main XQuery which will (by default) be called by controller.xql
 : to process any URI ending with ".html". It receives the HTML from
 : the controller and passes it to the templating system.
 :)
xquery version "3.1";

import module namespace templates="http://exist-db.org/xquery/templates" ;

(: 
 : The following modules provide functions which will be called by the 
 : templating.
 :)
import module namespace config="http://exist-db.org/apps/narrenapp/config" at "config.xqm";
import module namespace app="http://exist-db.org/apps/narrenapp/templates" at "app.xql";
import module namespace dch="http://oc.narragonien-digital.de/dch" at "displayChapter.xql";
import module namespace syn1="http://oc.narragonien-digital.de/syn1" at "synopsis1.xql";
import module namespace syn2="http://oc.narragonien-digital.de/syn2" at "synopsis2.xql";
import module namespace syn3="http://oc.narragonien-digital.de/syn3" at "synopsis3.xql";
import module namespace syn4="http://oc.narragonien-digital.de/syn4" at "synopsis4.xql";
import module namespace syn5="http://oc.narragonien-digital.de/syn5" at "synopsis5.xql";
import module namespace syn6="http://oc.narragonien-digital.de/syn6" at "synopsis6.xql";
import module namespace sin_ed = "http://oc.narragonien-digital.de/sin_ed" at "sin_ed.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

let $config := map {
    $templates:CONFIG_APP_ROOT : $config:app-root,
    $templates:CONFIG_STOP_ON_ERROR : true()
}
(:
 : We have to provide a lookup function to templates:apply to help it
 : find functions in the imported application modules. The templates
 : module cannot see the application modules, but the inline function
 : below does see them.
 :)
let $lookup := function($functionName as xs:string, $arity as xs:int) {
    try {
        function-lookup(xs:QName($functionName), $arity)
    } catch * {
        ()
    }
}
(:
 : The HTML is passed in the request from the controller.
 : Run it through the templating system and return the result.
 :)
let $content := request:get-data()
return
    templates:apply($content, $lookup, (), $config)