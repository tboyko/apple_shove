module AppleShove

  def self.notify(certificate, device_token, payload, sandbox = false)
    notification  = Notification.new  certificate:  certificate,
                                      device_token: device_token,
                                      payload:      payload,
                                      sandbox:      sandbox

    queue = NotificationQueue.new(CONFIG[:redis_key])
    queue.add(notification)

    true
  end

  def self.feedback_tokens(certificate, sandbox = false)
    conn = APNS::FeedbackConnection.new certificate:  certificate,
                                        sandbox:      sandbox

    conn.device_tokens
  end

  def self.stats
    redis = ::Redis.new
    queue = NotificationQueue.new(CONFIG[:redis_key], redis)

    size = queue.size

    redis.quit
    
    "queue size:\t#{size}"
  end

end