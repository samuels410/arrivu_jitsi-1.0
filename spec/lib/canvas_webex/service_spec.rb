require 'spec_helper'

describe ArrivuJitsi::Service do
  subject {ArrivuJitsi::Service.new('training', 'proserv_instructure', 'foo', '123', 'instructure', nil, 'test')}

  describe 'api_calls' do

    it 'gets a list of meeting summaries response body' do
      stub_call('meeting_list')
      result = subject.list_summary_meetings
      result.name.should == 'bodyContent'
    end

    it 'get a meeting response body' do
      stub_call('get_meeting')
      result = subject.get_meeting(123)
      result.name.should == 'bodyContent'
    end

    it 'get the host meeting url response body' do
      stub_call('host_meeting_url')
      result = subject.host_meeting_url(123, nil)
      result.name.should == 'bodyContent'
    end

    it 'get the join meeting url response body' do
      stub_call('join_meeting_url')
      result = subject.join_meeting_url(123, 'foo@bar')
      result.name.should == 'bodyContent'
    end

    it 'recording list response body' do
      stub_call('recording_list')
      result = subject.list_recordings(123)
      result.name.should == 'bodyContent'
    end

    it 'gets a create a meeting response body' do
      stub_call('create_meeting')
      result = subject.create_meeting('test')
      result.name.should == 'bodyContent'
    end

    it 'gets a time zone' do
      stub_call('list_timezones')
      result = subject.list_time_zone(4, '01/26/2006 21:00:00')
      result.name.should == 'bodyContent'
    end

  end


end
