xquery version "1.0-ml";
declare default collation "http://marklogic.com/collation/codepoint";
for $co in 
  cts:element-value-co-occurrences(
    xs:QName("agent_name"), xs:QName("agent_version_major"),
    ("frequency-order"),
    cts:collection-query("processed")
  )
return <agent frequency="{cts:frequency($co)}">{concat($co/cts:value[1], " (", $co/cts:value[2], ")")}</agent>
