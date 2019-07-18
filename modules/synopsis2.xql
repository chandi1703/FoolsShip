xquery version "3.1";
(: This file handles the transformation of fool's ship xml files :)

module namespace syn2 = "http://oc.narragonien-digital.de/syn2";
declare default element namespace "http://www.tei-c.org/ns/1.0";

import module namespace templates = "http://exist-db.org/xquery/templates";
import module namespace config = "http://exist-db.org/apps/narrenapp/config" at "config.xqm";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace functx = "http://www.functx.com";

declare function syn2:createTabItem($side as xs:string, $vers as xs:string, $title as xs:string){
	<li class="nav-item">
		<a
			class="nav-link"
			id="{ concat($vers, upper-case($side)) }-tab"
			data-toggle="tab"
			href="#{ concat($vers, upper-case($side)) }"
			role="tab"
			aria-controls="{ concat($vers, upper-case($side)) }"
			aria-selected="true">{ $title }</a>
	</li>
};

declare function syn2:createTabContent($side as xs:string, $vers as xs:string, $book as xs:string, $chap as xs:string){
	if ($vers eq 'reg') then
		<div
			class="tab-pane fade in active"
			id="{ concat($vers, upper-case($side)) }"
			role="tabpanel"
			aria-labelledby="{ concat($vers, upper-case($side)) }-tab">{ syn2:getFoolsShip($side, $vers, $book, $chap) }</div>
	else if ($vers eq 'facs') then
		<div
			class="tab-pane fade"
			id="{ concat($vers, upper-case($side)) }"
			role="tabpanel"
			aria-labelledby="{ concat($vers, upper-case($side)) }-tab">{ syn2:getFacsimile($side, $book, $chap) }</div>
	else
		<div
			class="tab-pane fade"
			id="{ concat($vers, upper-case($side)) }"
			role="tabpanel"
			aria-labelledby="{ concat($vers, upper-case($side)) }-tab">{ syn2:getFoolsShip($side, $vers, $book, $chap) }</div>
};

declare function syn2:viewFoolsShip($node as node(), $model as map(*), $side as xs:string) {
	(: takes necessary content from data/GW and passes it to syn2:tei2html :)
	(: Input: data/GW, user's choice from menu, $side (left or right of synopsis)
Output: chapter which was chosen by the user :)
	
	(: takes parameters from html-form :)
(:	let $vers1 := request:get-parameter('vers1', '') :)
	let $book1 := request:get-parameter('book1', '')
	let $chap1 := request:get-parameter('chap1', '')
	(:let $vers2 := request:get-parameter('vers2', ''):)
	let $book2 := request:get-parameter('book2', '')
	let $chap2 := request:get-parameter('chap2', '')
	
	let $facs := 'facs',
		$reg := 'reg',
		$orig := 'orig'
	
	return	
	if ($side eq 'l') then
		(<ul
		class="nav nav-tabs"
		id="myTabL"
		role="tablist">
		{ syn2:createTabItem($side, $reg, 'Normalisierte Lesefassung'),
		syn2:createTabItem($side, $orig, 'Transkription'),
		syn2:createTabItem($side, $facs, 'Faksimile') }
		</ul>,
		<div
			class="tab-content"
			id="myTabContent">
			{ syn2:createTabContent($side, $reg, $book1, $chap1),
			syn2:createTabContent($side, $orig, $book1, $chap1),
			syn2:createTabContent($side, $facs, $book1, $chap1) }
		</div>)
	else 
		(<ul
		class="nav nav-tabs"
		id="myTabL"
		role="tablist">
		{ syn2:createTabItem($side, $reg, 'Normalisierte Lesefassung'),
		syn2:createTabItem($side, $orig, 'Transkription'),
		syn2:createTabItem($side, $facs, 'Faksimile') }
		</ul>,
		<div
			class="tab-content"
			id="myTabContent">
			{ syn2:createTabContent($side, $reg, $book2, $chap2),
			syn2:createTabContent($side, $orig, $book2, $chap2),
			syn2:createTabContent($side, $facs, $book2, $chap2) }
		</div>)
};

declare function syn2:getFoolsShip($side as xs:string, $vers as xs:string, $book as xs:string, $chap as xs:string) {
	(: gets chapters from fool's ship according to user's choice and passes it to syn2:viewFoolsShip() :)
	(: Input: $side (synopsis side), $vers (version), $book (GW), $chap (chapter)
Output: user's chosen chapter :)
	let $document := doc(concat('/db/apps/narrenapp/data/GW/', string($book), '.xml'))
	
	let $chapnumber := replace($chap, 'GW[0-9]+n', '')
	let $chapter := $document//div[@type = 'chapter'][@n = $chapnumber]
	let $id := string($chapter/@xml:id)
	
	return
		<div
			id="{concat($book, $id, $vers)}"
			class="chapterL">{ syn2:tei2html($chapter, $side, $vers) }</div>
};

declare function syn2:getFacsimile($side as xs:string, $book as xs:string, $chap as xs:string) {
	let $document := doc(concat('/db/apps/narrenapp/data/GW/', string($book), '.xml'))
	return
		
		let $chapnumber := replace($chap, 'GW[0-9]+n', '')
		let $chapter := $document//div[@type = 'chapter'][@n = $chapnumber]
		
		return
			<div
				class="myPictures{upper-case($side)}">
				{
					((for $block in distinct-values($chapter//ab/string(@corresp))
					return
						<div
							class="first-image">
							<img
								src="/exist/rest/img/facs/{lower-case($book)}/{string(replace($block, '#', ''))}.jpg"
								id="zoom_01_{$side}"
								onmouseenter="zoomFacs{upper-case($side)}()"/>
						</div>
					)[1],
					<div
						id="gallery_01_{$side}">
						{
							for $block at $pos in distinct-values($chapter//ab/string(@corresp))
							return
								<a
									href="#"
									data-image="/exist/rest/img/facs/{lower-case($book)}/{string(replace($block, '#', ''))}.jpg">
									<img
										id="img_{$pos}"
										src="/exist/rest/img/facs/{lower-case($book)}/thumbnails/{string(replace($block, '#', ''))}.jpg"/>
								</a>
						}
					</div>)
				}
			</div>
};



declare function syn2:tei2html($nodes as node()*, $side as xs:string, $vers as xs:string) {
	(: transforms elements from syn2:viewFoolsShip() :)
	
	let $lem := collection('/db/apps/narrenapp/data/lemma/?select=*.xml')
	(: reads parameters from synopsis.html :)
	let $vers1 := request:get-parameter('vers1', '')
	let $vers2 := request:get-parameter('vers2', '')
	let $book1 := request:get-parameter('book1', '')
	let $book2 := request:get-parameter('book2', '')
	
	for $node in $nodes
	return
		typeswitch ($node)
			
			case text()
				return
					$node
			
			case element(ab)
				return
					
					if ($node/@type = "chapterTitle") then
						<div
							class="chapterTitle"
							style="font-weight:bold;font-size:1.5em;margin-bottom:3%">{syn2:tei2html($node/node(), $side, $vers)}</div>
					
					else
						if ($node/@type = "mainText") then
							<div
								class="mainText">{syn2:tei2html($node/node(), $side, $vers)}</div>
						
						else
							if ($node/@type = "motto") then
								<div
									class="motto"
									style="font-size:small;margin-bottom:4%">{syn2:tei2html($node/node(), $side, $vers)}</div>
							
							else
								if ($node/@type = "signatureTitle") then
									(: (<div class="signatureMark">{ syn2:tei2html($node/node(),$side) }</div>,
                    <hr class="pageturn"/>):)
									<div
										class="signatureMark">{syn2:tei2html($node/node(), $side,$vers)}</div>
								
								else
									if ($node/@type = "folio") then
										<div
											class="folio">{syn2:tei2html($node/node(), $side, $vers)}</div>
										
										(: Marginalien werden an anderer Stelle aufgerufen und verarbeitet, daher auslassen :)
									else
										if ($node/@type = "marginalie") then
											()
										else
											if ($node/@type = "woodcutTitle") then
												()
											
											else
												syn2:tei2html($node/node(), $side, $vers)
			
			case element(choice)
				return
					if ($node/reg | $node/orig) then
						switch ($vers)
							case "reg"
								return
									<div
										class='nrm'>{
											for $child in $node//reg
											return
												syn2:tei2html($child, $side, $vers)
										}</div>
							case "orig"
								return
									<div
										class='ocr'>{
											for $child in $node//orig
											return
												syn2:tei2html($child, $side, $vers)
										}</div>
							default return
								()
					
				else
					syn2:tei2html($node/node(), $side, $vers)

case element(corr)
	return
	switch($side)
		case "l" return
			(<span
				class="corr"><a
					href="#{$node/ancestor::div/@xml:id}_F{$node/position()}"
					data-toggle="collapse">{syn2:tei2html($node/node(), $side, $vers)}</a></span>,
			<div id="{$node/ancestor::div/@xml:id}_F{$node/position()}" class="collapse" style="background:lightgrey;line-height:2em;">
				<div style="text-align:center"><b>{$node, ' '}</b><i>{replace($node/@resp, '#', '')}</i> ] <b>{$node/preceding-sibling::sic, ' '}</b><i>{$book1}</i></div>
			</div>)
		case "r" return
			(<span
					class="corr"><a
						href="#{$node/ancestor::div/@xml:id}_F{$node/position()}"
						data-toggle="collapse">{syn2:tei2html($node/node(), $side, $vers)}</a></span>,
				<div id="{$node/ancestor::div/@xml:id}_F{$node/position()}" class="collapse" style="background:lightgrey;line-height:2.5em;">
					<div style="text-align:center"><b>{$node, ' '}</b><i>{replace($node/@resp, '#', '')}</i> ] <b>{$node/preceding-sibling::sic, ' '}</b><i>{$book2}</i></div>
				</div>)
		default return ()
				
case element(sic)
	return ()

case element(pb)
	return
		if ($node/preceding-sibling::ab != '') then
			
			(<div
				class="lage">{replace($node/@facs, '.*_([a-z][1-9][a-z])', '$1')}</div>,
			<hr
				class="pageturn"/>)
		else
			<div
				class="lage">{replace($node/@facs, '.*_([a-z][1-9][a-z])', '$1')}</div>
			
			(: pictures are not in narrenapp itself but inside of a directory on database level :)
case element(figure)
	return
		let $login := xmldb:login('/db/img/woodcut', 'guest', '')
		return
			<div
				class="row">
				
				{
					if ($node/parent::ab[@type = 'woodcut']/following-sibling::ab[@type = "woodcutTitle"][1]) then
						let $woodcutTitle := $node/parent::ab[@type = 'woodcut']/following-sibling::ab[@type = "woodcutTitle"]/choice
						return
							(<div
								class="col-sm-7 myWoodcut{upper-case($side)}">
								<img
									src="/exist/rest/img/woodcut/{lower-case(replace(base-uri($node), '.+/(.+).xml$', '$1'))}/thumbnail/{concat($node/@facs, '.jpg')}"
									data-zoom-image="/exist/rest/img/woodcut/{lower-case(replace(base-uri($node), '.+/(.+).xml$', '$1'))}/{concat($node/@facs, '.jpg')}"
									style="height:350px;margin-bottom:4%"
									id="woodcut-zoom-{ concat($side, $vers) }"
									onmouseenter="zoomWood{ concat(upper-case($side), $vers) }()"></img></div>,
							<div
								class="col-sm-5"
								style="font-size:small">{syn2:tei2html($woodcutTitle, $side, $vers)}</div>)
					else
						<div
							class="col-sm-8 col-sm-push-2 myWoodcut{upper-case($side)}">
							<img
								src="/exist/rest/img/woodcut/{lower-case(replace(base-uri($node), '.+/(.+).xml$', '$1'))}/thumbnail/{concat($node/@facs, '.jpg')}"
								data-zoom-image="/exist/rest/img/woodcut/{lower-case(replace(base-uri($node), '.+/(.+).xml$', '$1'))}/{concat($node/@facs, '.jpg')}"
								style="height:350px;margin-bottom:4%"
								id="woodcut-zoom-{ concat($side, $vers) }"
								onmouseenter="zoomWood{ concat(upper-case($side), $vers) }()"></img></div>
				}
			</div>

case element(l)
	return
		<div
			class="row">
			{
				if ($node/following-sibling::l != '') then
					
					(<div
						id="line"
						class="col-sm-2">{string($node/@n)}</div>,
					<div
						id="text"
						class="col-sm-10">{syn2:tei2html($node/node(), $side, $vers)}</div>)
				
				else
					if ($node/ancestor::ab[1]/following-sibling::ab[1][@type = 'marginalie']) then
						(<div
							id="line"
							class="col-sm-2"><a
								href="#{concat($side, $node/@n)}f"
								id="{concat($side, $node/@n)}t">{string($node/@n)}<sup><i
										class="fas fa-info-circle"
										style="font-size:10px"/></sup></a></div>,
						<div
							id="text"
							class="col-sm-10">{syn2:tei2html($node/node(), $side, $vers)}</div>)
					
					else
						(<div
							id="line"
							class="col-sm-2">{string($node/@n)}</div>,
						<div
							id="text"
							class="col-sm-10">{syn2:tei2html($node/node(), $side, $vers)}</div>)
			}
		
		</div>
		
		(: handling of lems, see also synopsis3.xql :)
case element(ref)
	return
		(: let $chapter := $node/ancestor::div/@xml:id:)
		
		let $uri := util:unescape-uri(replace(base-uri($node), '.+/(.+).xml$', '$1'), 'UTF-8')
		(:Wähle Personen, Orte und Anderes:)
		for $item in $lem//*[self::person or self::place or self::item]
		(: Wähle nur die unterste Ebene der Notes :)
		for $note in $item//note[not(descendant::note)]
		let $content := $note
			where $item/@xml:id eq replace($node/@target, '.+.xml#(.+)$', '$1')
		return
			<a
				tabindex="0"
				data-trigger="focus"
				class="btn btn-default btn-sm lem{$side}"
				data-toggle="popover"
				data-content="{$content} &lt;a data-toggle='modal' data-target='#{replace($node/@target, '.+.xml#(.+)$', '$1')}'&gt; ...mehr&lt;/a&gt;"
				data-placement="auto top"
				data-html="true">{$node/node()}</a>

case element()
	return
		syn2:tei2html($node/node(), $side, $vers)

default
	return
		$node/string()
};
