require File.dirname(__FILE__) + '/spec_helper'

describe MediaWiki do
  before(:all) do
    @wiki = MediaWiki.new
  end
  
  it "should log in" do
    res = @wiki.login
    @wiki.logged_in?.should be_true
  end
  
  it "should edit a page" do
  #  res = @wiki.edit('Dokken:Tracker', 'Blah')
  end
  
  it "shoud post the tracker" do
    a = Array.new
    view = mock()
    view.stubs(:total_cost).returns(123)
    view.stubs(:size).returns(456)
    view.stubs(:cost_missing?).returns(false)
    view.stubs(:bugzilla_url).returns("http://bugzilla.songbirdnest.com")

    iteration = mock()
    iteration.stubs(:start_date).returns(Date.parse('2008-01-01'))
    iteration.stubs(:end_date).returns(Date.parse('2008-12-31'))
    iteration.stubs(:number).returns(1)
    iteration.stubs(:wiki_url).returns("https://hq.songbirdnest.com")
    iteration.stubs(:remaining_at_start).returns(view)
    iteration.stubs(:changed).returns(view)
    iteration.stubs(:added).returns(view)
    iteration.stubs(:removed).returns(view)
    iteration.stubs(:completed).returns(view)
    iteration.stubs(:carry_over).returns(view)
    iteration.stubs(:remaining_at_end).returns(view)
    iteration.stubs(:asap_remaining_now).returns(view)
    iteration.stubs(:asap_remaining_at_end).returns(view)
    iteration.stubs(:asap_completed).returns(view)
    iteration.stubs(:planned).returns(view)
    iteration.stubs(:changed_net_cost).returns(12)
    iteration.stubs(:velocity).returns(Velocity.new(11.4))
    iteration.stubs(:changed_velocity).returns(Velocity.new(3.2))
    iteration.stubs(:planned_velocity).returns(Velocity.new(5.3))
    iteration.stubs(:ended?).returns(true)
    iteration.stubs(:completed_now).returns(view)
    iteration.stubs(:plan_locked?).returns(true)
    iteration.stubs(:plan_locked_on).returns(Time.now)

    iteration.stubs(:length).returns(4)

    a.push iteration
    a.push iteration
    a.push iteration
    a.push iteration

    release = mock()
    release.expects(:name).times(1).returns('Test')
    release.expects(:iterations).times(1).returns(a)
    release.expects(:remaining_now).times(1).returns(view)
    release.expects(:completed_now).times(1).returns(view)
  
    @wiki.publish(release)
  end
end