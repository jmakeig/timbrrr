xquery version "1.0-ml";
declare namespace local="local";
let $uas := map:map(doc("/user-agents.map")/element())
let $_ := for $k in map:keys($uas)
  let $value := map:get($uas, $k)[self::* except (self::agent_version_major, self::agent_version_minor) ]
  let $ver := data($value[self::agent_version])
  let $vers := tokenize($ver, "\.")
  return 
    map:put($uas, $k, 
      ($value, 
      if(matches($ver, "^[0-9]+")) then 
        (<agent_version_major>{$vers[1]}</agent_version_major>, if($vers[2] castable as xs:unsignedInt) then <agent_version_minor>{$vers[2]}</agent_version_minor> else ())
      else ())
    )
return xdmp:document-insert("/user-agents.map", document { $uas })
;
doc("/user-agents.map")
