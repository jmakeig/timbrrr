xquery version "1.0-ml";
declare namespace local="local";

declare function local:get-user-agent($raw as xs:string?) as element()* {
  if(empty($raw) or "" eq $raw) then () else
    let $url := concat("http://www.useragentstring.com/?uas=", xdmp:url-encode($raw), "&amp;getJSON=all")
    let $_ := xdmp:log(concat("Getting UA information from " , $url))
    let $m as map:map* := xdmp:from-json(xdmp:http-get($url)[2])
    for $k in map:keys($m)
      return (
        element {$k} { map:get($m, $k)},
        if("agent_version" = $k) then
          let $ver := map:get($m, $k)
          let $vers := tokenize($ver, "\.")
          return if(matches($ver, "^[0-9]+")) then (
            <agent_version_major>{$vers[1]}</agent_version_major>, 
            if($vers[2] castable as xs:unsignedInt) then <agent_version_minor>{$vers[2]}</agent_version_minor> else ()
          )
          else ()
        else ()
      )
};

let $map := 
  if(doc("/user-agents.map")) then map:map(doc("/user-agents.map")/*) else
  map:map()
let $_ := for $ua in distinct-values(collection("processed")//userAgent/@raw)
return 
  if(empty(map:get($map, $ua))) then
    map:put($map, $ua, local:get-user-agent($ua))
  else (
    xdmp:log(concat("Already have UA for ", $ua))
  )
return xdmp:document-insert("/user-agents.map", document {$map})
;
doc("/user-agents.map")
;
xdmp:save("/Users/jmakeig/Workspaces/timbrrr/load/user-agents.map.xml", doc("/user-agents.map"))

