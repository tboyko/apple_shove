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
    expect_any_instance_of(Redis).to receive(:rpush)

    n = generate_notification
    @q.add(n)
  end

  it 'should count notification on the queue when they are there' do
    expect_any_instance_of(Redis).to receive(:llen).and_return(1)

    expect(@q.size).to be_a_kind_of(Integer)
  end

  it 'should get notifications from the queue' do
    json = { p12: 'some p12', device_token: '123123123', payload: 'this is a test payload' }.to_json
    expect_any_instance_of(Redis).to receive(:lpop).and_return(json)

    notification = @q.get
    
    expect(notification).to be_an_instance_of(AppleShove::Notification)
  end

  it 'should count 0 notifications when the queue is empty' do
    expect_any_instance_of(Redis).to receive(:llen).and_return(0)
    
    @q.size.should eql(0)
  end

end