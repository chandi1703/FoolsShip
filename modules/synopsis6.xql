xquery version "3.1";
(: This file gets all marginalia in fools ship and displays them at the end of a chapter. Also handles links to lems and marginal notes. :)
(: Especially deals with ab[@type='marginalie'] :)

module namespace syn6 = "http://oc.narragonien-digital.de/syn6";
declare default element namespace "http://www.tei-c.org/ns/1.0";

import module namespace templates = "http://exist-db.org/xquery/templates";
import module namespace config = "http://exist-db.org/apps/narrenapp/config" at "config.xqm";

(: Save data-content in variables :)
(:declare variable $syn6:data := collection('/db/apps/narrenapp/data/GW');:)
(:declare variable $syn6:bel := collection('/db/apps/narrenapp/data/beleg');:)
(:declare variable $syn6:lem := collection('/db/apps/narrenapp/data/lemma');:)

declare function syn6:viewMarg($node as node(), $model as map(*), $side as xs:string) {
	(: gets all chosen values from user and calls function getMarg :)
	(: Input: $side (distinguishes between left and right synopsis-window)
Output: no direct output. Redirects to getMarg function :)

	let $book1 := request:get-parameter('book1', '')
	let $chap1 := request:get-parameter('chap1', '')
	let $book2 := request:get-parameter('book2', '')
	let $chap2 := request:get-parameter('chap2', '')
	return
		switch ($side)
			case "l"
				return
					syn6:getMarg($book1, $chap1, $side)
			case "r"
				return
					syn6:getMarg($book2, $chap2, $side)
			default return
				"It didn't work out"
};

declare function syn6:getMarg($book as xs:string, $chap as xs:string, $side as xs:string) {
	(: gets all elements ab[@type='marginalie'] from the current chapter :)
	(: Input: values chosen from user 
Output: left side --> marginalia
             right side --> data from lemma.xml and belege.xml :)
	
	let $document := doc(concat('/db/apps/narrenapp/data/GW/', string($book), '.xml'))
	
	let $chapnumber := replace($chap, 'GW[0-9]+n', '')
	let $chapter := $document//div[@type = 'chapter'][@n = $chapnumber]
	let $id := string($chapter/@xml:id)
	return
		(:horizontal line for seperating main text from footnote:)
		if ($chapter/ab[@type = 'marginalie'] != '') then
			(<hr
				class="margNote"/>,
			(: Counter is needed because double marginalia are possible :)
			for $marginalie at $pos in $chapter/ab[@type = "marginalie"]
			let $linenumber := $marginalie/preceding-sibling::ab[1]//reg//l[last()]/string(@n)
			return
				(<div
					class="row">
					
					<!-- left side all marginalia from chosen chapter -->
					<div
						class="col-sm-4">
						<span
							style="font-size:small"><a href="#{ concat($side, $linenumber) }t" id="{ concat($side, $linenumber) }f">{ $linenumber }</a></span>
						{
							for $line in $marginalie//reg//l
							return
								(: If marginal note is lemma as well call function buildLem :)
								if ($line/ref) then
									<div>{syn6:buildLem(string(replace($line/ref/@target, '.+.xml#(.+)$', '$1')), $line)}</div>
								else
									<div>{$line}</div>
						}
						<!-- Column End -->
					</div>
					
					<!-- right side all text from belege.xml, calls function buildBel -->
					{
						if ($marginalie//note != "") then
							<div
								class="col-sm-8">
								<a
									data-toggle="modal"
									data-target="#b{$pos}"
									class="clickBeleg"><i
										class="fas fa-caret-right"/> Belege</a>
								<div
									class="modal fade"
									id="b{$pos}"
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
													class="modal-title"><b>{
															for $line in $marginalie//reg//l
															return
																<span>{$line/text()}</span>
														}</b></h1>
											</div>
											<div
												class="modal-body">
												<p>
													{
														for $ref in $marginalie//note/ref
														let $id := string(replace($ref/@target, '.+.xml#(.+)$', '$1'))
														return
															if ($id != "") then
																<div>{syn6:buildBel($id)}</div>
															else
																()
													}
												</p>
											</div>
											<div
												class="modal-footer">
												<button
													type="button"
													class="btn btn-default"
													data-dismiss="modal"
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
						
						else
							()
					}
					<!-- Row End -->
				</div>,
				<hr/>)
			)
		else
			()
};

declare function syn6:buildLem($id as xs:string, $marg as xs:string) {
	(: deals with lemmata inside of ab[@type='marginalie'] :)
	(: Input: id as it is given in element ab[@type='marginalie'], marg as current text from element marginalie 
Output: link to lemma or plaintext, if there is content in lemma.xml for given id :)
	let $lem := collection('/db/apps/narrenapp/data/lemma/?select=*.xml')
	(: Check id's and get item from lemma.xml :)
	let $item := $lem//*[self::person or self::place or self::item][@xml:id = $id]
	return
		
		(: if item is not empty create popover link :)
		if ($item != '') then
			(: tabindex and data-trigger: Popover vanishes by clicking anywhere on the screen
        data-html allows to write html into attribute values
        data-placement: auto puts popup window where there is space. Default top
        data-content: data inside of popover window. Takes notes from lem file and creates link to modal window with id as data-target :)
			<a
				tabindex="0"
				data-trigger="focus"
				class="btn btn-info btn-sm leml"
				data-toggle="popover"
				data-content="{$item//note[not(descendant::note)]} &lt;a data-toggle='modal' data-target='#{$id}'&gt; ...mehr&lt;/a&gt;"
				data-placement="auto top"
				data-html="true">{$marg}</a>
			
			(: if empty just return plain text :)
		else
			<div>{$marg}</div>
};

declare function syn6:buildBel($id as xs:string) {
	(: deals with marginal notes inside of ab[@type='marginalie'] :)
	(: Input: id as it is given in element ab[@type='marginalie']
Output: collapse for marginal note text :)
	
	(: only take bibl elements which have a span child – span contains text. Ignore elements without text 
    also adding counter because double notes are possible :)
	let $bel := collection('/db/apps/narrenapp/data/beleg/?select=*.xml')
	for $item in $bel//bibl[child::span][@xml:id = $id]
	return
		(<div>{$item/span[@type = 'text']/text()}</div>,
		<br/>)
};
