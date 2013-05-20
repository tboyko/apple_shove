require 'celluloid'

module AppleShove
  module APNS
    class NotifyConnection < Connection
      include Celluloid

      attr_accessor :pending_notifications
      attr_reader :name

      def initialize(opts = {})
        @name = self.class.generate_name(opts[:certificate], opts[:sandbox])
        @last_message           = nil
        @pending_notifications  = 0

        host = "gateway.#{opts[:sandbox] ? 'sandbox.' : ''}push.apple.com"

        super certificate:  opts[:certificate],
              host:         host,
              port:         2195
      end

      def self.generate_name(certificate, sandbox)
        Digest::SHA1.hexdigest("#{certificate}#{sandbox}")
      end

      exclusive
      
      def connect
        super
        @last_used = Time.now
      end

      def send(notification)
        message = notification.binary_message

        if @last_used && Time.now - @last_used > CONFIG[:reconnect_timer] * 60
          Logger.info("#{@name}\trefreshing connection")
          reconnect
        end
        
        begin
          socket.write message
        rescue Errno::EPIPE
          Logger.warn("#{@name}\tbroken pipe. reconnecting.")
          reconnect
          # EPIPE raises on the second write to a closed pipe. We need to resend
          # the previous notification that didn't make it through.
          socket.write @last_message if @last_message 
          retry
        rescue Errno::ETIMEDOUT
          Logger.warn("#{@name}\ttimeout. reconnecting.")
          reconnect
          retry
        end
        
        @last_message = message
        @last_used    = Time.now
        @pending_notifications -= 1
        Logger.info("#{@name}\tdelivered notification")
      end

      def shutdown
        while @pending_notifications > 0
          Logger.info("#{@name}\twaiting to shut down. #{@pending_notifications} job(s) remaining.")
          sleep 1
        end

        self.disconnect
        self.terminate
      end

    end
  end
end
