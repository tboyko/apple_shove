module AppleShove
  class Notification

    attr_accessor :certificate, :sandbox, :device_token, :payload
    
    def initialize(attributes = {})
        attributes.each { |k, v| self.send("#{k}=", v) }
    end
    
    def self.parse(json)
      self.new(JSON.parse(json))
    end
    
    def to_json(*a)
      hash = {}
      clean_instance_variables.each { |k| hash[k] = self.send(k) }
      hash.to_json(*a)
    end
    
    # Apple APNS format
    def binary_message(msgid = nil, expiration = nil)
      payload_json  = @payload.to_json

	if !msgid
		message = [0, 32, @device_token, payload_json.length, payload_json]
		packed = message.pack('CnH*na*')
	else
		msgid = 256 + Random.rand(100)	# Maybe this should be an attr_accessor
		expiration ||= 1400595627	# Maybe this should be an attr_accessor
		message       = [1, msgid.to_i, expiration.to_i, 32, @device_token, payload_json.length, payload_json]
		packed = message.pack("CNNnH*na*")
	end

	#print "\nMSG BINARY: "
	#print packed
	#print "\nMSG CHR: "
	#print packed.unpack("C*") 
	#print "\n"
	packed
    end
    
    private
    
    def clean_instance_variables
      self.instance_variables.collect { |i| i[1..-1] }
    end
               
  end
end
