## Example Agent Install

1. Download the latest tagged version from `https://github.com/newrelic-platform/newrelic_example_plugin/tags`
2. Extract to the location you want to run the example agent from
3. Copy `config/template_newrelic_plugin.yml` to `config/newrelic_plugin.yml`
4. Edit `config/newrelic_plugin.yml` and replace "YOUR_LICENSE_KEY_HERE" with your New Relic license key
5. Create a plugin in New Relic
6. Edit `newrelic_example_agent` and replace "PUT YOUR GUID HERE" with the GUID that was generated when you created the plugin
7. run `./newrelic_example_agent`
