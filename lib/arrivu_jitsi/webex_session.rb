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
  class WebexSession

    def self.create(meeting_name, options = {}, client = CanvasWebex.client)
      case client.webex_service
        when 'meeting'
          CanvasWebex::Meeting.create(meeting_name, options, client)
        when 'training'
          CanvasWebex::Training.create(meeting_name, options, client)
      end
    end

    def host_url(client = CanvasWebex.client)
      if response = client.host_meeting_url(session_key, nil)
        response.at_xpath('hostMeetingURL').try(:text)
      end
    end

    def join_url(client = CanvasWebex.client)
      if response = client.join_meeting_url(session_key, nil)
        response.at_xpath('joinMeetingURL').text
      end
    end

    def self.recordings(session_key, client = CanvasWebex.client)
      if response = session_key && client.list_recordings(session_key)
        response.search('recording').map do |rec_xml|
          created_ts = rec_xml.at_xpath('createTime').try(:text)
          tz_id = rec_xml.at_xpath('timeZoneID').try(:text)
          created_at = self.parse_time_stamp(tz_id, created_ts)
          recording = {
            recording_id: rec_xml.at_xpath('recordingID').try(:text),
            title: rec_xml.at_xpath('name').try(:text),
            playback_url: rec_xml.at_xpath('streamURL').try(:text),
            created_at: self.parse_time_stamp(tz_id, created_ts).to_s
          }
          if duration = rec_xml.at_xpath('duration').try(:text)
            recording[:duration_minutes] = duration.to_i / 60
          end
          recording
        end
      else
        []
      end
    end

    def self.parse_time_stamp(time_zone, time_stamp, client = CanvasWebex.client)
      if response = client.list_time_zone(time_zone, time_stamp)
        if m_offset = response.at_xpath('timeZone/gmtOffset').try(:text).try(:to_i)
          offset_string = "%+0#3d:00" %[(m_offset / 60)]
          DateTime.strptime(time_stamp + offset_string, '%m/%d/%Y %H:%M:%S%z')
        else
          DateTime.strptime(time_stamp, '%m/%d/%Y %H:%M:%S')
        end
      else
        ""
      end
    end

  end
end
