module CanvasWebex
  class Service

    attr_reader :webex_service, :webex_id, :password, :site_id, :site_name, :partner_id, :status, :meeting_password


    def initialize(webex_service, webex_id, password, site_id, site_name, partner_id, meeting_password)
      @webex_service, @webex_id, @password, @site_id, @site_name, @partner_id, @meeting_password =
        [webex_service, webex_id, password, site_id, site_name, partner_id, meeting_password]
    end

    def list_summary_meetings
      body = xml_request do |xml|
        xml.bodyContent('xsi:type' => 'java:com.webex.service.binding.meeting.LstsummaryMeeting'){
          xml.listControl{
            xml.startFrom 1
            xml.listMethod 'OR'
          }
          xml.order{
            xml.orderAD 'ASC'
            xml.orderBy 'STARTTIME'
            xml.orderAD 'ASC'
            xml.orderBy 'CONFNAME'
          }
        }
      end
      request(body)
    end

    def create_meeting(confName, options = {})

      body = xml_request do |xml|
        xml.bodyContent('xsi:type' =>'java:com.webex.service.binding.meeting.CreateMeeting'){
          xml.metaData{
            xml.confName confName
          }
          if meeting_password != nil && meeting_password.strip != ''
            xml.accessControl{
              xml.meetingPassword meeting_password
            }
          end
          xml.schedule{
            if options[:scheduled_date].present?
              xml.startDate options[:scheduled_date].in_time_zone('America/Los_Angeles').strftime("%m/%d/%Y %T") rescue nil
              xml.timeZoneID 4
            else
              xml.startDate
            end
            xml.duration(options[:duration].to_i)
          }
          if options[:emails]
            xml.participants{
              xml.attendees{
                options[:emails].each do |email|
                  xml.attendee {
                    xml.emailInvitations true
                    xml.person {
                      xml.email email
                    }
                  }
                end
              }
            }
          end
        }
      end
      request(body)
    end

    def create_training_session(confName, options = {})
      body = xml_request do |xml|
        xml.bodyContent('xsi:type' =>'java:com.webex.service.binding.training.CreateTrainingSession'){
          xml.metaData{
            xml.confName confName
          }
          if meeting_password != nil && meeting_password.strip != ''
            xml.accessControl{
              xml.sessionPassword meeting_password
            }
          end
          xml.schedule{
            if options[:scheduled_date].present?
              xml.startDate options[:scheduled_date].in_time_zone('America/Los_Angeles').strftime("%m/%d/%Y %T") rescue nil
              xml.timeZoneID 4
            else
              xml.startDate
            end
            xml.duration(options[:duration].to_i)
          }
          if options[:emails]
            xml.attendees{
              xml.participants{
                options[:emails].each do |email|
                  xml.participant{
                    xml.person {
                      xml.email email
                    }
                  }
                end
              }
            }
            xml.attendeeOptions {
              xml.emailInvitations true
            }
          end
        }
      end
      request(body)
    end

    def host_meeting_url(meeting_key, email)
      body = xml_request(email) do |xml|
        xml.bodyContent('xsi:type' => 'java:com.webex.service.binding.meeting.GethosturlMeeting'){
          xml.meetingKey meeting_key
        }
      end
      request(body)
    end

    def join_meeting_url(meeting_key, email)
      body = xml_request(email) do |xml|
        xml.bodyContent('xsi:type' => 'java:com.webex.service.binding.meeting.GetjoinurlMeeting'){
          xml.meetingKey meeting_key
        }
      end
      request(body)
    end

    def get_meeting(meeting_key)
      body = xml_request do |xml|
        xml.bodyContent('xsi:type' => 'java:com.webex.service.binding.meeting.GetMeeting'){
          xml.meetingKey meeting_key
        }
      end
      begin
        request(body)
      rescue CanvasWebex::ConnectionError
        nil
      end

    end

    def get_training_session(session_key)
      body = xml_request do |xml|
        xml.bodyContent('xsi:type' => 'java:com.webex.service.binding.training.GetTrainingSession'){
          xml.sessionKey session_key
        }
      end
      begin
        request(body)
      rescue CanvasWebex::ConnectionError
        nil
      end
    end

    def list_recordings(meeting_key)
      body = xml_request do |xml|
        xml.bodyContent('xsi:type' => 'java:com.webex.service.binding.ep.LstRecording'){
          xml.listControl{
            xml.startFrom 0
          }
          xml.sessionKey meeting_key
          xml.hostWebExID @webex_id
          xml.returnSessionDetails 'true'
        }
      end
      begin
        request(body)
      rescue CanvasWebex::ConnectionError
        nil
      end
    end

    def list_time_zone(id, date)
      body = xml_request do |xml|
        xml.bodyContent('xsi:type' => 'site.LstTimeZone'){
          xml.timeZoneID id
          xml.date date
        }
      end
      request(body)
    end

    def xml_request(email = nil)
      Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.message('xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
                            'xmlns:serv' =>  "http://www.webex.com/schemas/2002/06/service",
                            'xsi:schemaLocation' => "http://www.webex.com/schemas/2002/06/service"){
          xml.parent.namespace = xml.parent.namespace_definitions.find{|ns|ns.prefix=="serv"}
          xml.header{
            xml.parent.namespace = xml.parent.namespace_definitions.first
            xml.securityContext {
              xml.webExID @webex_id
              xml.password @password
              xml.siteID @site_id
              xml.partnerID @partner_id if !!@partner_id
              xml.email email if !!email
            }
          }
          xml.body{
            xml.parent.namespace = xml.parent.namespace_definitions.first
            yield xml
          }
        }
      end.to_xml
    end

    def request(body)
      uri = URI.parse("https://#{@site_name}.webex.com")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.post('/WBXService/XMLService', body)
      xml = Nokogiri::XML(response.body).remove_namespaces!
      if xml.at_xpath('/message/header/response/result').try(:text) == 'SUCCESS'
        xml.at_xpath('/message/body/bodyContent')
      else
        raise CanvasWebex::ConnectionError.new(xml.at_xpath('/message/header/response/reason').try(:text))
      end
    end

  end
end
