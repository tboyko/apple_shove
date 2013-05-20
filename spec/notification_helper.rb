module NotificationHelper

  def generate_notification
    p12           = "DummyP12"
    sandbox       = false
    device_token  = hex(64)
    payload       = { mdm: "#{hex(8)}-#{hex(4)}-#{hex(4)}-#{hex(4)}-#{hex(12)}".downcase }
  
    AppleShove::Notification.new  p12:          p12,
                                  sandbox:      sandbox,
                                  device_token: device_token,
                                  payload:      payload
  end

  private

  def hex(length)
    length.times.map { ((0..9).to_a + ('a'..'f').to_a)[rand(16)] }.join
  end

end