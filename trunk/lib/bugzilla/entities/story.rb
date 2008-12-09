module Bugzilla
  module Entities
    class Story < Base
      class << self
        def bz_type
          'Story'
        end
      end

      def to_s
        "S#{super.to_s}"          
      end  
    end
  end
end