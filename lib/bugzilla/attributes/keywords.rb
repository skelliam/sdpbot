module Bugzilla
  module Attributes
    class Keywords < Single
      include Searchable
      named "keywords"
      prefixed_by "keywords_type=anywords"
      i=1
      with_choices Array.new(10).collect {|item| 
        i+=1
        "iteration#{i}"
      }    
    end
  end
end
