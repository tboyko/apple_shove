require 'logger'
require 'singleton'

module AppleShove
  class Logger < ::Logger
    include Singleton

    class Formatter
      def call(severity, time, progname, msg)
        formatted_severity = sprintf("%-5s",severity.to_s)
        formatted_time = time.strftime("%Y-%m-%d %H:%M:%S")
        "[#{formatted_severity} #{formatted_time}] #{msg.strip}\n"
      end
    end
    
    def initialize(output_stream = STDOUT)
      super(output_stream)
      self.formatter = Formatter.new
      self
    end
        
    def self.error(msg, connection = nil, notification = nil)
      log('error', msg, connection, notification) 
    end

    def self.debug(msg, connection = nil, notification = nil)
      log('debug', msg, connection, notification) 
    end

    def self.fatal(msg, connection = nil, notification = nil)
      log('fatal', msg, connection, notification) 
    end

    def self.info(msg, connection = nil, notification = nil)
      log('info', msg, connection, notification) 
    end

    def self.warn(msg, connection = nil, notification = nil)
      log('warn', msg, connection, notification) 
    end

    private

    def self.log(severity, msg, connection, notification)
      output = ''
      output += "#{connection.name}\t" if connection && connection.respond_to?("name")
      output += "#{notification.device_token}\t" if notification
      output += msg
      
      instance.send(severity, output)
    end
  end
end