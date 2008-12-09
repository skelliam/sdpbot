require File.dirname(__FILE__) + '/spec_helper'

module SDP
  describe Engineer do
    before(:all) do
      @engineer = Engineer.new("Bob", "bob@songbirdnest.com")
    end
    
    it "should return stats" do
      view = Array.new
      view.stubs(:total_cost).returns(12)
      view.stubs(:cost_histogram).returns(:cost_histogram)

      item = mock()
      item.stubs(:cost).returns(1)
      view.push item
      item = mock()
      item.stubs(:cost).returns(2)
      view.push item
      item = mock()
      item.stubs(:cost).returns(3)
      view.push item
      item = mock()
      item.stubs(:cost).returns(3)
      view.push item
      item = mock()
      item.stubs(:cost).returns(2)
      view.push item
      item = mock()
      item.stubs(:cost).returns(1)
      view.push item
      item = mock()
      item.stubs(:cost).returns(nil)
      view.push item
      
      Query.expects(:fixed_by).returns(:fixed_by_view)
      View.expects(:from_query).with(:fixed_by_view).returns(view)
      
      stats = @engineer.stats(Date.parse('12/31/2007'), Date.parse('02/01/2008'))
      stats[:work_days].should == 22
      stats[:velocity].decimal.should == 0.54
      stats[:total_cost].should == 12
      stats[:total_items].should == 7
      stats[:cost_histogram].should == :cost_histogram  
    end    
  end
end