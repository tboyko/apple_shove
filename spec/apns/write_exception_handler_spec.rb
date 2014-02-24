require 'apple_shove'
require 'openssl'

describe AppleShove::APNS::WriteExceptionHandler do

  def build_handler(exception, message)
    begin
      raise exception, message
    rescue Exception => e
      handler = AppleShove::APNS::WriteExceptionHandler.new(e)
    end

    handler
  end

  context 'when it encounters an unknown error' do 
    subject(:handler) { build_handler StandardError, "some unknown error" }

    it 'has default values' do
      expect(handler.message).to match(/error sending notification/)
      expect(handler).not_to be_reconnect
      expect(handler).not_to be_rewrite
      expect(handler).not_to be_retry
    end
  end

  context "when it's SSL connection has issues" do
    subject(:handler) { build_handler OpenSSL::SSL::SSLError, "SSL_write:: bad write retry" }

    it 'reconnects and retries' do
      expect(handler).to be_reconnect
      expect(handler).to be_retry
      expect(handler).to_not be_rewrite
    end
  end


end