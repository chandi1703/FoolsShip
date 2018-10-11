xquery version "3.1";

module namespace dch2="http://oc.narragonien-digital.de/dch2";
declare default element namespace "http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://exist-db.org/apps/narrenapp/config" at "config.xqm";

declare function dch2:transform($n){
    
    let $data := collection('/db/apps/narrenapp/data')
    for $document in $data
        let $uri := util:unescape-uri(replace(base-uri($document), '.+/(.+).xml$', '$1'), 'UTF-8')

        return
    
        typeswitch($n)
        case element(body)        
            return <div id="{$uri}" class="GWL">{
            for $child in $n/*
            return dch2:transform($child)
            }</div>
            
        case element() return element { node-name($n)} {
        for $child in $n/(@*|node())
        return dch2:transform($child)
  }
  default return $n
};

declare function dch2:takeP($n as xs:string){
    
    let $data := collection('/db/apps/narrenapp/data')
    for $document in $data//$n
    let $body := $document
    
    return dch2:transform($body)
    
};

(:declare function dch:lem($line as node()){:)
(:    for $lem in $line//ref:)
(:    return :)
(:        <a href="#">{$lem}</a>:)
(:};:)
(::)
(:declare function dch:loadCh($version as xs:string, $path as xs:string) {:)
(:    :)
(:let $data := collection('/db/apps/narrenapp/data'):)
(:    for $document in $data:)
(:           let $uri := util:unescape-uri(replace(base-uri($document), '.+/(.+).xml$', '$1'), 'UTF-8'):)
(:           return:)
(:                            :)
(:           (: in Werke aufsplitten :)       :)
(:           <div id="{concat($uri,$version)}" class="GWL">:)
(:           {:)
(:               for $chapter in $document//div[@type = 'chapter']:)
(:               let $id := string($chapter/@xml:id):)
(:               return:)
(:                                        :)
(:               (: normalisierte Kapitel in GW einfügen, nicht anzeigen, erst nach Auswahl; siehe CSS :):)
(:               <div id="{concat($uri,$id,$version)}" class="chapterL" style="display:none">:)
(:                        :)
(:                       {:)
(:                       (: ermöglicht Einbindung der verschiedenen Varianten in einer Funktion :):)
(:                       :)
(:                       switch($path):)
(:                            case "reg" return (   :)
(:                                :)
(:                                for $line in $chapter//reg//l:)
(:                                return:)
(:                                    :)
(:                                    <p>:)
(:                                    <div class="row">:)
(:                                        <div id="line" class="col-sm-2">{string($line/@n)}</div>:)
(:                                        <div id="text" class="col-sm-10">{string($line), dch:lem($line)}</div>:)
(:                                    </div>:)
(:                                    </p>):)
(:                       :)
(:                            case "orig" return ( :)
(:                                for $line in $chapter//orig//l:)
(:                                return:)
(:                                 <p>:)
(:                                 <div class="row">:)
(:                                        <div id="line" class="col-sm-2">{string($line/@n)}</div>:)
(:                                        <div id="text" class="col-sm-10">{string($line)}</div>:)
(:                                 </div>:)
(:                                 </p>):)
(:                       :)
(:                            default return "Something went horribly wrong here":)
(:                       }:)
(:                </div>:)
(:             }:)
(:             </div>:)
(:};:)

