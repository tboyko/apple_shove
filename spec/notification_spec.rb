require 'apple_shove'
require './spec/notification_helper'

describe AppleShove::Notification do
  include NotificationHelper
  
  before do
    @n = generate_notification
  end

  it "converts to and from json" do
    json = @n.to_json

    json.should be_an_instance_of(String)

    n2 = AppleShove::Notification.parse(json)

    @n.to_json.should == n2.to_json
  end

  it "creates a binary message for apns" do
    m = @n.binary_message

    m.should be_an_instance_of(String)
    m.length.should > 0
  end

end