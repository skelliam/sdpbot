module Bugzilla
  module Attributes
    class Status < MultiSelect
      include Searchable
      named "bug_status"
      with_choices %w( UNCONFIRMED NEW ASSIGNED REOPENED RESOLVED VERIFIED CLOSED )    
    end
  end
end