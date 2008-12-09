require File.dirname(__FILE__) + '/spec_helper'

module Bugzilla
  describe Bugzilla do
    before(:each) do
      @bugzilla = Bugzilla.new
    end
      
    it "should login" do
      @bugzilla.login
      @bugzilla.logged_in?.should be_true
    end

    it "should logout" do
      @bugzilla.login
      @bugzilla.logged_in?.should be_true
      @bugzilla.logout
      @bugzilla.logged_in?.should be_false
    end    
  end
end