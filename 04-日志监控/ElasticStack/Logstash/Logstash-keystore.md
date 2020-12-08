# logstash-keystore

``` yml
Usage:
--------
bin/logstash-keystore [option] command [argument]

Commands:
--------
create - Creates a new Logstash keystore  (e.g. bin/logstash-keystore create)
list   - List entries in the keystore  (e.g. bin/logstash-keystore list)
add    - Add a value to the keystore (e.g. bin/logstash-keystore add my-secret)
remove - Remove a value from the keystore  (e.g. bin/logstash-keystore remove my-secret)

Argument:
--------
--help - Display command specific help  (e.g. bin/logstash-keystore add --help)

Options:
--------
--path.settings - Set the directory for the keystore. This is should be the same directory as the logstash.yml settings file. The default is the config directory under Logstash home. (e.g. bin/logstash-keystore --path.settings /tmp/foo create)
```