# Timbrrr
Timbrrr is a user agent analysis tool that operates on Apache logs. It includes a log parser as well as a front-end web UI for visualizing user agent trends using MarkLogic Server. 

*This is by no means a generic or robust way to work with logs. I just needed to scratch an itch.*

## Usage
The `config` directory includes a database configuration package to set the appropriate index settings. You can import this into a MarkLogic 5 instance to create or update a database.

The `load` directory includes scripts for parsing log entries as well as seeding master data about the universe of user agent strings (using [User Agent String.com](http://www.useragentstring.com/)). I’ve used Information Studion in MarkLogic to load the raw access log files into a collection called `raw`.

After loading and processing, a log document will end up looking something like

```xml
<?xml version="1.0" encoding="UTF-8"?>
<log id="16792903662867185711">
  <ip>111.222.333.444</ip>
  <timestamp raw="01/Jan/2011:00:00:00 -0700" day-of-week="2">2011-01-01T00:00:00</timestamp>
  <request raw="GET /path/?foo=bar HTTP/1.1">
    <method>GET</method>
    <url>/path/?foo=bar</url>
    <protocol>HTTP/1.1</protocol>
  </request>
  <responseCode>302</responseCode>
  <referrer>http://hostname:8000/</referrer>
  <userAgent raw="Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)">
    <os_type>Windows</os_type>
    <agent_type>Browser</agent_type>
    <agent_version>9.0</agent_version>
    <agent_language/>
    <agent_name>Internet Explorer</agent_name>
    <os_name>Windows 7</os_name>
    <os_versionNumber/>
    <os_producerURL/>
    <agent_languageTag/>
    <os_versionName/>
    <linux_distibution>Null</linux_distibution>
    <os_producer/>
    <agent_version_major>9</agent_version_major>
    <agent_version_minor>0</agent_version_minor>
  </userAgent>
</log>
```

The  `analytics` directory includes a UI and some web services to render a visualization of requests by user agent over time. You should set the root of a MarkLogic app server to point to this directory and the context database to be the one you created in the configuration step above.


## License
Copyright 2011 Justin Makeig <<https://github.com/jmakeig>>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

### Third-Party Software
jQuery (v1.7) is copyright the [jQuery Project](http://jquery.org) and included under the terms of the [MIT license](https://github.com/jquery/jquery/blob/master/MIT-LICENSE.txt).

jQuery UI (v1.8.16) is copyright the [jQuery Project](http://jquery.org) and included under the terms of the [MIT license](https://github.com/jquery/jquery/blob/master/MIT-LICENSE.txt).


DataTables (v1.8.2) is copyright Allan Jardine and is included under the terms of the [BSD license](http://www.datatables.net/license_bsd).

HighCharts (v2.1.8) is copyright [Highsoft Solutions AS](http://highsoft.com) and is included under the terms of the [Creative Commons Attribution-NonCommercial 3.0 License](http://creativecommons.org/licenses/by-nc/3.0/).

selectToUISlider (v2) is copyright [Scott Jehl](mailto:scott@filamentgroup.com) and is included under the [MIT license](http://filamentgroup.com/examples/mit-license.txt).

Least squares calculation adapted from [“Linear least squares in Javascript”](http://dracoblue.net/dev/linear-least-squares-in-javascript/159/) by Jan Schütze (DracoBlue).


