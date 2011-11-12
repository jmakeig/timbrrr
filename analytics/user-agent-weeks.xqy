xquery version "1.0-ml";
declare namespace tmbr="https://github.com/jmakeig/timbrrr";

declare function tmbr:all-weeks() {
  let $min := xs:dateTime(xs:date(min(cts:element-values(xs:QName("timestamp")))))
  let $max := xs:dateTime(xs:date(max(cts:element-values(xs:QName("timestamp")))))
  let $total := ceiling(($max - $min) div xs:dayTimeDuration('P7D'))
  return 
    for $i in (0 to $total - 1) return $min + xs:dayTimeDuration(concat("P", $i * 7, "D"))
};
declare function tmbr:agent-by-week($a as xs:string, $v as xs:int) {
  tmbr:agent-by-week($a, $v, ())
};
declare function tmbr:agent-by-week($a as xs:string, $v as xs:int, $ws as xs:dateTime*) as xs:int* {
  (: Group by week, user agent. Aggregate by user agent frequency. :)
  let $weeks := if(empty($ws)) then tmbr:all-weeks() else $ws
  for $w at $i in $weeks 
    return sum( (: Sum converts empty sequences to zeros, which is what we want here :)
      cts:frequency(
        cts:element-value-co-occurrences(
          xs:QName("agent_name"), xs:QName("agent_version_major"),
          ("collation-1=http://marklogic.com/collation/codepoint", "frequency-order"),
          cts:and-query((
            (: Only the processed logs :)
            cts:collection-query("processed"),
            cts:element-range-query(xs:QName("agent_name"), "=", $a, "collation=http://marklogic.com/collation/codepoint"),
            cts:element-range-query(xs:QName("agent_version_major"), "=", $v),
            (: Limit to a specific week :)
            cts:element-range-query(xs:QName("timestamp"), ">=", $w),
            cts:element-range-query(xs:QName("timestamp"), "<", $w + xs:dayTimeDuration("P7D")),
            (: Filter internal IP addresses :)
            cts:not-query(cts:element-value-query(xs:QName("ip"), "216.243.*", ("wildcarded")))
          ))
        )
      )
    )
};
xdmp:set-response-content-type("application/json"),
xdmp:to-json(tmbr:agent-by-week(
  xdmp:get-request-field("ua"),
  xs:int(xdmp:get-request-field("v"))
))
