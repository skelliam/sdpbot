module Bugzilla
  module Attributes
    class TargetMilestone < MultiSelect
      include Searchable
      named "target_milestone"
      with_choices %w( --- Cher Dokken Eno Fugazi Future Bourbon Cosmo Daiquiri )    
    end
  end
end