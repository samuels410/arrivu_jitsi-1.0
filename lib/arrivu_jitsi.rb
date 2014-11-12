#
# Copyright (C) 2014 Arrivu Info Tech Private Limited.
#
# This file is part of Arrivu.

require_dependency "arrivu_jitsi/version"

module ArrivuJitsi
  class ConnectionError < StandardError; end

  configure_method = Proc.new do
    view_path = File.join(File.dirname(__FILE__), '..', 'app', 'views')
    unless ApplicationController.view_paths.include?(view_path)
      ApplicationController.view_paths.unshift(view_path)
    end

    path = File.expand_path('../app/models', File.dirname(__FILE__))
    ActiveSupport::Dependencies.autoload_paths << path unless ActiveSupport::Dependencies.autoload_paths.include? path

    require_dependency File.expand_path('../app/models/jitsi_meet_conference.rb', File.dirname(__FILE__))
    require_dependency "jitsi_meet_validator"
    require_dependency "arrivu/plugins/jitsi_meet"

    Arrivu::Plugins::JitsiMeet.new
  end

  if CANVAS_RAILS2
    Rails.configuration.to_prepare(&configure_method)
  else
    class Railtie < Rails::Railtie; end
    Railtie.config.to_prepare(&configure_method)
  end

  # Public: Find the plugin configuration.
  #
  # Returns a settings hash.
  def self.config
    Canvas::Plugin.find('arrivu_jitsi').settings || {}
  end

  # Return a cached Connect Service object to make requests with.
  #
  # Returns a CiscoWwebex::Service.
  def self.client
    Service.new(*self.config.values_at(:webex_service, :webex_id, :password_dec, :site_id, :site_name, :partner_id, :meeting_password_dec))
  end
end
