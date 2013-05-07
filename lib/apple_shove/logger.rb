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
        
    def self.error(msg); instance.error(msg) end
    def self.debug(msg); instance.debug(msg) end
    def self.fatal(msg); instance.fatal(msg) end
    def self.info(msg); instance.info(msg) end
    def self.warn(msg); instance.warn(msg) end
    
  end
end