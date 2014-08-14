require 'openssl'

module AppleShove
  module APNS
    class Connection

      attr_reader :last_used

      def initialize(host, port, p12_string)
        @host       = host
        @port       = port
        @p12_string = p12_string

        @p12        = nil
      end

      # lazy connect the socket
      def socket
        connect unless connected?
        @ssl_sock
      end

      def disconnect
        @ssl_sock.close if @ssl_sock

        begin
          @sock.close if @sock
        rescue IOError
          @sock = nil
        end
      end

      def reconnect
        disconnect
        connect
      end

      def safe_last_used
        @last_used || Time.at(0)
      end

      private

      def connect
        @p12          ||= OpenSSLHelper.pkcs12_from_pem(@p12_string)
        context         = ::OpenSSL::SSL::SSLContext.new
        context.cert    = @p12.certificate
        context.key     = @p12.key

        @sock           = TCPSocket.new(@host, @port)
        @sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)
        @ssl_sock       = ::OpenSSL::SSL::SSLSocket.new(@sock, context)
        @ssl_sock.sync  = true

        @ssl_sock.connect
      end

      def connected?
        @sock && @ssl_sock
      end

    end
  end
end
