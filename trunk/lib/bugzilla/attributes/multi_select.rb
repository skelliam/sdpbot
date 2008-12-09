module Bugzilla
  module Attributes
    class MultiSelect < Array
      include Field
          
      # Return union of values
      def |(other)
        return self.class.new(super.|(other)) 
      end
    end
  end
end