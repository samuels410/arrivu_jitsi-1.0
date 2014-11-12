#
# Copyright (C) 2014 Arrivu Info Tech Private Limited.
#
# This file is part of Arrivu.
module Canvas
  module Plugins
    module Validators
     class JitsiMeetPluginValidator
      def self.validate(settings, plugin_setting)
        if settings.map(&:last).all?(&:blank?)
          {}
        else
          expected_settings = [:domain, :secret, :recording_enabled]
          if settings.size != expected_settings.size || settings.map(&:last).any?(&:blank?)
            plugin_setting.errors.add(:base, I18n.t('canvas.plugins.errors.all_fields_required', 'All fields are required'))
            false
          else
            settings.slice!(*expected_settings)
            settings[:recording_enabled] = Canvas::Plugin.value_to_boolean(settings[:recording_enabled])
            settings
          end
        end
      end
     end
   end
  end
end

