require File.dirname(__FILE__) + '/spec_helper'

module SDP
  describe Velocity do
    it "should qualify velocity" do
      Velocity.new(10.0, 10.0).qualify.should == :normal
      Velocity.new(12.0, 10.0).qualify.should == :good
      Velocity.new(7.0, 10.0).qualify.should == :bad
      Velocity.new(3.0, 10.0).qualify.should == :ugly
    end
  end
end