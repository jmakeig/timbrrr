xquery version "1.0-ml";
import module namespace date="https://github.com/jmakeig/timbrrr" at "/date.xqy";
declare namespace tmbr="https://github.com/jmakeig/timbrrr"; 
declare option xdmp:mapping "false";

xdmp:set-response-content-type("text/html"),
'<!DOCTYPE html>',
let $b := xdmp:get-request-field("b")
let $e := xdmp:get-request-field("e")
let $ua := xdmp:get-request-field("ua")
let $v := "v" = xdmp:get-request-field("d")
let $min as xs:dateTime? := if(not(empty($b))) then xs:dateTime(xs:date($b)) else min(cts:element-values(xs:QName("timestamp")))
let $max as xs:dateTime? := if(not(empty($e))) then xs:dateTime(xs:date($e)) else max(cts:element-values(xs:QName("timestamp")))

let $suppress-internal := true()
return
<html lang="en">
<head>
	<meta charset="utf-8" />
	<title>server.marklogic.com User Agent Statistics</title>
	<link type="text/css" href="/static/vendor/ui-lightness/jquery-ui-1.8.16.custom.css" rel="stylesheet" />
	<link rel="stylesheet" href="/static/vendor/selectToUISlider.css" type="text/css" />
	<link type="text/css" rel="stylesheet" href="/static/browser.css" />
	<script type="text/javascript" src="/static/jquery.js">//</script>
	<script type="text/javascript" src="/static/vendor/jquery-ui-1.8.16.custom.min.js">//</script>
  <script type="text/javascript" src="/static/highcharts.js">//</script>
  <script type="text/javascript" src="/static/jquery.dataTables.js">//</script>
  <script type="text/javascript" src="/static/vendor/selectToUISlider.js">//</script>
  <script type="text/javascript" src="/static/stats.js">//</script>
  <script type="text/javascript" src="/static/sparklines.js">//</script>
</head>
<body>
  <header>
    <h1><a href="/">server.marklogic.com</a></h1>
    <!--<div class="stats">
      <div>From {format-dateTime($min, "[Y0001]-[M01]-[D01] [H01]:[m01]:[s01] [z]", "en", (), ())}</div>
      <div>to {format-dateTime($max, "[Y0001]-[M01]-[D01] [H01]:[m01]:[s01] [z]", "en", (), ())}</div>
      {if($suppress-internal) then <div>without internal addresses</div> else ()}
    </div>
    -->
  </header>
  <form method="get" action=".">
    <div id="DatePicker">{
      let $be := ($min, $max)
      return
      for $i at $j in ("b", "e") 
      return
      <select name="{$i}" id="{$i}">{
        for $w in tmbr:all-weeks()
        let $fw as xs:string := format-date(xs:date($w), '[Y0001]-[M01]-[D01]')
        return <option value="{$fw}">
        {if($be[$j] >= $w) then attribute selected {"selected"} else ()}
        {$fw}</option>
      }</select>
    }</div>
    {for $dim in xdmp:get-request-field("d") return <input type="hidden" name="d" value="{$dim}"/>}
    {if(exists($ua)) then <input type="hidden" name="ua" value="{$ua}"/> else ()}
  </form>
  <table id="UserAgents">
    <col style="width: 2em;"/>
    <col style="width: 12em;"/>
    <col style="width:120px;"/>
    <col style="width: 2em;"/>
    <col/>
    <thead>
      <tr>
        <th>#</th>
        <th class="title">User Agent</th>
        <th colspan="2">Trend</th>
        <th>Total</th>
      </tr>
    </thead>
    <tbody>
  {
    let $start := xs:dateTime(xs:date($min))
    let $end := xs:dateTime(xs:date($max))
    let $q := cts:and-query((
      (: Only the processed logs :)
      cts:collection-query("processed"),
      if($ua) then cts:element-range-query(xs:QName("agent_name"), "=", $ua, "collation=http://marklogic.com/collation/codepoint") else (),
      (: Filter internal IP addresses :)
      if($suppress-internal) then cts:not-query(cts:element-value-query(xs:QName("ip"), "216.243.*", ("wildcarded"))) else (),
      (: Limit to a specific range :)
      cts:element-range-query(xs:QName("timestamp"), ">=", xs:dateTime($start)),
      cts:element-range-query(xs:QName("timestamp"), "<", xs:dateTime($end))
    ))
    let $agents := 
      if(not($v)) then
        cts:element-values(
          xs:QName("agent_name"), (), ("collation=http://marklogic.com/collation/codepoint", "frequency-order", "limit=10"), $q
        )
      else
        cts:element-value-co-occurrences(
          xs:QName("agent_name"), xs:QName("agent_version_major"),
          ("collation-1=http://marklogic.com/collation/codepoint", "frequency-order", "limit=25"), 
          $q
        )
    let $max-freq := max(for $a in $agents return cts:frequency($a))
    return
      for $agent at $i in $agents        
        return 
        <tr>
          {attribute data-ua {if($v) then $agent/*[1] else $agent }}
          {if($v) then attribute data-v {$agent/*[2]} else () }
          <td class="numeric">{format-number($i, "#,###")}.</td>
          <td class="title"><span>
            {attribute data-ua {if($v) then $agent/*[1] else $agent }}
            {if($v) then attribute data-v {$agent/*[2]} else () }
            <a href="/?ua={if($v) then $agent/*[1] else $agent}&amp;d=v">{if($v) then string-join($agent/*/text(), " ") else $agent}</a></span></td>
          <td><div class="sparkline" id="sparkline{xdmp:random()}"></div></td>
          <td class="direction"><div></div></td>
          <td class="numeric"><span style="width: {xs:float(cts:frequency($agent) div $max-freq) * 100}%" class="bar">{format-number(cts:frequency($agent), "#,###")}</span></td>
        </tr>   
  }
    </tbody>
  </table>
  <footer>
    Powered by <a href="http://www.marklogic.com/products/overview.html">MarkLogic</a> and <a href="https://github.com/jmakeig/timbrrr">Timbrrr</a>.
  </footer>
</body>
</html>
