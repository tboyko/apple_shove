require 'celluloid'

module AppleShove
  module APNS
    class NotifyConnection < Connection
      include Celluloid

      attr_accessor :pending_notifications
      attr_reader :name

      def initialize(p12, sandbox)
        @name = self.class.generate_name(p12, sandbox)
        @last_message           = nil
        @pending_notifications  = 0

        host = "gateway.#{sandbox ? 'sandbox.' : ''}push.apple.com"

        super host, 2195, p12
      end

      def self.generate_name(p12, sandbox)
        Digest::SHA1.hexdigest("#{p12}#{sandbox}")
      end

      exclusive
      
      def connect
        super
        @last_used = Time.now
      end

      def send(notification)
        message = notification.binary_message

        begin
          if @last_used && Time.now - @last_used > CONFIG[:reconnect_timer] * 60
            Logger.info("refreshing connection", self, notification)
            reconnect
          end

          socket.write message
        rescue Errno::EPIPE
          Logger.warn("broken pipe. reconnecting.", self, notification)
          reconnect
          # EPIPE raises on the second write to a closed pipe. We need to resend
          # the previous notification that didn't make it through.
          socket.write @last_message if @last_message 
          retry
        rescue Errno::ETIMEDOUT
          Logger.warn("timeout. reconnecting.", self, notification)
          reconnect
          retry
        rescue Exception => e
          Logger.error("error sending notification: #{e.message}", self, notification)
        else
          Logger.info("delivered notification", self, notification)
        end

        @last_message = message
        @last_used    = Time.now
        @pending_notifications -= 1
      end

      def shutdown
        while @pending_notifications > 0
          Logger.info("waiting to shut down. #{@pending_notifications} job(s) remaining.", self)
          sleep 1
        end

        self.disconnect
        self.terminate
      end

    end
  end
end
