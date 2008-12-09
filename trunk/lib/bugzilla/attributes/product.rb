module Bugzilla
  module Attributes
    class Product < MultiSelect
      include Searchable
      named "product"
      with_choices %w( Songbird Website )    
    end
  end
end