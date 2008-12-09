require File.dirname(__FILE__) + '/spec_helper'
require 'benchmark'

module Bugzilla
  module Entities
    describe Base do
      before(:each) do
        @time = Time.now
        
        @hash = Hash.new
        @hash['id'] = 1
        @hash['summary'] = "This is a summary"
        @hash['internals'] = Hash.new
        @hash['internals']['isopened'] = 1
        @hash['internals']['bug_status'] = :closed
        @hash['internals']['target_milestone'] = 'Dokken'
        @hash['internals']['version'] = '0.3-Final'
        @hash['internals']['status_whiteboard'] = 'mozbug'
        @hash['internals']['cf_bug_cost_estimate'] = 1
        t = mock()
        t.stubs(:to_time).returns(@time)
        @hash['creation_time'] = t
        t = mock()
        t.stubs(:to_time).returns(@time)
        @hash['last_change_time'] = t
        @base = Base.new
        @base.load_attributes_from_bugzilla_hash(@hash)
      end
      
      it "should map id" do
        @base.id.should == 1
      end

      it "should map summary" do
        @base.summary.should == "This is a summary"
      end

      it "should map boolean opened state" do
        @base.is_opened.should be_true
      end

      it "should map boolean not opened state" do
        @hash['internals']['isopened'] = 0
        @base.load_attributes_from_bugzilla_hash(@hash)
        @base.is_opened.should be_false
      end

      it "should map status" do
        @base.status.should == :closed
      end

      it "should map target milestone" do
        @base.target_milestone.should == 'Dokken'
      end

      it "should map version" do
        @base.version.should == '0.3-Final'
      end

      it "should map whiteboard" do
        @base.whiteboard.should == 'mozbug'
      end

      it "should map cost" do
        @base.cost.should == 1
      end

      it "should map nil cost" do
        @hash['internals']['cf_bug_cost_estimate'] = ''
        @base.load_attributes_from_bugzilla_hash(@hash)
        @base.cost.should == nil
      end

      it "should map cost with extra junk" do
        @hash['internals']['cf_bug_cost_estimate'] = '3+ very hard'
        @base.load_attributes_from_bugzilla_hash(@hash)
        @base.cost.should == 3
      end

      it "should ignore ? in cost" do
        @hash['internals']['cf_bug_cost_estimate'] = '?'
        @base.load_attributes_from_bugzilla_hash(@hash)
        @base.cost.should == nil
      end

      it "should ignore , in cost" do
        @hash['internals']['cf_bug_cost_estimate'] = '2,3'
        @base.load_attributes_from_bugzilla_hash(@hash)
        @base.cost.should == 2
      end

      it "should support double digit cost" do
        @hash['internals']['cf_bug_cost_estimate'] = '45'
        @base.load_attributes_from_bugzilla_hash(@hash)
        @base.cost.should == 45
      end

      it "should map created time" do
        @base.created_on.should == @time
      end

      it "should map motified time" do
        @base.modified_on.should == @time
      end

      it "should find a bug" do
        set = Base.find(7000)
        set.to_a.first.should be_instance_of(Bug)
        set.to_a.first.id.should == 7000
      end  

      it "should find a story" do
        set = Base.find(4030)
        set.to_a.first.should be_instance_of(Story)
        set.to_a.first.id.should == 4030
      end  

      it "should find a task" do
        set = Base.find(4017)
        set.to_a.first.should be_instance_of(Task)
        set.to_a.first.id.should == 4017
      end  

      it "should find a feature" do
        set = Base.find(2244)
        set.to_a.first.should be_instance_of(Feature)
        set.to_a.first.id.should == 2244
      end  

      it "should cache one object" do
        Base.cache.clear
        item = Base.find(7000)
        Base.cache.include?(7000).should be_true      
      end

      it "should cache several objects" do
        Base.cache.clear
        items_cached = Base.find([7000, 4030])
        items_cached.size.should == 2
        Base.cache.include?(7000).should be_true      
        Base.cache.include?(4030).should be_true      
        items = Base.find([7000, 4030, 4017])
        Base.cache.include?(4017).should be_true   
        items.size.should == 3   
      end

      it "should speed things up with cache" do
        Base.cache.clear
        not_cached = Benchmark.realtime() {
          item = Base.find(7000)
        }
        cached = Benchmark.realtime() {
          item = Base.find(7000)
        }
        cached.should < (not_cached / 1000)
      end

      it "should not have cache miss" do
        Base.cache.clear
        Base.cache.statistics[2].should == 0  # Hit
        Base.cache.statistics[3].should == 0  # Miss
        item = Base.find(7000)
        Base.cache.statistics[2].should == 0
        Base.cache.statistics[3].should == 1
        item = Base.find(7000)
        Base.cache.statistics[2].should == 1
        Base.cache.statistics[3].should == 1
        item = Bug.find(7000)
        Base.cache.statistics[2].should == 2
        Base.cache.statistics[3].should == 1
      end
      
      it "should find a set from query" do
        q = mock()
        q.stubs(:to_s).returns("/buglist.cgi?quicksearch=7000,4030")
        q.stubs(:is_static?).returns(true)
        q.stubs(:ids).returns([7000,4030])
        set = Base.find_from_query(q)
        set.size.should == 2
      end

      it "should not get to item that requires loggedin" do
        Base.connector.logout
        q = mock()
        q.stubs(:to_s).returns("/buglist.cgi?quicksearch=6225,7000")
        q.stubs(:is_static?).returns(false)
        set = Base.find_from_query(q)
        set.size.should == 1
      end  

      it "should get to item that requires loggedin" do
        q = mock()
        q.stubs(:to_s).returns("/buglist.cgi?quicksearch=6225,7000")
        q.stubs(:is_static?).returns(false)
        Base.connector.login
        set = Base.find_from_query(q)
        a = Base.find(6225)
        set.size.should == 2
        (set - a).size.should == 1
      end  
      
      it "should compare to each other" do
        a = Base.find(6225)
        b = Base.find(7000)
        a.to_a.first.<=>(b.to_a.first).should == -1
        b.to_a.first.<=>(a.to_a.first).should == 1
        a.to_a.first.<=>(a.to_a.first).should == 0
      end
    end
  end
end
