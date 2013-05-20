require 'openssl'

module AppleShove
  class OpenSSLHelper
    
    def self.pkcs12_from_pem(p12_pem)
      key  = ::OpenSSL::PKey::RSA.new         p12_pem
      cert = ::OpenSSL::X509::Certificate.new p12_pem
      p12  = ::OpenSSL::PKCS12.create nil, nil, key, cert

      p12
    end

  end
end