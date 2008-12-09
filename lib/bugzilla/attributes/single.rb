module Bugzilla
  module Attributes
    class Single < String
      include Field
            
      def +(other)
        return self.class.new(super.+(other)) 
      end
    end
  end
end