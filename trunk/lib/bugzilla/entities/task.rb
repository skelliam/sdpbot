module Bugzilla
  module Entities
    class Task < Base
      class << self
        def bz_type
          'Task'
        end
      end
      
      def to_s
        "T#{super.to_s}"          
      end        
    end
  end
end