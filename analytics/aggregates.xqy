xquery version "1.0-ml";
module namespace tmbr="https://github.com/jmakeig/timbrrr";
import module namespace date="https://github.com/jmakeig/timbrrr" at "/date.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function tmbr:agent-by-week($a as xs:string, $v as xs:int) {
  tmbr:agent-by-week($a, $v, ())
};
(: Returns a sequence of integer frequencies, one for each week in $ws :)
declare function tmbr:agent-by-week($a as xs:string, $v as xs:int?, $ws as xs:dateTime*) as xs:int* {
  (: Group by week, user agent. Aggregate by user agent frequency. :)
  let $weeks := if(empty($ws)) then tmbr:all-weeks() else $ws
  for $w at $i in $weeks 
    let $q := cts:and-query((
      (: Only the processed logs :)
      cts:collection-query("processed"),
      cts:element-range-query(xs:QName("agent_name"), "=", $a, "collation=http://marklogic.com/collation/codepoint"),
      (:cts:element-range-query(xs:QName("agent_version_major"), "=", $v),:)
      (: Limit to a specific week :)
      cts:element-range-query(xs:QName("timestamp"), ">=", $w),
      cts:element-range-query(xs:QName("timestamp"), "<", $w + xs:dayTimeDuration("P7D")),
      (: Filter internal IP addresses :)
      cts:not-query(cts:element-value-query(xs:QName("ip"), "216.243.*", ("wildcarded")))
    ))
    return sum( (: Sum converts empty sequences to zeros, which is what we want here :)
      cts:frequency(
        if(empty($v)) then
          cts:element-values(xs:QName("agent_name"), (), "collation=http://marklogic.com/collation/codepoint", $q)          
        else
          cts:element-value-co-occurrences(
            xs:QName("agent_name"), xs:QName("agent_version_major"),
            ("collation-1=http://marklogic.com/collation/codepoint", "frequency-order"),
            cts:and-query(($q, cts:element-range-query(xs:QName("agent_version_major"), "=", $v)))
          )
      )
    )
};
