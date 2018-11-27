xquery version "3.1";
(: This file handles the forms of synopsis.html. :)

module namespace syn1="http://oc.narragonien-digital.de/syn1";
declare default element namespace "http://www.tei-c.org/ns/1.0";

import module namespace syn4="http://oc.narragonien-digital.de/syn4" at "synopsis4.xql";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://exist-db.org/apps/narrenapp/config" at "config.xqm";
import module namespace functx="http://www.functx.com";

declare function syn1:createForm($node as node(), $model as map(*)){
(: Creates a second form. Takes parameters the user has chosen from the first form and keeps them hidden 
in the second form.

Input: html-form from synopsis-page
Output: second form with hidden parameters the user has chosen from first form :)

    (: takes chosen parameters for version, book and chapter from form1 :)
    let $vers := request:get-parameter('vers1', ''),
         $book := request:get-parameter('book1', ''),
         $chap := request:get-parameter('chap1', '')   
    return
    
    <div class="col-sm-6">
        <form action="?">
            <fieldset>
            
                {syn4:create-link($node,$model,"previous","r")}
                <!-- json4 class is necessary for TODO .js-file -->
                <!-- chosen-select is class for chosen jquery plugin -->
                <select class="json4 chosen-select" data-placeholder="Fassung wählen" name="vers2" style="width:150px">
                    <option value=""/>
                    <option value="facs">Faksimile</option>
                    <option value="reg">Normalisierte Lesefassung</option>
                    <option value="orig">OCR des Original</option>
                    <input type="hidden" name="vers1" value="{ $vers }"/>
                </select>
                <select class="json5 chosen-select" data-placeholder="GW wählen" name="book2" style="width:150px">
                    <input type="hidden" name="book1" value="{ $book }"/>
                </select>
                <select class="json6 chosen-select" data-placeholder="Kapitel wählen" name="chap2" onchange="this.form.submit()" style="width:150px">
                    <input type="hidden" name="chap1" value="{ $chap }"/>
                </select>
                {syn4:create-link($node,$model,"next","r")}
            </fieldset>
        </form>
    </div>   
};
