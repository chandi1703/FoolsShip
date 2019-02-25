xquery version "3.1";
(: This file gets all marginalia in fools ship and displays them at the end of a chapter. Also handles links to lems and marginal notes. :)
(: Especially deals with ab[@type='marginalie'] :)

module namespace syn6 = "http://oc.narragonien-digital.de/syn6";
declare default element namespace "http://www.tei-c.org/ns/1.0";

import module namespace templates = "http://exist-db.org/xquery/templates";
import module namespace config = "http://exist-db.org/apps/narrenapp/config" at "config.xqm";

(: Save data-content in variables :)
declare variable $syn6:data := collection('/db/apps/narrenapp/data/GW');
declare variable $syn6:bel := collection('/db/apps/narrenapp/data/beleg');
declare variable $syn6:lem := collection('/db/apps/narrenapp/data/lemma');

declare function syn6:viewMarg($node as node(), $model as map(*), $side as xs:string) {
(: gets all chosen values from user and calls function getMarg :)
(: Input: $side (distinguishes between left and right synopsis-window)
Output: no direct output. Redirects to getMarg function :)
    
    let $vers1 := request:get-parameter('vers1', '')
    let $book1 := request:get-parameter('book1', '')
    let $chap1 := request:get-parameter('chap1', '')
    let $vers2 := request:get-parameter('vers2', '')
    let $book2 := request:get-parameter('book2', '')
    let $chap2 := request:get-parameter('chap2', '')
    return
    switch( $side )
    case "l" return
        syn6:getMarg( $vers1, $book1, $chap1 )
    case "r" return
        syn6:getMarg( $vers2, $book2, $chap2 )
    default return "It didn't work out"
};

declare function syn6:getMarg($vers as xs:string, $book as xs:string, $chap as xs:string) {
(: gets all elements ab[@type='marginalie'] from the current chapter :)
(: Input: values chosen from user 
Output: left side --> marginalia
             right side --> data from lemma.xml and belege.xml :)

    for $document in $syn6:data
    let $uri := util:unescape-uri(replace(base-uri($document), '.+/(.+).xml$', '$1'), 'UTF-8')
        where concat($uri, $vers) eq concat($book, $vers)
        
    (: take body from document :)
    for $body in $document//body
    
    (: search for chapter which equals parameters chosen from user :)
    (: Set counter at pos :)
    for $chapter at $pos in $body//div[@type = 'chapter']
    let $numId := concat($uri, 'n', $pos)
    
    (: Check for correct chapter :)
    where $numId eq $chap   
    return 
    (:horizontal line for seperating main text from footnote:)
    ( <hr class="margNote"/>,
    (: Counter is needed because double marginalia are possible :)
    for $marginalie at $pos in $chapter/ab[@type = "marginalie"]
    return
    ( <div class="row">
        
        <!-- left side all marginalia from chosen chapter -->
        <div class="col-sm-4">
            { for $line in $marginalie//reg//l 
            return
            
                    (: If marginal note is lemma as well call function buildLem :)
                    if ( $line/ref ) then 
                        <div>{ syn6:buildLem(string(replace($line/ref/@target, '.+.xml#(.+)$', '$1')), $line) }</div>
                    else
                        <div>{ $line }</div> }
        <!-- Column End -->
        </div> 
        
        <!-- right side all text from belege.xml, calls function buildBel -->
        { if ( $marginalie//note != "") then
            <div class="col-sm-8">   
                   <a data-toggle="modal" data-target="#{ $pos }" class="clickBeleg"><i class="fas fa-caret-right"/> Belege</a>
                   <div class="modal fade" id="{ $pos }" role="dialog">
                         <div class="modal-dialog modal-md">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal">&#215;</button>
                                    <h1 class="modal-title"><b>{ for $line in $marginalie//reg//l 
                                                                                    return <span>{ $line }</span> }</b></h1>
                                </div>
                                <div class="modal-body">
                                      <p> { for $ref in $marginalie//note/ref
                                             let $id := string( replace($ref/@target, '.+.xml#(.+)$', '$1') )
                                             return
                                             if ( $id != "" ) then                                                          
                                                  <div>{ syn6:buildBel( $id, string( $pos ) ) }</div>
                                             else () }
                                      </p>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal"
                                        >Schließen</button>
                                </div>
                            <!-- End Modal Content -->
                            </div>
                         <!-- End Modal Dialog -->
                        </div> 
                        <!-- Modal End-->
                        </div> 
                 <!-- Column End -->
                </div>
                
                else () }
            <!-- Row End -->
             </div>,
            <hr/> )
            )
};

declare function syn6:buildLem($id as xs:string, $marg as xs:string) {
(: deals with lemmata inside of ab[@type='marginalie'] :)
(: Input: id as it is given in element ab[@type='marginalie'], marg as current text from element marginalie 
Output: link to lemma or plaintext, if there is content in lemma.xml for given id :)

    (: Check id's and get item from lemma.xml :)
    let $item := $syn6:lem//*[self::person or self::place or self::item][@xml:id = $id]
    return
    
    (: if item is not empty create popover link :)
    if ( $item != '' ) then
        (: tabindex and data-trigger: Popover vanishes by clicking anywhere on the screen
        data-html allows to write html into attribute values
        data-placement: auto puts popup window where there is space. Default top
        data-content: data inside of popover window. Takes notes from lem file and creates link to modal window with id as data-target :)
        <a
                 tabindex="0"
                 data-trigger="focus"
                 class="btn btn-info btn-sm leml"
                 data-toggle="popover"
                 data-content="{ $item//note[not(descendant::note)] } &lt;a data-toggle='modal' data-target='#{ $id }'&gt; ...mehr&lt;/a&gt;"
                 data-placement="auto top"
                 data-html="true">{ $marg }</a>
                 
      (: if empty just return plain text :)
      else <div>{ $marg }</div>
};

declare function syn6:buildBel( $id as xs:string, $pos as xs:string ) {
(: deals with marginal notes inside of ab[@type='marginalie'] :)
(: Input: id as it is given in element ab[@type='marginalie']
Output: collapse for marginal note text :)
    
    (: only take bibl elements which have a span child – span contains text. Ignore elements without text 
    also adding counter because double notes are possible :)
    
       for $document in $syn6:bel
       for $bel in $document//bibl[child::span][@xml:id = $id]   
       return
       (<div>{ $bel/span[@type='text']/text() }</div>,
       <br/>)
              
                (:{ for $bel in $document//bibl[child::span][@xml:id = $id]   
                  return
                :)  
            
            (: Block 1: create link button to marginal note text :)
            (:<a class="btn btn-default btn-sm leml"
            data-toggle='collapse'
            data-target='#{ concat( $id, '_', $pos ) }'>{ $bel/title/text() }</a>,
            
            (\: Block 2: fetch marginal note :\) 
            <div id='{ concat( $id, '_', $pos ) }' class='collapse'>
            { $bel/span[@type='text']/text() }
            </div>:) 
};