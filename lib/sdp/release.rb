module SDP
  class Release < Project
    attr :iterations
    attr_accessor :iteration_length
    # TODO: Deprecate in next release
    attr_accessor :planned_lock_down_offset
    attr_accessor :updated_on
    attr_accessor :products
    attr_accessor :name
    
    class << self
      def from_yaml(yaml)                
        r = YAML.load(yaml)
        # Set defaults values in case they don't exists in the yaml
        r.defaults
        # Fix the back reference to release for each iteration
        r.iterations.each {|iteration| iteration.release = r}        
        return r
      end            
    end
    
    def initialize(name, start_date, end_date, products=nil)
      @products = products
      @name = name
      @iterations = Array.new
      @updated_on = Time.now.strftime("%Y-%m-%d %H:%M:%S %z")
      defaults      
      super(start_date, end_date)
    end
    
    def track
      if started?
        if @iterations.size == 0 || @iterations.last.ended?
          @iterations.push Iteration.new(self, @iterations.size+1, Date.today, Date.today + @iteration_length)
        end
      end
      @iterations.each {|iteration|
        iteration.track
      }      
      @updated_on = Time.now.strftime("%Y-%m-%d %H:%M:%S %z")
    end
    
    alias :planned_end_date :end_date
    
    def actual_end_date
      if ended?
        @iterations.last.end_date
      else
        @end_date
      end  
    end
    
    def ended?
      remaining_now.size == 0 && Date.today >= @end_date
    end

    def find_iteration(number)
      if number-1 > @iterations.size
        nil
      else
        @iterations[number-1]
      end
    end
    
    # Return a wiki url for this iteration
    def wiki_url
      "https://hq.songbirdnest.com/wiki/index.php?title=Release:#{name}"
    end

    def to_yaml_properties
        ["@name"] + super + ["@updated_on", "@products", "@iteration_length", "@iterations"]
    end
        
    def to_s
      s =  "#{@name} Release\n"
      s += "Start: #{@start_date}\n"
      s += "End: #{@end_date}\n"
      s += "Iteration length: #{@iteration_length} days\n"
      @iterations.each {|iteration|
        s += iteration.to_s
      }
      s
    end
    
    def defaults
      @iteration_length = 7 if @iteration_length.nil?  # 7 calendar days 
      @planned_lock_down_offset = 12*60*60 if @planned_lock_down_offset.nil? # 12 hours in seconds      
    end
  end  
end
