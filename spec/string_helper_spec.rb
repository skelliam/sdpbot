require File.dirname(__FILE__) + '/spec_helper'

describe String do
  before(:all) do
    @a = "0123\n456\n"
    @b = "0123\n456 \n"    
  end
  it "should returng diff" do
    @a.diff(@b).should == "1:456\n1:456 \n"
  end
end