require 'time'

module SDP
  # Represent one iteration of a release cycle.
  class Iteration < Project
    attr_accessor :release
    attr_accessor :number

    attr_accessor :completed
    attr_accessor :carry_over
    attr_accessor :planned
    attr_accessor :plan_locked_on
    attr_accessor :remaining_at_start
    attr_accessor :remaining_at_end

    attr_accessor :asap_remaining_at_start
    attr_accessor :asap_remaining_at_end
    attr_accessor :asap_completed    
    
    def initialize(release, number, start_date, end_date)
      @release = release
      @number = number
      super(start_date, end_date)
    end
    
    def name
      @release.name
    end
    
    def products
      @release.products
    end
    
    # Return a view of planned items as of now
    def planned_now
      q = Query.planned(name, {:products => products})
      View.from_query(q)
    end

    # Return a view of items carried over as of now    
    def carry_over_now
      q = Query.carried_over(name, {:products => products})
      View.from_query(q)
    end
    
    # Return a view of the number of items added during the iteration
    def added
      (@remaining_at_end + @completed) - @remaining_at_start unless @remaining_at_end.nil? || @completed.nil? || @remaining_at_start.nil?
    end

    # Return a view of the number of items removed during the iteration
    def removed
      @remaining_at_start - (@remaining_at_end + @completed) unless @remaining_at_end.nil? || @completed.nil? || @remaining_at_start.nil?
    end

    # Return a view of the number of items changed (union of added and removed) during the iteration
    def changed
      return added + removed unless added.nil? || removed.nil?
      return added unless added.nil?
      return removed unless removed.nil?
    end

    # Net change of cost. Can be negative if more items were removed
    def changed_net_cost
      unless added.nil?
        return added.substract_cost_from(removed)
      else
        return removed.total_cost unless removed.nil?
      end
    end
    
    # Return iteration length in working days
    def length
      (Date.week_days(@start_date, @end_date) - Personel.holidays).size
    end
    
    # Compute the velocity for this iteration
    def velocity
      v = compute_velocity(completed) {|view| view.total_cost}
      v.target = planned_velocity
      return v
    end

    # Compute the planned velocity for this iteration
    def planned_velocity
      return compute_velocity(planned) {|view| view.total_cost}
    end
    
    # Compute the velocity of change for this iteration
    def changed_velocity
      return compute_velocity(changed) {|view| changed_net_cost}
    end
        
    # Track iteration progress. This will snapshot any queries needed based on the time it's invoked.
    # It should be called periodically.
    def track
      if started?
        if @remaining_at_start.nil?
          @remaining_at_start = remaining_now
        end
        if @asap_remaining_at_start.nil?
          @asap_remaining_at_start = asap_remaining_now
        end

        if @planned.nil? || !plan_locked?
          @planned = planned_now
        end
      end
      
      if ended?
        if @remaining_at_end.nil?
          @remaining_at_end = remaining_now
        end
        if @completed.nil?
          @completed = completed_now
        end
        if @carry_over.nil?
          @carry_over = carry_over_now
        end
        if @asap_remaining_at_end.nil?
          @asap_remaining_at_end = asap_remaining_now
        end
        if @asap_completed.nil?
          @asap_completed = asap_completed_now
        end
      end
    end
    
    def snapshot_plan!
      @planned = planned_now
      @plan_locked_on = Time.now.strftime("%Y-%m-%d %H:%M:%S %z")     
    end
    
    def refresh_plan!
      @planned = planned_now
    end
    
    def plan_locked?
      !@plan_locked_on.nil?
    end
    
    # Return a wiki url for this iteration
    def wiki_url
      "https://hq.songbirdnest.com/wiki/index.php?title=Release:#{name}_Iteration_Notes#Iteration_#{@number}"
    end
    
    def to_yaml_properties #:nodoc:
      super + ["@number", "@remaining_at_start", "@plan_locked_on", "@planned", "@asap_remaining_at_start", "@remaining_at_end", "@completed", "@carry_over", "@asap_remaining_at_end", "@asap_completed"]
    end
    
    def to_s #:nodoc:
      s =  "Iteration #{@number} [#{@start_date} / #{@end_date}]\n"      
      s += "  Total remaining at start: #{@remaining_at_start.total_cost} pts (#{@remaining_at_start.size} items)\n" unless @remaining_at_start.nil?
      s += "  Completed: #{@completed.total_cost} pts (#{@completed.size} items)\n" unless @completed.nil?
      s += "  Added: #{added.total_cost} pts (#{added.size} items)\n" unless added.nil?
      s += "  Removed: #{removed.total_cost} pts (#{removed.size} items)\n" unless removed.nil?
      s += "  Intake: #{changed_net_cost} pts (#{changed.size} items)\n" unless changed.nil?
      s += "  Carry over: #{@carry_over.total_cost} pts (#{@carry_over.size} items)\n" unless @carry_over.nil?
      s += "  Total remaining at end: #{@remaining_at_end.total_cost} pts (#{@remaining_at_end.size} items)\n" unless @remaining_at_end.nil?
      s
    end   
    
    private
    def compute_velocity(view, &block)
      v = Velocity.new(0.0)
      unless view.nil?
        begin
          cost = yield(view)
        rescue View::CostMissingException => e
          cost = e.partial_cost
        end
        v = Velocity.compute(cost, length)
      end
      return v
    end 
  end
end