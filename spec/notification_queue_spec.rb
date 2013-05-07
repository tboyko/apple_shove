require 'apple_shove'
require './spec/notification_helper'

describe AppleShove::NotificationQueue do
  include NotificationHelper

  before do
    @q = AppleShove::NotificationQueue.new('dummy_key')
  end

  it 'should initialize without error' do
    @q.should_not eql(nil)
  end

  it 'should add notifications to the queue' do
    n = generate_notification
    @q.add(n)
  end

  it 'should count notification on the queue when they are there' do
    @q.size.should_not eql(0)
  end

  it 'should get notifications from the queue' do
    while n = @q.get
      n.should be_an_instance_of(AppleShove::Notification)
    end
  end

  it 'should count 0 notifications when the queue is empty' do
    @q.size.should eql(0)
  end

end