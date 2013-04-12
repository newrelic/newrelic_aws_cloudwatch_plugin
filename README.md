## New Relic Apache HTTPD Extension

### Instructions for running the Apache HTTPD Extension

1. Go to https://github.com/newrelic-platform/newrelic_apache_httpd_extension.git
2. Download and extract the source
3. Run `bundle install`
4. Edit `config/newrelic_plugin.yml` and replace "YOUR_LICENSE_KEY_HERE" with your New Relic license key
5. Edit `config/newrelic_plugin.yml` and replace "httpd.apache.org" with the hostname of your Apache HTTPD server
5. Execute `./newrelic_apache_httpd_extension`
1. Go back to the Extensions list, after a brief period you will see an entry for the Apache HTTPD Extension
