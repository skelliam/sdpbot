module Bugzilla
  module Attributes
    class Priority < MultiSelect
      include Searchable
      named "priority"
      with_choices %w(--- P1 P2 P3 P4)    
    end
  end
end
