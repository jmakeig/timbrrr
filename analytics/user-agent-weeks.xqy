xquery version "1.0-ml";
import module namespace date="https://github.com/jmakeig/timbrrr" at "/date.xqy";
import module namespace tmbr="https://github.com/jmakeig/timbrrr" at "/aggregates.xqy";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

xdmp:set-response-content-type("application/json"),
xdmp:to-json(tmbr:agent-by-week(
  xdmp:get-request-field("ua"),
  xs:int(xdmp:get-request-field("v")), 
  tmbr:all-weeks(
    xs:dateTime(xs:date(xdmp:get-request-field("b"))),
    xs:dateTime(xs:date(xdmp:get-request-field("e")))
  )
))
