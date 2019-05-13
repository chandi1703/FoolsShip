xquery version "3.1";
(: This file handles lems of fool's ships in synopsis.html. :)

module namespace syn3 = "http://oc.narragonien-digital.de/syn3";
declare default element namespace "http://www.tei-c.org/ns/1.0";

import module namespace templates = "http://exist-db.org/xquery/templates";
import module namespace config = "http://exist-db.org/apps/narrenapp/config" at "config.xqm";

declare function syn3:getLem($vers as xs:string, $book as xs:string, $chap as xs:string) {
	
	let $document := doc(concat('/db/apps/narrenapp/data/GW/', string($book), '.xml'))
	let $lem := collection('/db/apps/narrenapp/data/lemma/?select=*.xml')
	
	let $chapnumber := replace($chap, 'GW[0-9]+n', '')
	let $chapter := $document//div[@type = 'chapter'][@n = $chapnumber]
	return
		
		if ($chapter//ref != '') then
		
			for $ref in distinct-values($chapter//ref/string(@target))
			let $lemId := replace($ref, '.+#(.+)$', '$1')

			for $item in $lem//*[self::person or self::place or self::item][@xml:id = $lemId]
			return
				(: Klasse Modal von Bootstrap. Bildet ein Fenster mit weiterführenden Informationen :)
				<div
					class="modal fade"
					id="{$item/@xml:id}"
					role="dialog">
					<div
						class="modal-dialog modal-md">
						<div
							class="modal-content">
							<div
								class="modal-header">
								<button
									type="button"
									class="close"
									data-dismiss="modal">&#215;</button>
								<h1
									class="modal-title"><b>{$item/*[self::persName or self::placeName or self::span][not(@type)]}</b></h1>
							</div>
							<div
								class="modal-body">
								<p>{ syn3:lem2html($item) }</p>
							</div>
							<div
								class="modal-footer">
								<button
									type="button"
									class="btn btn-default"
									data-dismiss="modal"
								>Schließen</button>
							</div>
						</div>
					</div>
				</div>		
		else
			()
};


declare function syn3:viewLem($node as node(), $model as map(*)) {
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
		(syn3:getLem($vers1, $book1, $chap1),
		syn3:getLem($vers2, $book2, $chap2))
};

declare function syn3:lem2html($nodes as node()*) {
	(: transforms lems from syn3:viewLem() into html :)
	(: Input: TEI/XML lem from data/lemma
Output: HTML lem :)
	
	for $node in $nodes
	return
		typeswitch ($node)
			
			case text()
				return
					$node
					
					(: handles element persName :)
			case element(persName)
				return
					if ($node/@type) then
						<div
							class="lemAlternative">{syn3:lem2html($node/node())}</div>
					else
						()
						(: <h3 class="lemTitle">{ syn3:lem2html($node/node(),$side) }</h3>:)
						
						(: handles element placeName :)
			case element(placeName)
				return
					if ($node/@type) then
						<div
							class="lemAlternative">{syn3:lem2html($node/node())}</div>
					else
						()
						(:<h3 class="lemTitle">{ syn3:lem2html($node/node(),$side) }</h3>:)
						
						(: handles element span :)
			case element(span)
				return
					if ($node/@type) then
						<div
							class="lemAlternative">{syn3:lem2html($node/node())}</div>
					else
						()
						(:<h3 class="lemTitle">{ syn3:lem2html($node/node(),$side) }</h3>:)
						
						(: handles element note :)
			case element(note)
				return
					<div
						class="notes">{syn3:lem2html($node/node())}</div>
					
					(: handles element ref :)
			case element(ref)
				return
					<div
						class="lemLinks">
						<span><b>{string($node/@type)}:</b></span>
						<a
							class="lemma {$node/@type}"
							href="{$node/@source}">{string($node/@source)}</a>
					</div>
			
			case element()
				return
					syn3:lem2html($node/node())
			
			default
				return
					$node/string()
};
