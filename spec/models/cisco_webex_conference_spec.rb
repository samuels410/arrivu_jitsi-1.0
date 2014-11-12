require 'spec_helper'

describe JitsiMeetConference do
  subject { JitsiMeetConference.new }

  describe 'conference_status' do
    it 'is created when there is no start date' do
      subject.stub(:started_at) { nil }
      subject.conference_status.should == :created
    end

    it 'is active when there is a start date, a meeting, and no end date' do
      subject.stub(:started_at) { Time.now }
      subject.stub(:meeting) { [1, 2, 3] }
      subject.conference_status.should == :active
    end

    it 'is active when the end at is in the future' do
      subject.stub(:started_at) { Time.now }
      subject.stub(:meeting) { [1, 2, 3] }
      subject.stub(:end_at) { Time.now + 1200 }
      subject.conference_status.should == :active
    end

    it 'is closed when the end at is in the past' do
      subject.stub(:started_at) { Time.now }
      subject.stub(:meeting) { [1, 2, 3] }
      subject.stub(:end_at) { Time.now - 1200 }
      subject.conference_status.should == :closed
    end

    it 'is closed if there is no meeting' do
      subject.stub(:started_at) { Time.now }
      subject.stub(:meeting) { nil }
      subject.conference_status.should == :closed
    end

  end
end
