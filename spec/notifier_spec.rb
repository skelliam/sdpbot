require File.dirname(__FILE__) + '/spec_helper'
require 'erb'

require 'action_view'

module SDP
  describe Notifier do
    before(:all) do
      ActionMailer::Base.delivery_method = :test
    end
    
    it "should send an email" do            
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

      @release = mock()
      @release.expects(:name).times(3).returns("MyRelease")
      @release.expects(:start_date).times(2).returns(Date.parse('2008-01-01'))
      @release.expects(:end_date).times(2).returns(Date.parse('2008-12-31'))
      @release.expects(:iterations).times(2).returns(a)
      @release.expects(:iteration_length).times(2).returns(7)
      @release.expects(:remaining_now).times(2).returns(view)
      @release.expects(:completed_now).times(2).returns(view)
      @release.expects(:wiki_url).times(2).returns("https://hq.songbirdnest.com")

      content = ActionViewHelper.render(:file => 'release_tracking', :locals => {:release => @release})
               
      Notifier.deliver_release_tracking('john.doe@gmail.com', @release)
      
      email = ActionMailer::Base.deliveries.last
      email['to'].to_s.should == "john.doe@gmail.com"
      email['from'].to_s.should == "tracking@songbirdnest.com"
      email['subject'].to_s.should == "[MyRelease] release tracking"
      email.body.should == content
      
      File.open("#{Notifier.template_root}/#{Notifier.mailer_name}/release_tracking_1.html", 'w+') { |f|
        f.print content
      }            
      File.open("#{Notifier.template_root}/#{Notifier.mailer_name}/release_tracking_2.html", 'w+') { |f|
        f.print email.body
      }            
    end


    it "should send an email with incomplete costing" do
      a = Array.new
      view = mock()
      view.stubs(:total_cost).returns()
      view.stubs(:size).returns(456)
      view.stubs(:cost_missing?).returns(true)
      view.stubs(:bugzilla_url).returns("http://bugzilla.songbirdnest.com")

      iteration = mock()
      iteration.stubs(:start_date).returns(Date.parse('2008-01-01'))
      iteration.stubs(:end_date).returns(Date.parse('2008-12-31'))
      iteration.stubs(:number).returns(1)
      iteration.stubs(:wiki_url).returns("https://hq.songbirdnest.com")
      iteration.stubs(:remaining_at_start).returns(view)
      iteration.stubs(:changed).returns(nil)
      iteration.stubs(:added).returns(nil)
      iteration.stubs(:removed).returns(nil)
      iteration.stubs(:completed).returns(nil)
      iteration.stubs(:carry_over).returns(nil)
      iteration.stubs(:planned).returns(view)      
      iteration.stubs(:remaining_at_end).returns(nil)
      iteration.stubs(:changed_net_cost).returns(-1)
      iteration.stubs(:velocity).returns(Velocity.new(12.5))
      iteration.stubs(:changed_velocity).returns(Velocity.new(3.2))
      iteration.stubs(:planned_velocity).returns(Velocity.new(5.3))
      iteration.stubs(:asap_remaining_now).returns(view)
      iteration.stubs(:asap_completed).returns(view)
      iteration.stubs(:asap_remaining_at_end).returns(view)
      iteration.stubs(:completed_now).returns(view)
      iteration.stubs(:plan_locked?).returns(true)
      iteration.stubs(:plan_locked_on).returns(Time.now)

      iteration.stubs(:ended?).returns(false)

      iteration.stubs(:length).returns(5)

      a.push iteration
      a.push iteration
      a.push iteration
      a.push iteration

      @release = mock()
      @release.expects(:name).times(3).returns("MyRelease")
      @release.expects(:start_date).times(2).returns(Date.parse('2008-01-01'))
      @release.expects(:end_date).times(2).returns(Date.parse('2008-12-31'))
      @release.expects(:iterations).times(2).returns(a)
      @release.expects(:iteration_length).times(2).returns(7)
      @release.expects(:remaining_now).times(2).returns(view)
      @release.expects(:completed_now).times(2).returns(view)      
      @release.expects(:wiki_url).times(2).returns("https://hq.songbirdnest.com")

      content = ActionViewHelper.render(:file => 'release_tracking', :locals => {:release => @release})

      Notifier.deliver_release_tracking('john.doe@gmail.com', @release)
      
      email = ActionMailer::Base.deliveries.last
      email['to'].to_s.should == "john.doe@gmail.com"
      email['from'].to_s.should == "tracking@songbirdnest.com"
      email['subject'].to_s.should == "[MyRelease] release tracking"
      email.body.should == content
    end
  end
end