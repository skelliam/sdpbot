module SDP
  class Project   
    attr_accessor :start_date
    attr_accessor :end_date
             
    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date
      @end_date = start_date if start_date > end_date
    end
    
    def remaining_now
      q = Query.open(name, {:products => products})
      View.from_query(q)
    end

    def asap_remaining_now
      q = Query.open('ASAP', {:products => products})
      View.from_query(q)
    end

    # Return a view of completd items during this date range as of now
    # Because the state of an item can change outside of the date range, it's best
    # to run snapshot this query as well.
    def completed_now
      q = Query.completed(name, @start_date, @end_date, {:products => products})
      View.from_query(q)
    end

    def asap_completed_now
      q = Query.completed('ASAP', @start_date, @end_date, {:products => products})
      View.from_query(q)
    end    
    
    def started?
      Date.today >= @start_date && !ended?
    end
    
    # Can be overriden in case project slips
    def ended?
      Date.today >= @end_date
    end        

    def name
      # To override       
      raise "Method undefined"
    end
    
    def products
      # To override 
      raise "Method undefined"
    end
    
    def to_yaml_properties
      ["@start_date", "@end_date"]
    end
  end
end
