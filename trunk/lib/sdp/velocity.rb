require 'delegate'

module SDP
  class Velocity < DelegateClass(Float)
    attr_accessor :target
    
    def initialize(v, target=0.0)
      @target = target
      super(v)
    end
    
    def self.compute(points, days, target=0.0)
      if points.is_a?(Numeric) && days.is_a?(Numeric) && days > 0
        return Velocity.new(points.to_f / days, target)
      else
        return Velocity.new(0.0, target)
      end
    end
        
    # Return a qualifier for this velocity based on target
    def qualify
      unless @target == 0
        r = self / @target 
      else
        return :normal
      end
      return :good  if r >= 1.2
      return :ugly  if r <= 0.3
      return :bad   if r <= 0.7
      return :normal  
    end    
  end
end