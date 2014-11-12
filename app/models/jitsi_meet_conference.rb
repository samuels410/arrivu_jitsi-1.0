#
# Copyright (C) 2014 Arrivu Info Tech Private Limited.
#
# This file is part of Arrivu.

class JitsiMeetConference < WebConference

  # Public: Start a new conference and return its key. (required by WebConference)
  #
  # Returns a meeting.
  def initiate_conference
    return conference_key if conference_key && !retouch?
    unless self.conference_key
       slug = "arrivu_#{self.feed_code}".gsub(/[^a-zA-Z0-9_]/, "_")
       self.conference_key = slug.camelize
      chars = ('a'..'z').to_a + ('0'..'9').to_a
      # create user/admin passwords for this conference. we may want to show
      # the admin passwords in the ui in case moderators need them for any
      # admin-specific functionality within the BBB ui (or we could provide
      # ui for them to specify the password/key)
      settings[:user_key] = 8.times.map{ chars[chars.size * rand] }.join
      settings[:admin_key] = 8.times.map{ chars[chars.size * rand] }.join until settings[:admin_key] && settings[:admin_key] != settings[:user_key]
    end

    send_request(:create,conference_key) or return nil
    @conference_active = true
    save
    conference_key
  end

  def conference_status
    if (result = send_request(:isMeetingRunning,conference_key)) && result[:body][:center][:h1] == "301 Moved Permanently"
      :active
    else
      :closed
    end
  end

  def admin_join_url(user, return_to = "#{HostUrl.protocol}://#{HostUrl.default_host}")
    join_url(user, :admin)
  end

  def participant_join_url(user, return_to = "#{HostUrl.protocol}://#{HostUrl.default_host}")
    join_url(user)
  end


  private

  def retouch?
    # If we've queried the room status recently, use that result to determine if
    # we need to recreate it.
    if !@conference_active.nil?
      return !@conference_active
    end

    # BBB removes chat rooms that have been idle fairly quickly.
    # There's no harm in "creating" a room that already exists; the api will
    # just return the room info. So we'll just go ahead and recreate it
    # to make sure we don't accidentally redirect people to an inactive room.
    return true
  end

  def join_url(user, type = :user)
    generate_request(conference_key)
  end


  def generate_request(conference_key)
    "http://#{config[:domain]}/#{conference_key}"
  end

  def send_request(action, options)
    uri = URI.parse(generate_request(options))
    res = nil

    Net::HTTP.start(uri.host, uri.port) do |http|
      http.read_timeout = 10
      5.times do # follow redirects, but not forever
        logger.debug "Jitsi Meet api call: #{uri.path}?#{uri.query}"
        res = http.request_get("#{uri.path}?#{uri.query}")
        break if res.is_a?(Net::HTTPRedirection)
        url = res['location']
        uri = URI.parse(url)
      end
    end

    case res
      when Net::HTTPRedirection
        response = xml_to_hash(res.body)
        if response[:body][:center][:h1] == "301 Moved Permanently"
          return response
        else
          logger.error "jitsi meet api error #{response[:message]} (#{response[:messageKey]})"
        end
      else
        logger.error "jitsi meet http error #{res}"
    end
    nil
  rescue Timeout::Error
    logger.error "jitsi meet timeout error"
    nil
  rescue
    logger.error "jitsi meet unhandled exception #{$!}"
    nil
  end

  def xml_to_hash(xml_string)
    doc = Nokogiri::XML(xml_string)
    # assumes the top level value will be a hash
    xml_to_value(doc.root)
  end

  def xml_to_value(node)
    child_elements = node.element_children

    # if there are no children at all, then this is an empty node
    if node.children.empty?
      nil
      # If no child_elements, this is probably a text node, so just return its content
    elsif child_elements.empty?
      node.content
      # The BBB API follows the pattern where a plural element (ie <bars>)
      # contains many singular elements (ie <bar>) and nothing else. Detect this
      # and return an array to be assigned to the plural element.
    elsif node.name.singularize == child_elements.first.name
      child_elements.map { |child| xml_to_value(child) }
      # otherwise, make a hash of the child elements
    else
      child_elements.reduce({}) do |hash, child|
        hash[child.name.to_sym] = xml_to_value(child)
        hash
      end
    end
  end


end
