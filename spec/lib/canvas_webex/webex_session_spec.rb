require 'spec_helper'

describe ArrivuJitsi::WebexSession do
  let(:client) {ArrivuJitsi::Service.new('meeting', 'proserv_instructure', 'foo', '123', 'instructure', nil, 'test')}

  it 'parses a cisco timestamp' do
    stub_call('list_timezones')
    ts = ArrivuJitsi::WebexSession.parse_time_stamp(4, '01/26/2006 21:00:00', client)
    ts.to_s.should == '2006-01-26T21:00:00-08:00'
  end

end
