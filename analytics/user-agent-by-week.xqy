xquery version "1.0-ml";
(: Group by week, user agent. Aggregate by user agent frequency. :)
let $min := xs:dateTime(xs:date(min(cts:element-values(xs:QName("timestamp")))))
let $max := xs:dateTime(xs:date(max(cts:element-values(xs:QName("timestamp")))))
let $total := ceiling(($max - $min) div xs:dayTimeDuration('P7D'))
let $weeks := for $i in (0 to $total - 1) return $min + xs:dayTimeDuration(concat("P", $i * 7, "D"))
for $w at $i in $weeks 
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
