xquery version "1.0-ml";
if(exists(doc("/user-agents.map"))) then () else xdmp:document-insert("/user-agents.map", <a>map:map()</a>/*)
;
declare namespace s="http://www.w3.org/2009/xpath-functions/analyze-string";
declare namespace local="local";

declare variable $COLLECTION as xs:string := "/tickets/ticket/13903477104259455555";
declare variable $ua-map as map:map := map:map(doc("/user-agents.map")/*);

declare function local:get-user-agent($raw as xs:string?) as element()* {
  (:xdmp:log($raw),:)
  (:xdmp:log(xdmp:quote(map:get($ua-map, $raw))),:)
  map:get($ua-map, $raw)
(:
  let $m as map:map* := xdmp:from-json(xdmp:http-get(concat("http://www.useragentstring.com/?uas=", xdmp:url-encode($raw), "&amp;getJSON=all"))[2])
  for $k in map:keys($m)
    return element {$k} { map:get($m, $k)}
:)
};

declare function local:parse-dateTime($str) {
  if(empty($str) or $str eq "") then () 
  else 
  let $ts := tokenize($str, " ")
  let $dts := tokenize($ts[1], ":")
  let $dates := tokenize($dts[1], "/")
  let $months := ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
  return xs:dateTime(
    concat(
    (: date :)
    $dates[3], "-", if(index-of($months, $dates[2]) lt 10) then "0" else "", index-of($months, $dates[2]), "-", $dates[1],
    (: time :)
    "T",
    $dts[2], ":", $dts[3], ":", $dts[4]
    )
  )
};

(: From Functx :)
declare function local:day-of-week($date as xs:anyAtomicType?)  as xs:integer? {
  if(empty($date))
  then ()
  else xs:integer((xs:date($date) - xs:date('1901-01-06')) div xs:dayTimeDuration('P1D')) mod 7
};

for $d in (collection($COLLECTION))[201 to 500]
return
  let $ls := tokenize($d, "\n")
  let $re := '^([\d.]+) (\S+) (\S+) \[([\w:/]+\s[+\-]\d{4})\] "(.+?)" (\d{3}) ([\-\d]+) "([^"]+)" "([^"]+)"$'
  for $l as xs:string at $i in $ls
    let $as := analyze-string($l, $re)

    let $timestamp := local:parse-dateTime($as//s:group[@nr eq 4]/string(.))
    let $request := $as//s:group[@nr eq 5]/string(.)
    where string-length($l) gt 0
    return (
      xdmp:document-insert(concat(xdmp:node-uri($d), "/", encode-for-uri($as//s:group[@nr eq 4]/string(.)), "/", xdmp:hash64(concat($l, $i))), 
        <log id="{xdmp:hash64(concat($l, $i))}">
          <ip>{$as//s:group[@nr eq 1]/string(.)}</ip>
          <timestamp raw="{$as//s:group[@nr eq 4]/string(.)}" day-of-week="{local:day-of-week($timestamp)}">{$timestamp}</timestamp>
          <request raw="{$request}">
            <method>{tokenize($request, " ")[1]}</method>
            <url>{tokenize($request, " ")[2]}</url>
            <protocol>{tokenize($request, " ")[3]}</protocol>
          </request>
          <responseCode>{$as//s:group[@nr eq 6]/string(.)}</responseCode>
          <referrer>{$as//s:group[@nr eq 8]/string(.)}</referrer>
          <userAgent raw="{$as//s:group[@nr eq 9]/string(.)}">
            {local:get-user-agent($as//s:group[@nr eq 9]/string(.))}
          </userAgent>
        </log>, (xdmp:default-permissions()), ("processed")
      )
    )
(:
;
declare namespace local="local";

declare function local:get-user-agent($raw as xs:string?) as element()* {
  if(empty($raw) or "" eq $raw) then () else
    let $url := concat("http://www.useragentstring.com/?uas=", xdmp:url-encode($raw), "&amp;getJSON=all")
    let $_ := xdmp:log(concat("Getting UA information from " , $url))
    let $m as map:map* := xdmp:from-json(xdmp:http-get($url)[2])
    for $k in map:keys($m)
      return element {$k} { map:get($m, $k)}
};

let $map := map:map(doc("/user-agents.map")/*)
let $_ := for $ua in distinct-values(collection("processed")//userAgent/@raw)
return 
  if(empty(map:get($map, $ua))) then
    map:put($map, $ua, local:get-user-agent($ua))
  else (
    xdmp:log(concat("Already have UA for ", $ua))
  )
return xdmp:document-insert("/user-agents.map", document {$map})
;
count(doc("/user-agents.map")//map:entry),
count(distinct-values(collection("processed")//userAgent/@raw)),
xdmp:save("/Users/jmakeig/tmp/user-agents.map.xml", doc("/user-agents.map"))
:)
