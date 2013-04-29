module NewRelicAWS
  module Config
    def self.options
      aws = NewRelic::Plugin::Config.config.options["aws"]
      unless aws.is_a?(Hash) &&
          aws["access_key"].is_a?(String) &&
          aws["secret_key"].is_a?(String) &&
          aws["regions"].is_a?(Array)
        raise NewRelic::Plugin::BadConfig, "Missing or invalid AWS configuration."
      end
      aws
    end
  end
end
