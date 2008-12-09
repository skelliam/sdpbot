require File.dirname(__FILE__) + '/spec_helper'

describe Date do
  it "should return week days" do
    s = Date.week_days(Date.parse('12/31/2007'), Date.parse('02/02/2008'))
    s.size.should == 25
    s.should be_include(Date.parse('12/31/2007'))
    s.should be_include(Date.parse('1/1/2008'))
    s.should be_include(Date.parse('2/1/2008'))
  end

  it "should not return last day of interval" do
    s = Date.week_days(Date.parse('1/7/2008'), Date.parse('1/14/2008'))
    s.size.should == 5
    s.should be_include(Date.parse('1/7/2008'))
    s.should_not be_include(Date.parse('1/14/2008'))
  end
end
