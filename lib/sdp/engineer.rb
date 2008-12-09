module SDP  
  def engineer(name, &block)
    engineer = Engineer.new(name)
    engineer.instance_eval &block
    Personel.engineers << engineer
    engineer
  end
  
  class Engineer
    attr :name
    attr :email
    attr :pto
    
    def initialize(name, email='', pto=Calendar.new('pto'))
      @name = name
      @email = email
      @pto = pto
    end
    
    # Returns a hash of stats for the engineer
    def stats(period_start, period_end, release='')
      q = Query.fixed_by(release, period_start, period_end, @email)
      view = View.from_query(q)

      begin
        total_cost = view.total_cost
      rescue View::CostMissingException => e
        total_cost = e.partial_cost
      end
      
      work_days = Date.week_days(period_start, period_end) - Personel.holidays - @pto

      stats = Hash.new
      stats[:work_days] = work_days.size
      stats[:velocity] = Velocity.compute(total_cost, work_days.size, 1.0)
      stats[:total_cost] = total_cost
      stats[:total_items] = view.size
      stats[:cost_histogram] = view.cost_histogram
      stats[:view] = view
      return stats
    end    
    
    def pto(&block)
      calendar = Calendar.new('pto')
      calendar.instance_eval &block
      @pto = calendar
      calendar
    end
        
    def email_address
      @email
    end
    
    def email(address)
      @email = address
    end
    
    def self.find_by_name(name)
      Personel.engineers.each {|engineer|
        return engineer if engineer.name == name
      }
      return nil
    end

    def self.find_by_email(email)
      Personel.engineers.each {|engineer|
        return engineer if engineer.email == email
      }
      return nil
    end    
  end  
end

