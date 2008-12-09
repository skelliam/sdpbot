require 'set'

module SDP
  # Implements a calendar as a set of dates
  class Calendar < Set    
    attr_accessor :name
    
    def initialize(name='', *args)
      @name = name
      super(*args)
    end
    
    def on(s, name='')
      d = Date.parse(s)
      d.name = name
      self.add d
    end

    def to_s
      s  = "#{@name}\n"
      self.each {|day|
        s += "#{day.to_s} #{day.name}\n"
      }
      s
    end
  end

  # DSL to describe calendar
  def calendar(name, &block)
    calendar = Calendar.new(name)
    calendar.instance_eval &block
    calendar  
  end
end

