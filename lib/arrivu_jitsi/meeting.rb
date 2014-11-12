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
  class Meeting < CanvasWebex::WebexSession

    ATTRIBUTES = [:meeting_key, :conf_name, :start_date, :host_joined, :status]

    def self.retrieve(meeting_key, client = CanvasWebex.client)
      if response = client.get_meeting(meeting_key)
        Meeting.new(Nokogiri::XML(response.to_xml))
      end
    end

    def self.create(meeting_name, options = {}, client = CanvasWebex.client)
      if response = client.create_meeting(meeting_name, options)
        if meeting_key = response.at_xpath('//meetingkey').try(:text)
          retrieve(meeting_key, client)
        end
      end
    end

    # Public: Create a new Meeting
    #
    # meeting_xml - The xml returned for a meeting (must already exist).
    def initialize(meeting_xml)
      @attr_cache = {}
      @xml = meeting_xml
    end

    def session_key
      meeting_key
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
