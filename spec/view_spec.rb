require File.dirname(__FILE__) + '/spec_helper'

module Bugzilla
  describe View do
    before(:all) do
      @view = View.from_ids([5618, 7007])
      @same = View.from_ids([5618, 7007])
      @subset = View.from_ids([5000, 7007])
      @superset = View.from_ids([5000, 5618, 7007, 7008])
      @different = View.from_ids([5619, 7008])
      @cost_missing = View.from_ids([5000, 5001, 5005])
    end
      
    it "should have a bugzilla url" do
      @view.bugzilla_url.should == "http://bugzilla.songbirdnest.com/buglist.cgi?order=bugs.bug_id&quicksearch=5618,7007"
    end
    
    it "should total cost" do
      @view.total_cost.should == 3
    end

    it "should know when cost is missing" do
      @cost_missing.cost_missing?.should be_true
    end

    it "should raise an exception when cost is missing" do
      lambda {
        @cost_missing.total_cost        
      }.should raise_error(View::CostMissingException)
    end

    it "should return element that are missing cost" do
      begin
        @cost_missing.total_cost        
      rescue View::CostMissingException => e
         e.view.size.should == 1
         e.view.should == View.from_ids([5005])
         e.partial_cost.should == 2
      end
    end

    it "should return bugzilla static query" do
      @view.to_query.to_s.should == '/buglist.cgi?order=bugs.bug_id&quicksearch=5618,7007'
    end

    it "should create from query" do
      q = mock()
      q.stubs(:to_s).returns("/buglist.cgi?quicksearch=7007,5618")
      q.stubs(:is_static?).returns(true)
      q.stubs(:ids).returns([7007,5618])

      v = View.from_query(q)
      v.to_query.to_s.should == '/buglist.cgi?order=bugs.bug_id&quicksearch=5618,7007'
    end

    it "should create from ids" do
      q = mock()
      q.stubs(:to_s).returns("/buglist.cgi?quicksearch=7007,5618")
      Query.stubs(:static).times(1).with([5618, 7007]).returns(q)
      Query.stubs(:static).times(1).with([7007, 5618]).returns(q)
      q.stubs(:is_static?).returns(true)
      q.stubs(:ids).returns([7007,5618])

      v = View.from_ids([7007,5618])
      v.to_query.to_s.should == '/buglist.cgi?quicksearch=7007,5618'
    end
   
    it "should refresh" do
      q = mock()
      q.stubs(:to_s).returns("/buglist.cgi?quicksearch=7007,5618")
      Query.stubs(:static).times(2).with([5618, 7007]).returns(q)
      Query.stubs(:static).times(1).with([7007, 5618]).returns(q)
      q.stubs(:is_static?).returns(true)
      q.stubs(:ids).returns([7007,5618])

      v = View.from_ids([7007,5618])
      v.refresh
      v.to_query.to_s.should == '/buglist.cgi?quicksearch=7007,5618'
    end
    
    it "should substract cost for 2 complete views" do
      item_cost_1 = mock()
      item_cost_1.stubs(:cost).returns(1)
      item_cost_2 = mock()
      item_cost_2.stubs(:cost).returns(2)
      item_cost_3 = mock()
      item_cost_3.stubs(:cost).returns(3)
      item_cost_nil = mock()
      item_cost_nil.stubs(:cost).returns(nil)
      
      v1 = View.new([item_cost_1, item_cost_2])
      v2 = View.new([item_cost_3, item_cost_1])
      lambda {
        @total = v1.substract_cost_from(v2)        
      }.should_not raise_error(View::CostMissingException)
      @total.should == -1
    end

    it "should substract cost from 1 incomplete views" do
      item_cost_1 = mock()
      item_cost_1.stubs(:cost).returns(1)
      item_cost_2 = mock()
      item_cost_2.stubs(:cost).returns(2)
      item_cost_3 = mock()
      item_cost_3.stubs(:cost).returns(3)
      item_cost_nil = mock()
      item_cost_nil.stubs(:cost).returns(nil)
      
      v1 = View.new([item_cost_1, item_cost_nil])
      v2 = View.new([item_cost_3, item_cost_1])
      lambda {
        v1.substract_cost_from(v2)        
      }.should raise_error(View::CostMissingException)
      begin
        v1.substract_cost_from(v2)        
      rescue View::CostMissingException => e
        e.partial_cost.should == -3
        e.view.size.should == 1
      end
    end

    it "should substract cost with 1 incomplete views" do
      item_cost_1 = mock()
      item_cost_1.stubs(:cost).returns(1)
      item_cost_2 = mock()
      item_cost_2.stubs(:cost).returns(2)
      item_cost_3 = mock()
      item_cost_3.stubs(:cost).returns(3)
      item_cost_nil = mock()
      item_cost_nil.stubs(:cost).returns(nil)
      
      v1 = View.new([item_cost_2, item_cost_3])
      v2 = View.new([item_cost_3, item_cost_nil])
      lambda {
        v1.substract_cost_from(v2)        
      }.should raise_error(View::CostMissingException)
      begin
        v1.substract_cost_from(v2)        
      rescue View::CostMissingException => e
        e.partial_cost.should == 2
        e.view.size.should == 1
      end
    end
  
    it "should substract cost from both incomplete views" do
      item_cost_1 = mock()
      item_cost_1.stubs(:cost).returns(1)
      item_cost_2 = mock()
      item_cost_2.stubs(:cost).returns(2)
      item_cost_3 = mock()
      item_cost_3.stubs(:cost).returns(3)
      item_cost_nil1 = mock()
      item_cost_nil1.stubs(:cost).returns(nil)
      item_cost_nil2 = mock()
      item_cost_nil2.stubs(:cost).returns(nil)
      
      v1 = View.new([item_cost_2, item_cost_nil1])
      v2 = View.new([item_cost_3, item_cost_nil2])
      lambda {
        v1.substract_cost_from(v2)        
      }.should raise_error(View::CostMissingException)
      begin
        v1.substract_cost_from(v2)        
      rescue View::CostMissingException => e
        e.partial_cost.should == -1
        e.view.size.should == 2
      end
    end

    it "should compute a cost histogram" do
      item_cost_1 = mock()
      item_cost_1.stubs(:cost).returns(1)
      item_cost_2 = mock()
      item_cost_2.stubs(:cost).returns(2)
      item_cost_3 = mock()
      item_cost_3.stubs(:cost).returns(3)
      item_cost_nil = mock()
      item_cost_nil.stubs(:cost).returns(nil)
      
      v = View.new([item_cost_1, item_cost_2, item_cost_3, item_cost_nil])
      h = v.cost_histogram
      
      h[:cost_1][:count].should == 1
      h[:cost_1][:percentage].should == 25
      h[:cost_2][:count].should == 1
      h[:cost_2][:percentage].should == 25
      h[:cost_3][:count].should == 1
      h[:cost_3][:percentage].should == 25
      h[:unknown][:count].should == 1
      h[:unknown][:percentage].should == 25
    end
    
    it "should detect identity" do
      @view.should == @same
    end

    it "should return complement with same" do
      @result = @view - @same
      @result.size.should == 0
    end

    it "should return complement with subset" do
      @result = @view - @subset
      @result.should == View.from_ids([5618])
    end

    it "should return complement with superset" do
      @result = @view - @superset
      @result.size.should == 0
    end

    it "should return complement with different" do
      @result = @view - @different
      @result.should == @view
    end

    it "should return union with same" do
      @result = @view + @same
      @result.should == @view
    end

    it "should return union with subset" do
      @result = @view + @subset
      @result.should == View.from_ids([5618, 7007, 5000])
    end

    it "should return union with superset" do
      @result = @view + @superset
      @result.should == @superset
    end

    it "should return union with different" do
      @result = @view + @different
      @result.should == View.from_ids([5618, 7007, 5619, 7008])
    end
    
    it "should serialize to yaml" do
yaml=<<EOY
--- !songbirdnest.com,2008-01/Bugzilla::View 
created_on: 2008-10-01 00:00:01 -0700
query: /buglist.cgi?order=bugs.bug_id&quicksearch=5618,7007
EOY
      Time.stubs(:now).returns(Time.parse('2008-10-01 00:00:01'))
      @view = View.from_ids([5618, 7007])      
      @view.to_yaml.should == yaml
    end
    
    it "should have items cached" do
      cache = Entities::Base.cache
      Entities::Base.cache.clear
      Entities::Base.cache.statistics[2].should == 0  # Hit
      Entities::Base.cache.statistics[3].should == 0  # Miss
      
      View.from_query(Query.all('Cosmo'))

      hit = Entities::Base.cache.statistics[2]  # Hit
      miss = Entities::Base.cache.statistics[3] # Miss
      
      hit.should == 0
      
      view = View.from_query(Query.open('Cosmo'))

      Entities::Base.cache.statistics[3].should == miss
      view.size.should == Entities::Base.cache.statistics[2]  # Hit
    end
    
  end
end