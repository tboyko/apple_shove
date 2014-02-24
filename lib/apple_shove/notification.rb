module AppleShove
  class Notification

    attr_accessor :p12, :sandbox, :device_token, :payload, :expiration_date, :priority
    
    def initialize(attributes = {})
      [:p12, :device_token, :payload].each do |req_attr|
        raise "#{req_attr} must be specified" unless attributes.keys.collect { |k| k.to_s }.include? req_attr.to_s
      end

      attributes.each { |k, v| self.send("#{k}=", v) }
    
      @sandbox          = false if @sandbox.nil?
      @expiration_date  ||= Time.now + 60*60*24*365
      @priority         ||= 10
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
      
      frame = [ [ 1, 32,                  @device_token         ].pack('CnH64'),
                [ 2, payload_json.length, payload_json          ].pack('Cna*'),
                [ 3, 4,                   ''                    ].pack('CnA4'),
                [ 4, 4,                   @expiration_date.to_i ].pack('CnN'),
                [ 5, 1,                   @priority             ].pack('CnC')     ].join

      [ 2, frame.length, frame ].pack('CNa*')
    end
    
    private
    
    def clean_instance_variables
      self.instance_variables.collect { |i| i[1..-1] }
    end
               
  end
end
