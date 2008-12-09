require File.dirname(__FILE__) + '/spec_helper'

module SDP
  describe Personel do
    before(:all) do
      holidays "My Holidays" do
          on '1/1/2007', "New years"
      end
    end
    
    it "should return holidays" do
      Personel.holidays.size.should == 1
    end
  end
end