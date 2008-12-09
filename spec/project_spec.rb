require File.dirname(__FILE__) + '/spec_helper'

module SDP
	describe Project do
	  before(:all) do
	    @project = Project.new(Date.parse('1/1/2008'), Date.parse('1/10/2008'))
	  end
	  	  
	  it "should not have started" do
	    @project.started?.should be_false
	  end
	  
	  it "should have ended" do
	    @project.ended?.should be_true
	  end
	  
	  it "should not have started nor ended" do
	    project = Project.new(Date.today + 1, Date.today + 2)
	    project.started?.should be_false
	    project.ended?.should be_false
	  end

	  it "should have started but not ended" do
	    project = Project.new(Date.today, Date.today + 1)
	    project.started?.should be_true
	    project.ended?.should be_false
	  end

	  it "should allow for a mock clock to manipulate time" do
      Date.stubs(:today).returns(Date.parse('1/1/2007'))
	    project = Project.new(Date.parse('2/1/2007'), Date.parse('2/10/2007'))
	    project.started?.should be_false
	    project.ended?.should be_false
      Date.stubs(:today).returns(Date.parse('2/1/2007'))
	    project.started?.should be_true
	    project.ended?.should be_false
      Date.stubs(:today).returns(Date.parse('2/2/2007'))
	    project.started?.should be_true
	    project.ended?.should be_false
      Date.stubs(:today).returns(Date.parse('2/9/2007'))
	    project.started?.should be_true
	    project.ended?.should be_false
      Date.stubs(:today).returns(Date.parse('2/10/2007'))
	    project.started?.should be_false
	    project.ended?.should be_true
      Date.stubs(:today).returns(Date.parse('2/11/2007'))
	    project.started?.should be_false
	    project.ended?.should be_true
	  end
	  
    it "should serialize to yaml" do
yaml =<<EOY
--- !ruby/object:SDP::Project 
start_date: 2008-01-01
end_date: 2008-01-10
EOY
      @project.to_yaml.should == yaml
    end	  
	end
end