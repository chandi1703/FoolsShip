xquery version "3.1";
(: This file handles lems and marginal notes of fool's ships in synopsis.html. :)

module namespace syn3="http://oc.narragonien-digital.de/syn3";
declare default element namespace "http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://exist-db.org/apps/narrenapp/config" at "config.xqm";

(: Save data-content in variables :)
declare variable $syn3:data := collection('/db/apps/narrenapp/data/GW');
declare variable $syn3:lem := collection('/db/apps/narrenapp/data/lemma');

declare function syn3:getLem($side as xs:string, $vers as xs:string, $book as xs:string, $chap as xs:string){
(: Gets lem data according to data the user has chosen. See also syn3:viewLem() :)
(: Input: $side, $vers (chosen version), $book (chosen GW), $chap (chosen chapter)
Ouput: all lems from chosen chapter :)

    for $document in $syn3:data
    let $uri := util:unescape-uri(replace(base-uri($document), '.+/(.+).xml$', '$1'), 'UTF-8')
    where concat($uri, $vers) eq concat($book, $vers)
    
    (: take body from document :)
    for $body in $document//body
        
    (: search for chapter which equals parameters chosen from user :)
    (: Set counter at pos :)
    for $chapter at $pos in $body//div[@type = 'chapter']
    let $id := string($chapter/@xml:id)
    let $numId := concat($uri, 'n' ,$pos)
    where $numId eq $chap  
    
    for $ref in $chapter//ref
    
    (: create lem id for output and connection to the fool's ship text :)
    let $lemId := concat($uri,$id,replace($ref/@target, '.+#(.+)$', '$1' ))
    
    (: create small id for checking with lem xml-file :)
    let $smId := replace($lemId, 'GW[0-9]+[PB][0-9]+(.+)$', '$1')
      
    for $document in $syn3:lem
    return
    (for $person in $document//person[@xml:id = $smId]
        return
        
            <div class="lem{$side} overlay invisible" id="{ $lemId }">  
                <span class="popup-exit">
                      <i class="fas fa-times"></i>
                </span>
                
                <!-- lem2html transforms TEI-form of lems into html -->
                <div class="lemContent">{ syn3:lem2html($person,$side) }</div>
            </div>,
            
    for $place in $document//place[@xml:id = $smId]
        return 
        
            <div class="lem{$side} overlay invisible" id="{ $lemId }">  
                <span class="popup-exit">
                      <i class="fas fa-times"></i>
                </span>
                
                <!-- lem2html transforms TEI-form of lems into html -->
                <div class="lemContent">{ syn3:lem2html($place,$side) }</div>
            </div>,
            
   for $item in $document//item[@xml:id = $smId]
        return
            
            <div class="lem{$side} overlay invisible" id="{ $lemId }">  
                <span class="popup-exit">
                      <i class="fas fa-times"></i>
                </span>
                
                <!-- lem2html transforms TEI-form of lems into html -->
                <div class="lemContent">{ syn3:lem2html($item,$side) }</div>
            </div>
    )
};

declare function syn3:viewLem($node as node(), $model as map(*), $side as xs:string){
(: Compares user's chapter choice with lem-file (data/lemma) and returns all lems that are available in current chapter :)
(: Input: $node, $side (distinguishes between left and right synopsis-window)
Output: all lems in current chapter -> persons, places, items :)

    let $vers1 := request:get-parameter('vers1', '')
    let $book1 := request:get-parameter('book1', '')
    let $chap1 := request:get-parameter('chap1', '')
    let $vers2 := request:get-parameter('vers2', '')
    let $book2 := request:get-parameter('book2', '')
    let $chap2 := request:get-parameter('chap2', '')
    return 
    
    switch($side)
    case "l" return
        syn3:getLem($side,$vers1,$book1,$chap1)   
    case "r" return
        syn3:getLem($side,$vers2,$book2,$chap2)
    default return "Something went wrong here"
};

declare function syn3:lem2html($nodes as node()*, $side as xs:string){
(: transforms lems from syn3:viewLem() into html :)
(: Input: TEI/XML lem from data/lemma
Output: HTML lem :)

    for $node in $nodes
    return
        typeswitch($node)
        
        case text() return
        $node   
        
        (: handles element persName :)
        case element(persName) return
            if($node/@type) then
                <div class="lemAlternative">{ syn3:lem2html($node/node(),$side) }</div>
            else 
                <h3 class="lemTitle">{ syn3:lem2html($node/node(),$side) }</h3>
        
        (: handles element placeName :)
        case element(placeName) return
            if($node/@type) then
                <div class="lemAlternative">{ syn3:lem2html($node/node(),$side) }</div>
            else 
                <h3 class="lemTitle">{ syn3:lem2html($node/node(),$side) }</h3>
        
        (: handles element span :)
        case element(span) return
            if($node/@type) then
                <div class="lemAlternative">{ syn3:lem2html($node/node(),$side) }</div>
            else 
                <h3 class="lemTitle">{ syn3:lem2html($node/node(),$side) }</h3>

        (: handles element note :)
        case element(note) return
            <div class="notes">{ syn3:lem2html($node/node(),$side) }</div>
        
        (: handles element ref :)
        case element(ref) return
            <div class="lemLinks">
                <span><b>{ string($node/@type) }:</b></span>      
                <a class="lemma { $node/@type }" href="{ $node/@source }">{ string($node/@source) }</a>
            </div>
        
        case element() return
                syn3:lem2html($node/node(),$side)
                
        default return $node/string()
};