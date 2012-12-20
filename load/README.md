* Load the raw Apache logs into a database with a collection (`$COLLECTION`), for example using Information Studio
* Import the workspace into Query Console
* Load `user-agents.map.xml` into the database at the URI `/user-agents.map`
* In the “Process” tab, set the `$COLLECTION` variable to your collection name above
* Adjust the predicate range in `for $d in (collection($COLLECTION))[1 to 100]` so that the request doesn't timeout
* Run the “Process” query, adjust the range and rerun until all of the log files have been processed
* Run the “user agent” query to update the user agent lookup map
