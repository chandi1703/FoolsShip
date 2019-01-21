xquery version "3.1";

module namespace app="http://exist-db.org/apps/narrenapp/templates";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://exist-db.org/apps/narrenapp/config" at "config.xqm";

declare variable $app:lem := collection('/db/apps/narrenapp/data/lemma');
declare variable $app:data := collection('/db/apps/narrenapp/data/GW');

declare function app:selectLemma($node as node(), $model as map(*)){
    for $document in $app:lem
    for $item in $document//tei:*[self::tei:person or self::tei:place or self::tei:item]
    let $content := string($item//@xml:id)
    return <div>{$content}</div>
};

declare function app:selectGw($node as node(), $model as map(*)) {
    let $data := collection('/db/apps/narrenapp/data/GW')
    for $document in $data
        let $uri := util:unescape-uri(replace(base-uri($document), '.+/(.+).xml$', '$1'), 'UTF-8')
        return
            (
            <option value=""/>,
            <option
                value="{$uri}facsL">{$uri} Faksimile</option>,
            <option
                value="{$uri}regL">{$uri} Normalisiert</option>,
            <option
                value="{$uri}origL">{$uri} Original</option>)
};

declare function app:selectCh($node as node(), $model as map(*)) {
    let $data := collection('/db/apps/narrenapp/data/GW')
    for $document in $data
    let $uri := util:unescape-uri(replace(base-uri($document), '.+/(.+).xml$', '$1'), 'UTF-8')
        for $chapter in $document//tei:div[@type = 'chapter']
        let $id := string($chapter/@xml:id)
        return
            (
            <option value=""/>,
            <option
                value="{concat($uri,$id)}facsL">Kapitel {$id} Faksimile</option>,
            <option
                value="{concat($uri,$id)}regL">Kapitel {$id} normalisiert</option>,
            <option
                value="{concat($uri,$id)}origL">Kapitel {$id} Original</option>)

};