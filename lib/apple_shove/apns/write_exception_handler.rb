require 'openssl'

module AppleShove
  module APNS
    class WriteExceptionHandler

      attr_reader :message

      def initialize exception

        # defaults

        @message    = "error sending notification: #{exception.class} - #{exception.message}"
        @reconnect  = false
        @rewrite    = false
        @retry      = false

        # known cases

        case exception
        when Errno::EPIPE
          @message    = "broken pipe. reconnecting."
          @reconnect  = true
          @rewrite    = true
          @retry      = true
        when Errno::ETIMEDOUT
          @message    = "timeout. reconnecting."
          @reconnect  = true
          @retry      = true
        when OpenSSL::SSL::SSLError
          if exception.message.match 'bad write retry'
            @message    = "SSL bad write. reconnecting."
            @reconnect  = true
            @retry      = true
          end
        end

      end

      def reconnect?
        @reconnect
      end

      def rewrite?
        @rewrite
      end

      def retry?
        @retry
      end

    end
  end
end
