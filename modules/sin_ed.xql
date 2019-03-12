xquery version "3.1";

module namespace sin_ed = "http://oc.narragonien-digital.de/sin_ed";
declare default element namespace "http://www.tei-c.org/ns/1.0";

import module namespace templates = "http://exist-db.org/xquery/templates";
import module namespace config = "http://exist-db.org/apps/narrenapp/config" at "config.xqm";
import module namespace functx = "http://www.functx.com";

declare variable $sin_ed:books := bla;
declare variable $sin_ed:data := collection('/db/apps/narrenapp/data/GW');

declare function local:get_params(){
    let $book := request:get-parameter('book_sin', ''),
        $page := request:get-parameter('page', '')
    return $book, $page
};

declare function sin_ed:choose_book($node as node(), $model as map(*)){
    let $chosen := <div class="menue-element pull-right"><select
                                class="chosen-select synMenu"
                                data-placeholder="Ausgabe wählen"
                                name="book_sin"
                                style="width:100%">
                                <option value=""/>
                                    <option value="GW5041">Brandt, 'Narrenschiff' Basel 11.2.1494</option>
                                    <option value="GW5046">Brandt, 'Narrenschiff' Basel 3.3.1495</option>
                                    <option value="GW5047">Brandt, 'Narrenschiff' Basel 12.2.1499</option>
                                    <option value="GW5042">Brandt, 'Narrenschiff' Nürnberger Bearb.</option>
                            </select>
                            </div>
        return $chosen 
};

declare function sin_ed:choose_page($node as node(), $model as map(*)){
    let $max_page := 200, (:: TODO: maxlength function ::)
    
        $form :=
            <div class="md-form menue-element">
                <textarea type="text" id="form1" class="md-textarea form-control" placeholder="0-{$max_page}" rows="1"></textarea>
            </div>
    return $form
};

declare function sin_ed:show_content($node as node(), $model as map(*)){
    let $content := 
        <div class="content_text">
            {local:prep_GW(request:get-parameter('book_sin', ''))}
        </div>
    return $content
};

declare function local:prep_GW($gw){
    let $raw_xml := fn:doc(concat("/db/apps/narrenapp/data/GW/", $gw, ".xml"))
    return 
        $raw_xml
};

declare function local:page_count($text){
    let $counter := count(distinct-values($text/**/pb/@facs))
    return $counter
};
