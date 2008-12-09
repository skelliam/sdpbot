require File.dirname(__FILE__) + '/spec_helper'

module SDP
  describe Calendar do
    before(:all) do
      @calendar = calendar "My Calendar" do
        on '10/8/2008'        
        on '11/24/2007', "Turkey Day"
        on '12/5/2008', "Festivus"
      end
    end

    it "should have a name" do
      @calendar.name == "My Calendar"
    end
    
    it "should create a calendar" do
      @calendar.size.should == 3
      @calendar.should be_include(Date.parse('10/8/2008'))
      @calendar.should be_include(Date.parse('11/24/2007'))
      @calendar.should be_include(Date.parse('12/5/2008'))
    end

    it "dates should have name" do
      @calendar.each {|day|
        day.name.should be_empty if day == Date.parse('10/8/2008')
        day.name.should == "Turkey Day" if day == Date.parse('11/24/2007')
        day.name.should == "Festivus" if day == Date.parse('12/5/2008')
      }
    end
  end
end