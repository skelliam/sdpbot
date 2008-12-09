require File.dirname(__FILE__) + '/field_spec'

module Bugzilla
  module Attributes
    describe 'MultiSelect', :shared => true do
      it_should_behave_like 'Field'

      it "should support multiple choices" do
        s = ""
        @klass.choices.each {|choice|
          s += choice.send("to_#{@klass.simple_name.snake_case}".to_sym).to_search_query
        }
        @klass.all.to_search_query.should == s        
      end
    end
  end
end