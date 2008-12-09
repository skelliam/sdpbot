require 'fileutils'

module SDP
  DEFAULT_CONFIG_PATH = File.dirname(__FILE__) + '/../../config/personel'
  
  def holidays(name, &block)
    Personel.holidays = Calendar.new(name)
    Personel.holidays.instance_eval &block
    Personel.holidays
  end

  class Personel
    @@engineers = Array.new
    @@holidays = Calendar.new
    
    def self.engineers
      @@engineers
    end    

    def self.holidays
      @@holidays
    end    

    def self.holidays=(calendar)
      @@holidays = calendar
    end    
    
    # Load the DSL that describe personel stuff
    def self.load(path=DEFAULT_CONFIG_PATH)
      Dir.glob("#{path}/*.rb").each {|file|
        SDP.class_eval(File.read(file))
      }
    end
  end  
end
