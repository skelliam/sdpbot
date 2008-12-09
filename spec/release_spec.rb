require File.dirname(__FILE__) + '/spec_helper'

module SDP
  describe Release do
    before(:all) do
      @a = Array.new
      for i in (1..10)
        @a[i] = mock()
        @a[i].stubs(:<=>).returns(1)
        @a[i].stubs(:id).returns(i)
        @a[i].stubs(:cost).returns(i)
      end

      @release = Release.new("MyRelease", Date.parse('1/28/2008'), Date.parse('2/11/2008'))
      @release.planned_lock_down_offset = 0
    end

    it "should persist to yaml" do
yaml =<<EOY
--- !ruby/object:SDP::Release 
name: MyRelease
start_date: 2008-01-28
end_date: 2008-02-11
updated_on: 2008-01-27 00:00:00 -0800
products: 
iteration_length: 7
iterations: []

EOY
      Time.stubs(:now).returns(Time.parse('2008-01-27 00:00:00'))      
      @release.track
      @release.to_yaml.should == yaml
    end

    it "should persist to yaml during first iteration" do
yaml = <<EOY
--- !ruby/object:SDP::Release 
name: MyRelease
start_date: 2008-01-28
end_date: 2008-02-11
updated_on: 2008-01-28 00:00:00 -0800
products: 
iteration_length: 7
iterations: 
- !ruby/object:SDP::Iteration 
  start_date: 2008-01-28
  end_date: 2008-02-04
  number: 1
  remaining_at_start: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-01-28 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1,2,3
  plan_locked_on: 
  planned: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-01-28 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1
  asap_remaining_at_start: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-01-28 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1,2,3
  remaining_at_end: 
  completed: 
  carry_over: 
  asap_remaining_at_end: 
  asap_completed: 
EOY
      Date.stubs(:today).returns(Date.parse('1/28/2008'))
      Time.stubs(:now).returns(Time.parse(Date.today.to_s))

      Query.expects(:carried_over).never
      Query.expects(:completed).never   

      Query.expects(:open).times(3).returns(:open1, :open2, :open3)      
      View.expects(:from_query).times(1).with(:open1).returns(View.new(Array.[](@a[1], @a[2], @a[3])))
      View.expects(:from_query).times(1).with(:open2).returns(View.new(Array.[](@a[1], @a[2], @a[3])))
      View.expects(:from_query).times(1).with(:open3).returns(View.new(Array.[](@a[1], @a[2], @a[3])))

      Query.expects(:planned).returns(:planned)      
      View.expects(:from_query).times(1).with(:planned).returns(View.new(Array.[](@a[1])))

      @release.track
      @release.to_yaml.should == yaml
   end

   it "should persist to yaml after first iteration" do
yaml =<<EOY
--- !ruby/object:SDP::Release 
name: MyRelease
start_date: 2008-01-28
end_date: 2008-02-11
updated_on: 2008-02-05 00:00:00 -0800
products: 
iteration_length: 7
iterations: 
- !ruby/object:SDP::Iteration 
  start_date: 2008-01-28
  end_date: 2008-02-04
  number: 1
  remaining_at_start: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-01-28 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1,2,3
  plan_locked_on: 
  planned: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-01-28 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1
  asap_remaining_at_start: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-01-28 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1,2,3
  remaining_at_end: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-05 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=3,4,5
  completed: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-05 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1,2
  carry_over: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-05 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=3
  asap_remaining_at_end: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-05 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=3,4,5
  asap_completed: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-05 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1,2
- !ruby/object:SDP::Iteration 
  start_date: 2008-02-05
  end_date: 2008-02-12
  number: 2
  remaining_at_start: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-05 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=3,4,5
  plan_locked_on: 
  planned: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-05 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1
  asap_remaining_at_start: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-05 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=3,4,5
  remaining_at_end: 
  completed: 
  carry_over: 
  asap_remaining_at_end: 
  asap_completed: 
EOY
    Date.stubs(:today).returns(Date.parse('2/5/2008'))
    Time.stubs(:now).returns(Time.parse(Date.today.to_s))


    Query.expects(:carried_over).returns(:carried_over)
    View.expects(:from_query).with(:carried_over).returns(View.new(Array.[](@a[3])))

    Query.expects(:completed).times(2).returns(:completed1, :completed2)
    View.expects(:from_query).times(1).with(:completed1).returns(View.new(Array.[](@a[1], @a[2])))
    View.expects(:from_query).times(1).with(:completed2).returns(View.new(Array.[](@a[1], @a[2])))

    Query.expects(:open).times(5).returns(:open1, :open2, :open3, :open4, :open5)      
    View.expects(:from_query).times(1).with(:open1).returns(View.new(Array.[](@a[3], @a[4], @a[5])))
    View.expects(:from_query).times(1).with(:open2).returns(View.new(Array.[](@a[3], @a[4], @a[5])))
    View.expects(:from_query).times(1).with(:open3).returns(View.new(Array.[](@a[3], @a[4], @a[5])))
    View.expects(:from_query).times(1).with(:open4).returns(View.new(Array.[](@a[3], @a[4], @a[5])))
    View.expects(:from_query).times(1).with(:open5).returns(View.new(Array.[](@a[3], @a[4], @a[5])))

    Query.expects(:planned).returns(:planned)      
    View.expects(:from_query).times(1).with(:planned).returns(View.new(Array.[](@a[1])))

    @release.track
    
    @release.to_yaml.should == yaml
  end

   it "should persist to yaml at the end of the project" do
yaml =<<EOY
--- !ruby/object:SDP::Release 
name: MyRelease
start_date: 2008-01-28
end_date: 2008-02-11
updated_on: 2008-02-13 00:00:00 -0800
products: 
iteration_length: 7
iterations: 
- !ruby/object:SDP::Iteration 
  start_date: 2008-01-28
  end_date: 2008-02-04
  number: 1
  remaining_at_start: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-01-28 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1,2,3
  plan_locked_on: 
  planned: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-01-28 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1
  asap_remaining_at_start: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-01-28 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1,2,3
  remaining_at_end: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-05 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=3,4,5
  completed: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-05 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1,2
  carry_over: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-05 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=3
  asap_remaining_at_end: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-05 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=3,4,5
  asap_completed: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-05 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1,2
- !ruby/object:SDP::Iteration 
  start_date: 2008-02-05
  end_date: 2008-02-12
  number: 2
  remaining_at_start: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-05 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=3,4,5
  plan_locked_on: 
  planned: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-05 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1
  asap_remaining_at_start: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-05 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=3,4,5
  remaining_at_end: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-13 00:00:00 -0800
    query: 
  completed: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-13 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1,2
  carry_over: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-13 00:00:00 -0800
    query: 
  asap_remaining_at_end: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-13 00:00:00 -0800
    query: 
  asap_completed: !songbirdnest.com,2008-01/Bugzilla::View 
    created_on: 2008-02-13 00:00:00 -0800
    query: /buglist.cgi?order=bugs.bug_id&quicksearch=1,2
EOY
       Date.stubs(:today).returns(Date.parse('2/13/2008'))
       Time.stubs(:now).returns(Time.parse(Date.today.to_s))

       Query.expects(:carried_over).returns(:carried_over)
       View.expects(:from_query).with(:carried_over).returns(View.new(Array.[]()))

       Query.expects(:completed).times(2).returns(:completed1, :completed2)
       View.expects(:from_query).times(1).with(:completed1).returns(View.new(Array.[](@a[1], @a[2])))
       View.expects(:from_query).times(1).with(:completed2).returns(View.new(Array.[](@a[1], @a[2])))

       Query.expects(:open).times(3).returns(:open1, :open2, :open3)      
       View.expects(:from_query).times(1).with(:open1).returns(View.new(Array.[]()))
       View.expects(:from_query).times(1).with(:open2).returns(View.new(Array.[]()))
       View.expects(:from_query).times(1).with(:open3).returns(View.new(Array.[]()))

       @release.track

       @release.to_yaml.should == yaml
    end
  end
  
  
  describe "Release lifecycle" do
    before(:all) do
      @a = Array.new
      for i in (1..10)
        @a[i] = mock()
        @a[i].stubs(:<=>).returns(1)
        @a[i].stubs(:id).returns(i)
        @a[i].stubs(:cost).returns(i)
      end
      
      @release = Release.new("MyRelease", Date.parse('1/28/2008'), Date.parse('2/11/2008'))
    end
    
    it "should do nothing before started" do
      Date.stubs(:today).returns(Date.parse('1/1/2008'))
      @release.track
    end

    it "should create an iteration once started" do
      Date.stubs(:today).returns(Date.parse('1/28/2008'))
      Query.expects(:open).times(3).returns(:qo1)      
      View.expects(:from_query).times(3).with(:qo1).returns(View.new(Array.[](@a[1], @a[2], @a[3])))
      Query.expects(:planned).times(1).returns(:qplanned)      
      View.expects(:from_query).times(1).with(:qplanned).returns(View.new(Array.[](@a[1])))

      @release.track
      @release.iterations.size.should == 1
    end

    it "should have an iteration in the proper date range" do
      @release.iterations.last.start_date.should == Date.parse('1/28/2008')
      @release.iterations.last.end_date.should == Date.parse('2/4/2008')
    end
    
    it "should not create an iteration once started" do
      Date.stubs(:today).returns(Date.parse('1/29/2008'))
      Query.expects(:open).times(1).returns(:qo1)      
      View.expects(:from_query).times(1).with(:qo1).returns(View.new(Array.[](@a[1], @a[2], @a[3])))
      Query.expects(:planned).times(1).returns(:qo2)      
      View.expects(:from_query).times(1).with(:qo2).returns(View.new(Array.[](@a[1], @a[2], @a[3])))

      @release.track
      @release.iterations.size.should == 1
    end

    it "should complete iteration" do
      Date.stubs(:today).returns(Date.parse('2/4/2008'))
      Query.expects(:open).times(5).returns(:qo1)      
      View.expects(:from_query).times(5).with(:qo1).returns(View.new(Array.[](@a[1], @a[2], @a[3])))

      Query.expects(:planned).times(1).returns(:qplanned)      
      View.expects(:from_query).times(1).with(:qplanned).returns(View.new(Array.[](@a[2])))

      Query.expects(:carried_over).times(1).returns(:carried_over_at_end)      
      View.expects(:from_query).times(1).with(:carried_over_at_end).returns(View.new(Array.[](@a[1], @a[2], @a[3])))

      Query.expects(:completed).times(2).returns(:completed)      
      View.expects(:from_query).times(2).with(:completed).returns(View.new(Array.[](@a[1], @a[2], @a[3])))

      @release.track
      @release.iterations.size.should == 2
    end

    it "should compute iteration length" do
      @release.iterations[0].length.should == 5
    end

    it "should compute velocity" do
      @release.iterations[0].velocity.should == 1.2
    end

    it "should complete iteration and project" do
      Date.stubs(:today).returns(Date.parse('2/11/2008'))
      Query.expects(:open).times(5).returns(:qo1)      
      View.expects(:from_query).times(5).with(:qo1).returns(View.new(Array.[]()))

      Query.expects(:carried_over).times(1).returns(:carried_over_at_end)      
      View.expects(:from_query).times(1).with(:carried_over_at_end).returns(View.new(Array.[](@a[1], @a[2], @a[3])))

      Query.expects(:completed).times(2).returns(:completed)      
      View.expects(:from_query).times(2).with(:completed).returns(View.new(Array.[](@a[1], @a[2], @a[3])))

      @release.track
      @release.iterations.size.should == 2
      @release.ended?.should be_true
      @release.actual_end_date.should == Date.parse('2/11/2008')
    end
  end
end