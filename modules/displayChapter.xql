xquery version "3.1";

module namespace dch="http://oc.narragonien-digital.de/dch";
declare default element namespace "http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://exist-db.org/apps/narrenapp/config" at "config.xqm";

(: Zu Beginn alle Texte in Variablen einlesen :)
declare variable $dch:data := collection('/db/apps/narrenapp/data/GW');
declare variable $dch:lem := collection('/db/apps/narrenapp/data/lemma');


(:declare function dch:lem2html($nodes as node()*, $side as xs:string){

    for $node in $nodes
    return
        typeswitch($node)
        
        case text() return
        $node   
        
        case element(persName) return
            if($node/@type) then
                <div class="lemAlternative">{ dch:lem2html($node/node(),$side) }</div>
            else 
                <h3 class="lemTitle">{ dch:lem2html($node/node(),$side) }</h3>
                
        case element(note) return
            <div class="notes">{ dch:lem2html($node/node(),$side) }</div>
        
        case element(ref) return
            <div class="lemLinks">
                <span><b>{ string($node/@type) }:</b></span>      
                <a class="lemma { $node/@type }" href="{ $node/@source }">{ string($node/@source) }</a>
            </div>
        
        case element() return
                dch:lem2html($node/node(),$side)
                
        default return $node/string()

};:)

declare function dch:tei2html($nodes as node()*,$side as xs:string) {
(: Diese Funktion ist für die Transformation aller TEI Elemente zu HTML zuständig :)

    (: an dieser Stelle Parameter aus der form von synopsis.html auslesen :)
    let $vers1 := request:get-parameter('vers1', '')    
    let $vers2 := request:get-parameter('vers2', '')
    
    for $node in $nodes
    return
        typeswitch($node)
        
            case text() return
                $node
                
            case element (ab) return
            (: ab (anonymous block) stellt alle Elemente aus dem Wiki dar :)
                    
                if ($node/@type = "chapterTitle") then
                    <div class="chapterTitle" style="font-weight:bold;font-size:1.5em;margin-bottom:3%">{ dch:tei2html($node/node(),$side) }</div>
                else if ($node/@type = "mainText") then
                    <div class="mainText">{ dch:tei2html($node/node(),$side) }</div>
                    
                else if ($node/@type = "motto") then
                    <div class="motto" style="font-size:small;margin-bottom:4%">{ dch:tei2html($node/node(),$side) }</div>
                
                else if ($node/@type = "signatureMark") then
                    (<div class="signatureMark" style="font-size:small;margin-top:4%;text-align:right">{ dch:tei2html($node/node(),$side) }</div>,
                    <hr class="pageturn"/>)
                    
                else dch:tei2html($node/node(),$side)
                
            case element (choice) return
            (: Hier müssen Lesefassung und OCR behandelt werden :)
            
                switch($side)
                    case "l" return
                        switch($vers1)
                            case "reg" return
                                <div class='nrm'>{ for $child in $node//reg return dch:tei2html($child,$side) }</div>
                            case "orig" return
                                <div class='ocr'>{ for $child in $node//orig return dch:tei2html($child,$side) }</div>
                            default return ()
                    case "r" return
                        switch($vers2)
                            case "reg" return
                                <div class='nrm'>{ for $child in $node//reg return dch:tei2html($child,$side) }</div>
                            case "orig" return
                                <div class='ocr'>{ for $child in $node//orig return dch:tei2html($child,$side) }</div>
                            default return ()
                    default return "WTF"
                    
            case element (figure) return
                <div class="row">
                    <div class="col-sm-10 col-sm-push-2">
                        <img src="resources/img/{ $node/@facs }" style="height:400px;margin-bottom:4%"/>
                    </div>
                </div>
                
            case element (l) return    
                    <div class="row">
                        <div id="line" class="col-sm-2">{ string($node/@n) }</div>
                        <div id="text" class="col-sm-10">{ dch:tei2html($node/node(),$side) }</div>
                    </div>
                
            case element(ref) return 
            (: ref behandelt die Lemmata, hierfür gibt es noch eine eigene Funktion, viewLem :) 
            
                let $chapter := $node/ancestor::div/@xml:id
                let $uri := util:unescape-uri(replace(base-uri($node), '.+/(.+).xml$', '$1'), 'UTF-8')
                return
                
                <button><a  class="person" data-key="{ concat($uri,$chapter,replace($node/@target,'.+.xml#(.+)$','$1')) }">{ $node/node() }</a></button>
                (:<button data-toggle="collapse" data-target="{ concat('#',$uri,$chapter,replace($node/@target,'.+#(.+)$','$1')) }">{ $node/node() }</button>:)(:,
                let $id := concat($uri,$chapter,replace($node/@target, '.+.xml#(.+)$', '$1' ))
                return
                    dch:viewLem($node,$id,$side):)
                
            case element() return
                dch:tei2html($node/node(),$side)
                
            default return $node/string()
        
};

(:declare function dch:view3($node as node(), $model as map(*), $side as xs:string) {
(\: dch:view3 entscheidet, welche Textteile aus den GWs transformiert und letztendlich angezeigt
werden :\)

    (\: alle Parameter aus der form auslesen :\)
    let $vers1 := request:get-parameter('vers1', '')
    let $book1 := request:get-parameter('book1', '')
    let $chap1 := request:get-parameter('chap1', '')
    let $vers2 := request:get-parameter('vers2', '')
    let $book2 := request:get-parameter('book2', '')
    let $chap2 := request:get-parameter('chap2', '')
    
    return 
    
    switch($side)
    case "l" return
        
        (\: alle Dokumente werden aus der Collection ausgelesen :\)
        for $document in $dch:data
        let $uri := util:unescape-uri(replace(base-uri($document), '.+/(.+).xml$', '$1'), 'UTF-8')
        where concat($uri,$vers1) eq $book1
        return
        
            (\: der body wird aus den Dokumenten herausgezogen :\)
            for $body in $document//body
            return
            
            (\: Parameter aus der form werden abgeglichen mit ids aus den Werken, dann das jeweilige
            Kapitel herausgesucht :\)
            <div id="{concat($uri,$vers1)}" class="GWL">{
                for $chapter in $body//div[@type = 'chapter']
                let $id := string($chapter/@xml:id)
                where concat($uri,$id,$vers1) eq $chap1
                return                   
                <div id="{concat($uri,$id,$vers1)}" class="chapterL">{ dch:tei2html($chapter,$side) }</div>
                         
            }</div>
          
    case "r" return
        for $document in $dch:data
             let $uri := util:unescape-uri(replace(base-uri($document), '.+/(.+).xml$', '$1'), 'UTF-8')
             where concat($uri,$vers2) eq $book2
             return
                 for $body in $document//body
                 return
                 <div id="{concat($uri,$vers2)}" class="GWL">{
                     for $chapter in $body//div[@type = 'chapter']
                     let $id := string($chapter/@xml:id)
                     where concat($uri,$id,$vers2) eq $chap2
                     return                   
                     <div id="{concat($uri,$id,$vers2)}" class="chapterL">{ dch:tei2html($chapter,$side) }</div>
                 }</div>
                 
    default return "WTF"
                              
};:)

declare function dch:showform($node as node(), $model as map(*)){
(: diese Funktion erstellt eine zweite Form und übergibt die Werte der ersten Anfrage als versteckte 
input-Felder, sodass Eingabe1 und Eingabe2 beide gleichzeitig angezeigt werden können :) 

    let $fassung1 := request:get-parameter('vers1', '')
    let $werk1 := request:get-parameter('book1', '')
    let $kapitel1 := request:get-parameter('chap1', '')
    
    return
    
    <div class="col-sm-6">
        <form action="?">
            <fieldset>
                <select class="json4 chosen-select" data-placeholder="Fassung wählen" name="fassung2" style="width:180px">
                    <option value=""/>
                    <option value="facs">Faksimile</option>
                    <option value="reg">Normalisierte Lesefassung</option>
                    <option value="orig">OCR des Original</option>
                    <input type="hidden" name="fassung1" value="{$fassung1}"/>
                </select>
                <select class="json5 chosen-select" data-placeholder="GW wählen" name="werk2" style="width:180px">
                    <input type="hidden" name="werk1" value="{$werk1}"/>
                </select>
                <select class="json6 chosen-select" data-placeholder="Kapitel wählen" name="kapitel2" onchange="this.form.submit()" style="width:180px">
                    <input type="hidden" name="kapitel1" value="{$kapitel1}"/>
                </select>
            </fieldset>
        </form>
    </div>
    
};


declare function dch:viewLem($node as node(), $id as xs:string, $side as xs:string) {
(: Diese Funktion verarbeitet Lemmata aus der Lemmaliste und zeigt diese an :)

    let $smId := replace($id, 'GW[0-9]+[PB][0-9]+(.+)$', '$1')
    for $document in $dch:lem
    return
    
    (for $person in $document//person[@xml:id = $smId]
        return
            <div id="{ $id }" class="collapse lem">{ dch:tei2html($person,$side) }</div>,
            
    for $place in $document//place[@xml:id = $smId]
        return 
            <div id="{ $id }" class="collapse lem">{ dch:tei2html($place,$side) }</div>)
            
};

(:declare function dch:viewLem2($node as node(), $model as map(*), $side as xs:string){
    
    let $fassung1 := request:get-parameter('vers1', '')
    let $werk1 := request:get-parameter('book1', '')
    let $kapitel1 := request:get-parameter('chap1', '')
    
    for $document in $dch:data
    let $uri := util:unescape-uri(replace(base-uri($document), '.+/(.+).xml$', '$1'), 'UTF-8')
    where concat($uri,$fassung1) eq $werk1
    
    (\: der body wird aus den Dokumenten herausgezogen :\)
    for $body in $document//body
        
    (\: Parameter aus der form werden abgeglichen mit ids aus den Werken, dann das jeweilige
    Kapitel herausgesucht :\)
    for $chapter in $body//div[@type = 'chapter']
    let $id := string($chapter/@xml:id)
    where concat($uri,$id,$fassung1) eq $kapitel1  
    
    for $ref in $chapter//ref
    let $LemId := concat($uri,$id,replace($ref/@target, '.+#(.+)$', '$1' ))
    (\:Testing how those ID's look like.:\) 
    (\:return <p>{ $LemId }</p>:\)
    
    let $smId := replace($LemId, 'GW[0-9]+[PB][0-9]+(.+)$', '$1')
    (\:Testing how these stripped ID's look like:\)
    (\:return <p>{ $smId }</p>:\)
      
    for $document in $dch:lem
    return
    
    (for $person in $document//person[@xml:id = $smId]
        return
        
            <div class="person overlay invisible" id="{ $LemId }">  
                <span class="popup-exit">
                      <i class="fas fa-times"></i>
                </span>
                <div class="lemContent">{ dch:lem2html($person,$side) }</div>
            </div>,
            
    for $place in $document//place[@xml:id = $smId]
        return 
            <div class="collapse place" id="{ $LemId }">
            { dch:lem2html($place,$side) }
            </div>,
            
   for $item in $document//item[@xml:id = $smId]
        return
            <div class="collapse item" id="{ $LemId }">
            { dch:lem2html($item,$side) }
            </div>
            )                   
};:)
