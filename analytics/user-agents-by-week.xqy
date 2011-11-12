xquery version "1.0-ml";
(
xdmp:set-response-content-type("application/json"),
(: Group by week, user agent. Aggregate by user agent frequency. :)
let $min := xs:dateTime(xs:date(min(cts:element-values(xs:QName("timestamp")))))
let $max := xs:dateTime(xs:date(max(cts:element-values(xs:QName("timestamp")))))
let $total := ceiling(($max - $min) div xs:dayTimeDuration('P7D'))
let $weeks := for $i in (floor($total div 2) to $total - 2) return $min + xs:dayTimeDuration(concat("P", $i * 7, "D"))
let $result := for $w at $i in $weeks 
  return <week start="{xs:date($w)}">{
    for $agent in 
      cts:element-value-co-occurrences(
        xs:QName("agent_name"), xs:QName("agent_version_major"),
        ("collation-1=http://marklogic.com/collation/codepoint", "frequency-order"),
        cts:and-query((
          (: Only the processed logs :)
          cts:collection-query("processed"),
          (: Limit to a specific week :)
          cts:element-range-query(xs:QName("timestamp"), ">=", $w),
          cts:element-range-query(xs:QName("timestamp"), "<", $w + xs:dayTimeDuration("P7D")),
          (: Filter internal IP addresses :)
          cts:not-query(cts:element-value-query(xs:QName("ip"), "216.243.*", ("wildcarded")))
        ))
      )
      where cts:frequency($agent) gt 25
      return <agent count="{cts:frequency($agent)}">{string($agent)}</agent>
  }</week>
return (:$result:)
  xdmp:to-json(for $ag in distinct-values($result//agent)
    let $m := map:map()
    return (
      map:put($m, "name", $ag), 
      map:put($m, "data", for $wk in $result return if($wk/agent[. eq $ag]) then xs:int($wk/agent[. eq $ag]/@count) else 0), 
      $m
    )
  )
)
