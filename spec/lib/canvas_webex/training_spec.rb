require 'spec_helper'

describe ArrivuJitsi::Training do
  let(:client) {ArrivuJitsi::Service.new('training', 'proserv_instructure', 'foo', '123', 'instructure', nil, 'test')}
  subject{ArrivuJitsi::Training.retrieve(123, client)}

  before(:each) do
    stub_call('get_training')
  end

  it 'returns the session name' do
    subject.conf_name.should == "test"
  end

  it 'returns the session key' do
    subject.session_key.should == "752909833"
  end

  it 'returns the start date' do
    subject.start_date.should == "01/14/2014 11:22:55"
  end

  it 'returns the status' do
    subject.status.should == "NOT_INPROGRESS"
  end

end
