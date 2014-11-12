require 'canvas_webex/webex_session'
require 'canvas_webex/service'
require 'canvas_webex/meeting'
require 'canvas_webex/training'
require 'nokogiri'
require 'uri'
require 'net/http'
require 'webmock/rspec'
require 'pry'

class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

# An object is present if it's not <tt>blank?</tt>.
  def present?
    !blank?
  end
end

class WebConference

  def conference_key
  end

  def settings
    {}
  end

  def self.after_save(*args)
  end

  def self.user_setting_field(arg, arg2)
  end

  def started_at
  end

  def ended_at
  end

  def end_at
  end

  def end_at=(arg)
  end

  def save
  end

  def close
  end
end
require 'models/arrivu_jitsi_conference'

WebMock.disable_net_connect!


RSpec.configure do |config|
  # some (optional) config here
end

def fixture(file)
  File.new(File.join(File.expand_path("../fixtures", __FILE__), file + ".xml"))
end

def stub_call(fixture_name, status = 200, request_body = nil)
  stub = stub_request(:post, "https://instructure.webex.com/WBXService/XMLService")
  stub = stub.with(body: request_body) if request_body
  stub.to_return(status: status, body: fixture(fixture_name), headers: {
    :content_type => 'application/xml; charset=utf-8'})
end

class Object
  def try(*a, &b)
    if a.empty? && block_given?
      yield self
    else
      public_send(*a, &b) if respond_to?(a.first)
    end
  end
end

class String
  def camelcase(first_letter = :upper)
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map { |e| e.capitalize }.join
  end
end