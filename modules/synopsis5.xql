xquery version "3.1";
(: This file creates clickable arrows for turning pages for two narrenschiff at once :)

module namespace syn5 = "http://oc.narragonien-digital.de/syn5";
(: synopsis4.xql imports button-creation :)
import module namespace syn4 = "http://oc.narragonien-digital.de/syn4" at "synopsis4.xql";
declare default element namespace "http://www.tei-c.org/ns/1.0";

import module namespace templates = "http://exist-db.org/xquery/templates";
import module namespace config = "http://exist-db.org/apps/narrenapp/config" at "config.xqm";
import module namespace functx = "http://www.functx.com";

declare function syn5:create-link-tall($node as node(), $model as map(*), $direction as xs:string, $side as xs:string) {
(: creates links for turning pages in both foolship windows at once :)
(: Input: direction (turning page to the left or the right, next-previous), side ( left:l or right:r window) 
Output: clickable links. Calls function syn4:create-button() to create fontawesome buttons :)
    
    let $book1 := request:get-parameter('book1', ''),
        $book2 := request:get-parameter('book2', ''),
        $chap1 := request:get-parameter('chap1', ''),
        $chap2 := request:get-parameter('chap2', ''),
        $uri := request:get-uri(),
        (: gets continous number of chapter id for counting :)
        (: functx imported :)
        $chap-number1 := number(functx:substring-after-match($chap1, 'GW[0-9]+n')),
        $chap-number2 := number(functx:substring-after-match($chap2, 'GW[0-9]+n'))
    
    return
        (: handles left window first. :)
        switch ($side)
            case ("l")
                return
                    (: link changes according to direction. Counting down for "previous" :)
                    switch ($direction)
                        case "previous"
                            return
                                if ($book2 eq "") then
                                    <a
                                        href="{$uri}?book1={$book1}&amp;chap1={concat(replace($chap1, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number1 - 1))}">
                                        {syn4:create-button($node, $model, $direction)}
                                    </a>
                                else
                                    <a
                                        href="{$uri}?book1={$book1}&amp;chap1={concat(replace($chap1, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number1 - 1))}&amp;book2={$book2}&amp;chap2={concat(replace($chap2, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number2 - 1))}">
                                        {syn4:create-button($node, $model, $direction)}
                                    </a>
                                    (: link changes according to direction. Counting up for "next" :)
                        case "next"
                            return
                                if ($book2 eq "") then
                                    <a
                                        href="{$uri}?book1={$book1}&amp;chap1={concat(replace($chap1, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number1 + 1))}">
                                        {syn4:create-button($node, $model, $direction)}
                                    </a>
                                else
                                    <a
                                        href="{$uri}?book1={$book1}&amp;chap1={concat(replace($chap1, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number1 + 1))}&amp;book2={$book2}&amp;chap2={concat(replace($chap2, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number2 + 1))}">
                                        {syn4:create-button($node, $model, $direction)}
                                    </a>
                        default return
                            "Did not work"
        (: handles right window second. :)
        case ("r")
            return
                (: link changes according to direction. Counting down for "previous" :)
                switch ($direction)
                    case "previous"
                        return
                            if ($book1 eq "") then
                                <a
                                    href="{$uri}?book2={$book2}&amp;chap2={concat(replace($chap2, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number2 - 1))}">
                                    {syn4:create-button($node, $model, $direction)}
                                </a>
                            else
                                <a
                                    href="{$uri}?book1={$book1}&amp;chap1={concat(replace($chap1, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number1 - 1))}&amp;book2={$book2}&amp;chap2={concat(replace($chap2, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number2 - 1))}&amp;">
                                    {syn4:create-button($node, $model, $direction)}
                                </a>
                                (: link changes according to direction. Counting up for "next" :)
                    case "next"
                        return
                            if ($book1 eq "") then
                                <a
                                    href="{$uri}?book2={$book2}&amp;chap2={concat(replace($chap2, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number2 + 1))}&amp;">
                                    {syn4:create-button($node, $model, $direction)}
                                </a>
                            else
                                <a
                                    href="{$uri}?book1={$book1}&amp;chap1={concat(replace($chap1, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number1 + 1))}&amp;book2={$book2}&amp;chap2={concat(replace($chap2, '(GW[0-9]+n)[0-9]+$', '$1'), string($chap-number2 + 1))}">
                                    {syn4:create-button($node, $model, $direction)}
                                </a>
                    default return
                        "Did not work"
    default return
        "urgh"
};
