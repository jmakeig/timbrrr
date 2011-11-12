xdmp:set-response-content-type("text/html"),
'<!DOCTYPE html>',
<html lang="en">
<head>
	<meta charset="utf-8" />
	<title>timbrrr</title>
	<link type="text/css" rel="stylesheet" href="/static/browser.css" />
	<script type="text/javascript" src="/static/jquery.js">//</script>
  <script type="text/javascript" src="/static/highcharts.js">//</script>
  <script type="text/javascript" src="/static/sparklines.js">//</script>
</head>
<body>
  <h1>Timbrrr</h1>
  <table id="UserAgents">{
    let $start := xs:dateTime(xs:date(min(cts:element-values(xs:QName("timestamp")))))
    let $end := xs:dateTime(xs:date(max(cts:element-values(xs:QName("timestamp")))))
    return
      for $agent in 
        cts:element-value-co-occurrences(
          xs:QName("agent_name"), xs:QName("agent_version_major"),
          ("collation-1=http://marklogic.com/collation/codepoint", "frequency-order", "limit=25"), 
          cts:and-query((
            (: Only the processed logs :)
            cts:collection-query("processed"),
            (: Filter internal IP addresses :)
            cts:not-query(cts:element-value-query(xs:QName("ip"), "216.243.*", ("wildcarded"))),
            (: Limit to a specific week :)
            cts:element-range-query(xs:QName("timestamp"), ">=", xs:dateTime($start)),
            cts:element-range-query(xs:QName("timestamp"), "<", xs:dateTime($end))
          ))
        )
        return <tr data-ua="{$agent/*[1]}" data-v="{$agent/*[2]}">
          <th>{string-join($agent/*/text(), " ")}</th>
          <td><div class="sparkline" id="sparkline{xdmp:random()}"></div></td>
          <td class="numeric">{format-number(cts:frequency($agent), "#,###")}</td>
        </tr>
  }</table>
</body>
</html>
