module AppleShove
  module APNS
    class ErrorResponsePacket

      attr_reader :status, :identifier

      STATUS_MESSAGES = { 0   => 'No errors encountered',
                          1   => 'Processing error',
                          2   => 'Missing device token',
                          3   => 'Missing topic',
                          4   => 'Missing payload',
                          5   => 'Invalid token size',
                          6   => 'Invalid topic size',
                          7   => 'Invalid payload size',
                          8   => 'Invalid token',
                          10  => 'Shotdown',
                          255 => 'None (unknown)' }

      def initialize(binary_response)
        response = binary_response.unpack('CCA4')

        @status     = response[1]
        @identifier = response[2]
      end

      def status_message
        STATUS_MESSAGES[@status]
      end

    end
  end
end
