require File.dirname(__FILE__) + '/spec_helper'

module SDP
  describe Releases do
    before(:all) do
      @r = Releases.instance
    end
    
    it "should find release name regardless of capitalization" do
      @r[:mykey] = true
      @r.find("mykey").should be_true
      @r.find("MyKey").should be_true
      @r.find(:mykey).should be_true
      @r.delete(:mykey)
    end

    it "should load releases" do
      @r.load
    end

    it "should track releases" do
      @r.track_all
    end

    it "should save releases" do
      @r.save
    end
  end
end