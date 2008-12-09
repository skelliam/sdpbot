module Bugzilla
  module Attributes
    describe 'Field', :shared => true do      
      it "should return no search query" do
        @klass.new.to_search_query.should == ""
      end

      it "should have a class method for each choices" do
        @klass.choices.each {|choice|
          @klass.send(choice.to_sym).should be_is_a(@klass)
        }
      end

      it "should have class method unspecified choice" do
        @klass.unspecified.should be_is_a(@klass)
      end

      it "should return a search query" do
        term = @klass.choices.first
        attribute = @klass.new << term
        if @klass.prefix.nil?
          attribute.to_search_query.should == "&#{@klass.field_name}=#{term}"
        else
          attribute.to_search_query.should == "&#{@klass.prefix}&#{@klass.field_name}=#{term}"
        end
      end

      it "should add conversion method to strings" do
        String.instance_methods.should be_include("to_#{@klass.simple_name.snake_case}")
      end

      it "should convert strings to class" do
        attribute = @klass.choices.last.send("to_#{@klass.simple_name.snake_case}".to_sym)
        attribute.should be_is_a(@klass)
        @klass.send(@klass.choices.last.to_sym).should == attribute
      end      
    end
  end
end