module Bugzilla
  module Entities
    class Bug < Base
      class << self
        def bz_type
          'Bug'
        end
      end
      def to_s
        "B#{super.to_s}"          
      end        
    end
  end
end