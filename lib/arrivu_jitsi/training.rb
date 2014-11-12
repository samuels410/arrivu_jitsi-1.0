#
# Copyright (C) 2013 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#
module CanvasWebex
  class Training < CanvasWebex::WebexSession


    ATTRIBUTES = [:session_key, :conf_name, :start_date, :status]

    def self.retrieve(session_key, client = CanvasWebex.client)
      if response = client.get_training_session(session_key)
        Training.new(Nokogiri::XML(response.to_xml))
      end
    end

    def self.create(session_name, options = {}, client = CanvasWebex.client)
      if response = client.create_training_session(session_name, options)
        if session_key = response.at_xpath('//sessionkey').try(:text)
          retrieve(session_key, client)
        end
      end
    end

    # Public: Create a new Training
    #
    # training_xml - The xml returned for a training (must already exist).
    def initialize(training_xml)
      @attr_cache = {}
      @xml = training_xml
    end

    def method_missing(meth, *args, &block)
      if ATTRIBUTES.include?(meth)
        @attr_cache[meth] ||= @xml.at_xpath("//*[contains(translate(name(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'), '#{meth.to_s.camelcase(:lower).downcase}')]").try(:text)
      else
        super
      end
    end

  end
end
