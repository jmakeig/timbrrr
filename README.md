An Apache log parser for MarkLogic Server. This is by no means a generic way to work with logs. I just needed to scratch an itch.

A log document will end up looking something like

```xml
<log id="16191458111230932830">
  <ip>111.222.33.4</ip>
  <timestamp raw="22/Sep/2011:17:26:59 -0700" day-of-week="4">2011-09-22T17:26:59</timestamp>
  <request raw="GET /redirector/?version=5.0-20110922&amp;license=development&amp;link=0001&amp;update=explore_content HTTP/1.1">
    <method>GET</method>
    <url>/redirector/?version=5.0-20110922&amp;license=development&amp;link=0001&amp;update=explore_content</url>
    <protocol>HTTP/1.1</protocol>
  </request>
  <responseCode>302</responseCode>
  <referrer>http://localhost:8000/</referrer>
  <userAgent raw="Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.16) Gecko/20110319 Firefox/3.6.16">
    <os_type>Windows</os_type>
    <agent_type>Browser</agent_type>
    <agent_version>3.6.16</agent_version>
    <agent_language>English - United States</agent_language>
    <agent_name>Firefox</agent_name>
    <os_name>Windows 7</os_name>
    <os_versionNumber/>
    <os_producerURL/>
    <agent_languageTag>en-US</agent_languageTag>
    <os_versionName/>
    <linux_distibution>Null</linux_distibution>
    <os_producer/>
  </userAgent>
</log>
```
Uses [User Agent String.com](http://www.useragentstring.com/) to parse user-agents.
