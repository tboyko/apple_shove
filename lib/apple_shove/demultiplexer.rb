module AppleShove
  class Demultiplexer

    def initialize(opts = {})
      unless opts[:max_apns_connections]
        raise ArgumentError, 'max_apns_connections must be specified'
      end

      @max_connections = opts[:max_apns_connections].to_i

      @connections  = {}
      @queue        = NotificationQueue.new(CONFIG[:redis_key])
    end

    def start

      while true

        if notification = @queue.get
          conn = get_connection(notification)
          conn.pending_notifications += 1
          conn.async.send(notification)
        else
          sleep 1
        end

      end

    end

    private

    def get_connection(notification)
      key         = APNS::NotifyConnection.generate_name(notification.p12, notification.sandbox)
      connection  = @connections[key]

      unless connection
        retire_oldest_connection if @connections.count >= @max_connections

        connection        = APNS::NotifyConnection.new notification.p12, notification.sandbox
        @connections[key] = connection
        Logger.info "created connection to APNS (#{@connections.count} total)", connection
      end

      connection
    end

    def retire_oldest_connection
      if oldest = @connections.min_by { |_k, v| v.safe_last_used }
        key, conn = oldest[0], oldest[1]
        conn_name = conn.name
        @connections.delete key
        conn.shutdown

        Logger.info "destroyed connection to APNS (#{@connections.count} total)", conn_name
      end
    end

  end
end