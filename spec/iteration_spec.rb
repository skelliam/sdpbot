require File.dirname(__FILE__) + '/spec_helper'
require 'set'

module SDP
  describe Iteration do
    before(:all) do
      @release = mock()
      @release.stubs(:name).returns(:name)
      @release.stubs(:products).returns(Array.new)
      @release.stubs(:planned_lock_down_offset).returns(12*60*60)
      @iteration = Iteration.new(@release, 1, Date.parse('1/31/2008'), Date.parse('2/07/2008'))
      @iteration.remaining_at_start = Set.new [1,2,3]
      @iteration.remaining_at_end = Set.new [3,4]
      @iteration.completed = Set.new [1,5]      
      @iteration.carry_over = Set.new [3,4]
      
      # Stub views to manipulate cost
      @a = Array.new
      for i in (1..10)
        @a[i] = mock()
        @a[i].stubs(:id).returns(i)
        @a[i].stubs(:cost).returns(i)
      end
    end
  
    it "should compute added" do
      @iteration.added.should == Set.new([4,5])
    end

    it "should compute removed" do
      @iteration.removed.should == Set.new([2])
    end

    it "should compute changed" do
      @iteration.changed.should == Set.new([2,4,5])
    end
    
    it "should serialize to yaml" do
      @iteration.to_yaml.should be_an_instance_of(String)
    end	      

    it "should compute intake net cost" do
      iteration = Iteration.new(@release, 1, Date.parse('1/11/2008'), Date.parse('1/17/2008'))
      
      iteration.remaining_at_start = View.new(Array.[](@a[1], @a[2], @a[3]))
      iteration.remaining_at_end = View.new(Array.[](@a[3], @a[4]))
      iteration.completed = View.new(Array.[](@a[1], @a[5]))
      iteration.carry_over = View.new(Array.[](@a[3], @a[4]))
      
      iteration.changed_net_cost.should == 7
    end    

    it "should compute length" do
      iteration = Iteration.new(@release, 1, Date.parse('1/2/2008'), Date.parse('1/3/2008'))
      iteration.length.should == 1
    end

    it "should compute length and take into accunt week-ends" do
      iteration = Iteration.new(@release, 1, Date.parse('1/2/2008'), Date.parse('1/7/2008'))
      iteration.length.should == 3
    end
    
    it "should compute velocity" do
      iteration = Iteration.new(@release, 1, Date.parse('1/2/2008'), Date.parse('1/3/2008'))
      iteration.completed = View.new(Array.[](@a[1], @a[2], @a[3]))
      iteration.velocity.should == 6
    end

    it "should compute velocity and take into account week-ends" do
      iteration = Iteration.new(@release, 1, Date.parse('1/2/2008'), Date.parse('1/7/2008'))
      iteration.completed = View.new(Array.[](@a[1], @a[2], @a[3]))
      iteration.velocity.should == 2
    end

    it "should compute velocity and take into account holidays" do
      iteration = Iteration.new(@release, 1, Date.parse('1/1/2008'), Date.parse('1/7/2008'))
      iteration.completed = View.new(Array.[](@a[1], @a[2], @a[3]))
      iteration.velocity.should == 2
    end

    it "should compute intake velocity" do
      iteration = Iteration.new(@release, 1, Date.parse('1/2/2008'), Date.parse('1/3/2008'))
      iteration.remaining_at_start = View.new(Array.[](@a[1], @a[2]))
      iteration.remaining_at_end = View.new(Array.[](@a[2], @a[3]))
      iteration.completed = View.new(Array.[](@a[1]))
      iteration.changed_velocity.should == 3.0
    end

    it "should not have plan locked" do
      iteration = Iteration.new(@release, 1, Date.parse('1/2/2008'), Date.parse('1/3/2008'))
      iteration.plan_locked?.should be_false
    end

    it "should not be able to lock plan" do
      iteration = Iteration.new(@release, 1, Date.parse('1/2/2008'), Date.parse('1/3/2008'))
      iteration.plan_locked?.should be_false
      iteration.snapshot_plan!
      iteration.plan_locked?.should be_true
    end
  end

  describe "Iteration lifecyle" do
    before(:all) do      
      @release = mock()
      @release.stubs(:name).returns(:name)
      @release.stubs(:products).returns(Array.new)
      @release.stubs(:planned_lock_down_offset).returns(12*60*60)
      
      @iteration = Iteration.new(@release, 1, Date.parse('1/31/2008'), Date.parse('2/07/2008'))
    end

    it "should track nothing before started" do
      Date.stubs(:today).returns(Date.parse('1/1/2008'))
      Time.stubs(:now).returns(Time.parse(Date.today.to_s))
      
      @iteration.track
      @iteration.started?.should be_false
      @iteration.remaining_at_start.should be_nil
      @iteration.remaining_at_end.should be_nil
      @iteration.carry_over.should be_nil
      @iteration.completed.should be_nil
      @iteration.planned.should be_nil
    end    

    it "should track remaining at start upon starting" do
      Query.expects(:open).times(2).returns(:open_view_at_start)
      View.expects(:from_query).with(:open_view_at_start).times(2).returns(:open_view_at_start)
      Query.expects(:planned).returns(:planned_now)
      View.expects(:from_query).with(:planned_now).returns(:planned_now)

      Date.stubs(:today).returns(Date.parse('1/31/2008'))
      Time.stubs(:now).returns(Time.parse(Date.today.to_s))
      
      @iteration.track
      @iteration.started?.should be_true
      @iteration.remaining_at_start.should == :open_view_at_start
      @iteration.planned.should == :planned_now
      @iteration.remaining_at_end.should be_nil
      @iteration.carry_over.should be_nil
      @iteration.completed.should be_nil
      @iteration.plan_locked?.should be_false
    end    

    it "should track planned once planned lock down occured" do
      Query.expects(:planned).returns(:planned_now)
      View.expects(:from_query).with(:planned_now).returns(:planned_now)
      Date.stubs(:today).returns(Date.parse('1/31/2008'))
      Time.stubs(:now).returns(Time.parse('1/31/2008 12:00:00 -08:00'))
      
      @iteration.snapshot_plan!
      
      @iteration.track
      @iteration.started?.should be_true
      @iteration.remaining_at_start.should == :open_view_at_start
      @iteration.planned.should == :planned_now
      @iteration.remaining_at_end.should be_nil
      @iteration.carry_over.should be_nil
      @iteration.completed.should be_nil
      @iteration.plan_locked?.should be_true
    end    

    it "should not track remaining once started" do
      Query.expects(:open).never
      View.expects(:from_query).never
      Date.stubs(:today).returns(Date.parse('1/31/2008'))
      Time.stubs(:now).returns(Time.parse(Date.today.to_s))

      @iteration.track
      @iteration.started?.should be_true
      @iteration.remaining_at_start.should == :open_view_at_start
      @iteration.planned.should == :planned_now      
      @iteration.remaining_at_end.should be_nil
      @iteration.carry_over.should be_nil
      @iteration.completed.should be_nil
    end    

    it "should track all at end once ended" do
      Query.expects(:open).times(2).returns(:open_view_at_end)
      View.expects(:from_query).times(2).with(:open_view_at_end).returns(:open_view_at_end)
      Query.expects(:carried_over).returns(:carried_over_at_end)
      View.expects(:from_query).with(:carried_over_at_end).returns(:carried_over_at_end)
      Query.expects(:completed).times(2).returns(:completed)  
      View.expects(:from_query).with(:completed).times(2).returns(:completed)
      Date.stubs(:today).returns(Date.parse('2/07/2008'))
      Time.stubs(:now).returns(Time.parse(Date.today.to_s))

      @iteration.track
      @iteration.started?.should be_false
      @iteration.ended?.should be_true

      @iteration.remaining_at_start.should == :open_view_at_start
      @iteration.planned.should == :planned_now      
      @iteration.remaining_at_end.should == :open_view_at_end
      @iteration.carry_over.should == :carried_over_at_end
      @iteration.completed.should == :completed
    end    

    it "should track nothing once ended" do
      Date.stubs(:today).returns(Date.parse('2/08/2008'))
      Time.stubs(:now).returns(Time.parse(Date.today.to_s))

      @iteration.track
    end
  end  
end