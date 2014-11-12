#
# Copyright (C) 2014 Arrivu Info Tech Private Limited.
#
# This file is part of Arrivu.


module Arrivu
  module Plugins
    class JitsiMeet
      require_dependency 'jitsi_meet_validator'
      # Public: Bootstrap the gem on app load.
      #
      # Returns nothing.
      def initialize; register; end

      protected
      # Internal: Register as a plugin with Arrivu LMS
      #
      # Returns a Canvas plugin object
      def register
          Canvas::Plugin.register('jitsi_meet', :web_conferencing, {
              :name => lambda{ t :name, "Jitsi Meet" },
              :description => lambda{ t :description, "Jitsi Meet web conferencing support" },
              :website => 'https://jitsi.org/',
              :author => 'Arrivu Info Tech Private Limited',
              :author_website => 'http://www.arrivuapps.com',
              :version => '1.0.0',
              :settings_partial => 'plugins/jitsi_meet_settings',
              :validator => 'JitsiMeetPluginValidator',
              :encrypted_settings => [:secret]
          })

      end

    end
  end
end
