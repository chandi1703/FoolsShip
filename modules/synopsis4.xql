xquery version "3.1";
(: This file creates clickable arrows for turning pages inside of narrenschiff :)

module namespace syn4 = "http://oc.narragonien-digital.de/syn4";
declare default element namespace "http://www.tei-c.org/ns/1.0";

import module namespace templates = "http://exist-db.org/xquery/templates";
import module namespace config = "http://exist-db.org/apps/narrenapp/config" at "config.xqm";
import module namespace functx = "http://www.functx.com";

declare function syn4:create-button($node as node(), $model as map(*), $direction as xs:string) {
    (: Creates font-awesome arrows for clicking to left or to right :)
    (: Input: direction, clicking left or right
Output: fontawesome buttons :)
    
    switch ($direction)
        case ("previous")
            return
                <button
                    type="button"
                    class="btn btn-default btn-sm" aria-label="left">
                    <i class="fas fa-caret-left"></i> 
                </button>
        case ("next")
            return
                <button
                    type="button"
                    class="btn btn-default btn-sm">
                    <i class="fas fa-caret-right"></i>
                </button>
        default return
            "did not work"
};

declare function syn4:create-link($node as node(), $model as map(*), $direction as xs:string, $side as xs:string) {
    (: creates links according to window and direction of click. If left window is used, right window doesn't move and the other way round :)
    (: Input: direction (turning page to the left or the right, next-previous), side ( left:l or right:r window) 
Output: clickable links. Calls function syn4:create-button() to create fontawesome buttons :)
    
    let $vers1 := request:get-parameter('vers1', ''),
        $vers2 := request:get-parameter('vers2', ''),
        $book1 := request:get-parameter('book1', ''),
        $book2 := request:get-parameter('book2', ''),
        $chap1 := request:get-parameter('chap1', ''),
        $chap2 := request:get-parameter('chap2', ''),
        $uri := request:get-uri(),
        (: gets continous number of chapter id for counting :)
        (: functx imported :)
        $chap-number1 := number(functx:substring-after-match($chap1, 'GW[0-9]+n')),
        $chap-number2 := number(functx:substring-after-match($chap2, 'GW[0-9]+n'))
    
    return
        (: handles left window first. If user turns pages on the left, right window freezes :)
        switch ($side)
            case ("l")
                return
                    (: link changes according to direction. Counting down for "previous" :)
                    switch ($direction)
                        case "previous"
                            return
                                if ($book2 eq "") then
                                    <a
                                        href="{$uri}?book1={$book1}&amp;chap1={concat(replace($chap1, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number1 - 1))}&amp;vers1={$vers1}">
                                        {syn4:create-button($node, $model, $direction)}
                                    </a>
                                else
                                    <a
                                        href="{$uri}?book1={$book1}&amp;chap1={concat(replace($chap1, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number1 - 1))}&amp;vers1={$vers1}&amp;book2={$book2}&amp;chap2={$chap2}&amp;vers2={$vers2}">
                                        {syn4:create-button($node, $model, $direction)}
                                    </a>
                                    (: link changes according to direction. Counting up for "next" :)
                        case "next"
                            return
                                if ($book2 eq "") then
                                    <a
                                        href="{$uri}?book1={$book1}&amp;chap1={concat(replace($chap1, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number1 + 1))}&amp;vers1={$vers1}">
                                        {syn4:create-button($node, $model, $direction)}
                                    </a>
                                else
                                    <a
                                        href="{$uri}?book1={$book1}&amp;chap1={concat(replace($chap1, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number1 + 1))}&amp;vers1={$vers1}&amp;book2={$book2}&amp;chap2={$chap2}&amp;vers2={$vers2}">
                                        {syn4:create-button($node, $model, $direction)}
                                    </a>
                        default return
                            "Did not work"
                            (: handles right window second. If user turns pages on the right, left window freezes :)
        case ("r")
            return
                (: link changes according to direction. Counting down for "previous" :)
                switch ($direction)
                    case "previous"
                        return
                            if ($book1 eq "") then
                                <a
                                    href="{$uri}?book2={$book2}&amp;chap2={concat(replace($chap2, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number2 - 1))}&amp;vers2={$vers2}">
                                    {syn4:create-button($node, $model, $direction)}
                                </a>
                            else
                                <a
                                    href="{$uri}?book1={$book1}&amp;chap1={$chap1}&amp;vers1={$vers1}&amp;book2={$book2}&amp;chap2={concat(replace($chap2, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number2 - 1))}&amp;vers2={$vers2}">
                                    {syn4:create-button($node, $model, $direction)}
                                </a>
                                (: link changes according to direction. Counting up for "next" :)
                    case "next"
                        return
                            if ($book1 eq "") then
                                <a
                                    href="{$uri}?book2={$book2}&amp;chap2={concat(replace($chap2, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number2 + 1))}&amp;vers2={$vers2}">
                                    {syn4:create-button($node, $model, $direction)}
                                </a>
                            else
                                <a
                                    href="{$uri}?book1={$book1}&amp;chap1={$chap1}&amp;vers1={$vers1}&amp;book2={$book2}&amp;chap2={concat(replace($chap2, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number2 + 1))}&amp;vers2={$vers2}">
                                    {syn4:create-button($node, $model, $direction)}
                                </a>
                    default return
                        "Did not work"
    default return
        "urgh"
};
