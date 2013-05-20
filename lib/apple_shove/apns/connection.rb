require 'openssl'

module AppleShove
  module APNS
    class Connection
      
      attr_reader :last_used
      
      def initialize(opts = {})
        @host         = opts[:host]
        @port         = opts[:port]
	@certificate  = OpenSSL::PKCS12.new(opts[:certificate], "")	# Ensure we can parse a empty password encoded p12 file with both private key + certificate
      end

      # lazy connect the socket
      def socket
        connect unless connected?
        @ssl_sock
      end

      def disconnect
        @ssl_sock.close if @ssl_sock
        @sock.close     if @sock
      end

      def reconnect
        disconnect
        connect
      end

      private
      
      def connect
        @sock = TCPSocket.new(@host, @port)
        @sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)

        context         = ::OpenSSL::SSL::SSLContext.new
        context.cert    = ::OpenSSL::X509::Certificate.new(@certificate.certificate)
        context.key     = ::OpenSSL::PKey::RSA.new(@certificate.key) 
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
