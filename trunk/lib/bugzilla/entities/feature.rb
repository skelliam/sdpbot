module Bugzilla
  module Entities
    class Feature < Base
      class << self
        def bz_type
          'Feature'
        end
      end
      
      def to_s
        "F#{super.to_s}"          
      end        
    end
  end
end