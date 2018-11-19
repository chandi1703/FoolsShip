xquery version "3.1";
(: This file handles the forms of synopsis.html. Also creates previous-next-buttons :)

module namespace syn1="http://oc.narragonien-digital.de/syn1";
declare default element namespace "http://www.tei-c.org/ns/1.0";

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
            
                <!-- json4 class is necessary for TODO .js-file -->
                <!-- chosen-select is class for chosen jquery plugin -->
                <select class="json4 chosen-select" data-placeholder="Fassung wählen" name="vers2" style="width:180px">
                    <option value=""/>
                    <option value="facs">Faksimile</option>
                    <option value="reg">Normalisierte Lesefassung</option>
                    <option value="orig">OCR des Original</option>
                    <input type="hidden" name="vers1" value="{ $vers }"/>
                </select>
                <select class="json5 chosen-select" data-placeholder="GW wählen" name="book2" style="width:180px">
                    <input type="hidden" name="book1" value="{ $book }"/>
                </select>
                <select class="json6 chosen-select" data-placeholder="Kapitel wählen" name="chap2" onchange="this.form.submit()" style="width:180px">
                    <input type="hidden" name="chap1" value="{ $chap }"/>
                </select>
            </fieldset>
        </form>
    </div>   
};

declare function syn1:previousnext($node as node(), $model as map(*), $direction as xs:string){
(: Creates previous-next-buttons. :)
(: Output: Linked previous-next-buttons. :)
    
    let $vers := request:get-parameter('vers1', ''),
         $book := request:get-parameter('book1', ''),
         $chap := request:get-parameter('chap1', ''),
         $uri := request:get-uri(),
         (: gets continous number of chapter id for counting :) 
         (: functx imported :) 
         $chap-number := number(functx:substring-after-match($chap, 'GW[0-9]+[a-z]+'))
         
    return
    (: build new link :)
    switch($direction)
    case "previous" return
        <a href="{$uri}?vers1={$vers}&amp;book1={$book}&amp;chap1={concat(replace($chap, '(GW[0-9]+[a-z]+)[0-9]+$', '$1'), string($chap-number - 1))}">
            <!-- fontawesome -->
            <button type="button" class="btn btn-secondary btn-sm">
                <i class="fas fa-angle-double-left"/>
            </button>
        </a>
    case "next" return
        <a href="{$uri}?vers1={$vers}&amp;book1={$book}&amp;chap1={concat(replace($chap, '(GW[0-9]+[a-z]+)[0-9]+$', '$1'), string($chap-number + 1))}">
            <!-- fontawesome -->
            <button type="button" class="btn btn-secondary btn-sm">
                <i class="fas fa-angle-double-right"/>
            </button>
        </a>
    default return "blättern nicht möglich"
};