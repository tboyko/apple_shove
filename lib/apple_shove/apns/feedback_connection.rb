module AppleShove
  module APNS
    class FeedbackConnection < Connection

      def initialize(p12, sandbox)
        host = "feedback.#{sandbox ? 'sandbox.' : ''}push.apple.com"

        super host, 2196, p12
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