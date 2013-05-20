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
    def binary_message
      payload_json  = @payload.to_json
      message       = [0, 32, @device_token, payload_json.length, payload_json]
      message.pack('CnH*na*')
    end
    
    private
    
    def clean_instance_variables
      self.instance_variables.collect { |i| i[1..-1] }
    end
               
  end
end
