require 'locomotive/common'

module Spec
  module Helpers

    def reset!
      FileUtils.rm_rf(File.expand_path('../../../site', __FILE__))
    end

    def remove_logs
      FileUtils.rm_rf(File.expand_path('../../fixtures/default/log', __FILE__))
    end

    def setup_common(logger_output = nil)
      Locomotive::Common.reset
      Locomotive::Common.configure do |config|
        config.notifier = Locomotive::Common::Logger.setup(logger_output)
      end
    end

    def restore_mongodb
      path = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'fixtures', 'mongodb')
      `mongo steam_test --eval "db.dropDatabase()"`
      `mongorestore -d steam_test #{path}`
    end

    def run_server
      output = ENV['STEAM_VERBOSE'] ? nil : File.join(default_fixture_site_path, 'log/steam.log')
      setup_common(output)

      Locomotive::Steam.configure do |config|
        config.mode           = :test
        config.site_path      = default_fixture_site_path
        config.serve_assets   = true
        config.minify_assets  = true
      end

      Locomotive::Common::Logger.info 'Server started...'
      Locomotive::Steam::Server.to_app
    end

    def default_fixture_site_path
      File.expand_path('../../fixtures/default/', __FILE__)
    end

    def env_for(url, opts={})
      Rack::MockRequest.env_for(url, opts)
    end
  end
end
