module AppleShove

  def self.notify(p12, device_token, payload, sandbox = false)
    notification  = Notification.new  p12:          p12,
                                      device_token: device_token,
                                      payload:      payload,
                                      sandbox:      sandbox

    queue = NotificationQueue.new(CONFIG[:redis_key])
    queue.add(notification)

    true
  end

  def self.feedback_tokens(p12, sandbox = false)
    conn = APNS::FeedbackConnection.new p12, sandbox

    conn.device_tokens
  end

  def self.stats
    redis = ::Redis.new
    queue = NotificationQueue.new(CONFIG[:redis_key], redis)

    size = queue.size

    redis.quit
    
    "queue size:\t#{size}"
  end

  # raises an exception if the p12 string is invalid
  def self.try_p12(p12)
    OpenSSLHelper.pkcs12_from_pem(p12)
    true
  end
  
end