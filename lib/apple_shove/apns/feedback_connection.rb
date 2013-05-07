module AppleShove
  module APNS
    class FeedbackConnection < Connection

      def initialize(opts = {})
        host = "feedback.#{opts[:sandbox] ? 'sandbox.' : ''}push.apple.com"

        super certificate:  opts[:certificate],
              host:         host,
              port:         2196
      end

      def device_tokens
        tokens = []
        while response = socket.read(38)
          timestamp, token_length, device_token = response.unpack('N1n1H*')
          tokens << device_token
        end

        tokens
      end

    end
  end
end