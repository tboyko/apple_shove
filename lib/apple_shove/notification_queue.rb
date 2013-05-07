require 'json'
require 'redis'

module AppleShove
  class NotificationQueue
    
    def initialize(key, redis = Redis.new)
      @redis = redis
      @key = key
    end
    
    def add(notification)
      @redis.rpush @key, notification.to_json
    end
    
    def get
      element = @redis.lpop @key
      element ? Notification.parse(element) : nil
    end

    def size
      @redis.llen @key
    end   

  end
end