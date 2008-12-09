require File.dirname(__FILE__) + '/spec_helper'

module Bugzilla
  describe Base do
    it "should throw an exception for method that is supposed to be overriden" do
      lambda {
        Base.find
      }.should raise_error(NotImplementedError)
    end

    it "should throw an exception for method that is supposed to be overriden" do
      o = Base.new
      lambda {
        o.load_attributes_from_bugzilla_hash(nil)
      }.should raise_error(NotImplementedError)
    end

    it "should throw an exception for method that is supposed to be overriden" do
      o = Base.new
      lambda {
        o.load_id_from_bugzilla_hash(nil)
      }.should raise_error(NotImplementedError)
    end
  end
end