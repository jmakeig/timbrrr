xquery version "1.0-ml";
module namespace tmbr="https://github.com/jmakeig/timbrrr";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function tmbr:all-weeks() {
  tmbr:all-weeks((), ())
};
declare function tmbr:all-weeks($begin as xs:dateTime?, $end as xs:dateTime?) {
  let $min := if(not(empty($begin))) then $begin else xs:dateTime(xs:date(min(cts:element-values(xs:QName("timestamp")))))
  let $max := if(not(empty($end))) then $end else xs:dateTime(xs:date(max(cts:element-values(xs:QName("timestamp")))))
  let $total := ceiling(($max - $min) div xs:dayTimeDuration('P7D'))
  return 
    for $i in (0 to $total - 1) return $min + xs:dayTimeDuration(concat("P", $i * 7, "D"))
};
