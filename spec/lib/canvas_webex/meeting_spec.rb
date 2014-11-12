require 'spec_helper'

describe ArrivuJitsi::Meeting do
  let(:client) {ArrivuJitsi::Service.new('meeting', 'proserv_instructure', 'foo', '123', 'instructure', nil, 'test')}
  subject{ArrivuJitsi::Meeting.retrieve(123, client)}

  before(:each) do
    stub_call('get_meeting')
  end

  it 'returns the meeting name' do
    subject.conf_name.should == "test"
  end

  it 'returns the meeting key' do
    subject.meeting_key.should == "807833538"
  end

  it 'returns the start date' do
    subject.start_date.should == "10/22/2013 10:59:19"
  end

  it 'returns the host_joined value' do
    subject.host_joined.should == "false"
  end

  it 'returns the status' do
    subject.status.should == "NOT_INPROGRESS"
  end

end
