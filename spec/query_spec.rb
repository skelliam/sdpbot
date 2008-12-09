require File.dirname(__FILE__) + '/spec_helper'

module Bugzilla
	describe Query do
    it "should build query for all open" do
      q = Query.open("Dokken")
      q.to_s.should == "/buglist.cgi?query_format=advanced&target_milestone=Dokken&bug_status=UNCONFIRMED&bug_status=NEW&bug_status=ASSIGNED&bug_status=REOPENED&priority=---&priority=P1&priority=P2&priority=P3&field0-0-0=cf_type_&type0-0-0=notequals&value0-0-0=Feature"
    end

    it "should build query for completed" do
      q = Query.completed("Dokken", Date.parse("1/18/2008"), Date.parse("1/25/2008"))
      q.to_s.should == "/buglist.cgi?query_format=advanced&target_milestone=Dokken&resolution=FIXED&chfield=resolution&chfieldvalue=FIXED&priority=---&priority=P1&priority=P2&priority=P3&chfieldfrom=2008-01-18&chfieldto=2008-01-25&field0-0-0=cf_type_&type0-0-0=notequals&value0-0-0=Feature"    
    end

    it "should build query for carry over" do
      q = Query.carried_over("Dokken")
      q.to_s.should == "/buglist.cgi?query_format=advanced&target_milestone=Dokken&bug_status=UNCONFIRMED&bug_status=NEW&bug_status=ASSIGNED&bug_status=REOPENED&priority=P1&field0-0-0=cf_type_&type0-0-0=notequals&value0-0-0=Feature"
    end

    it "should build query from string" do
      q = Query.from_s("http://bugzilla.songbirdnest.com/buglist.cgi?query_format=advanced&target_milestone=Dokken&bug_status=UNCONFIRMED&bug_status=NEW&bug_status=ASSIGNED&bug_status=REOPENED&priority=---&priority=P1&priority=P2&priority=P3&field0-0-0=cf_type_&type0-0-0=notequals&value0-0-0=Feature")
      q.to_s.should == "/buglist.cgi?query_format=advanced&target_milestone=Dokken&bug_status=UNCONFIRMED&bug_status=NEW&bug_status=ASSIGNED&bug_status=REOPENED&priority=---&priority=P1&priority=P2&priority=P3&field0-0-0=cf_type_&type0-0-0=notequals&value0-0-0=Feature"
    end
    
    it "should build query for fixed by" do
      q = Query.fixed_by("", Date.parse("10/01/2007"), Date.parse("01/01/2008"), "georges@songbirdnest.com")
      q.to_s.should == "/buglist.cgi?query_format=advanced&emailassigned_to1=1&emailtype1=exact&email1=georges@songbirdnest.com&resolution=FIXED&chfield=resolution&chfieldvalue=FIXED&chfieldfrom=2007-10-01&chfieldto=2008-01-01&field0-0-0=cf_type_&type0-0-0=notequals&value0-0-0=Feature"
    end

    it "should build query for planned" do
      q = Query.planned("Dokken")
      q.to_s.should == "/buglist.cgi?query_format=advanced&target_milestone=Dokken&bug_status=UNCONFIRMED&bug_status=NEW&bug_status=ASSIGNED&bug_status=REOPENED&priority=P1&field0-0-0=cf_type_&type0-0-0=notequals&value0-0-0=Feature"
    end
    
    it "should detect static queries" do
      q = Query.from_s "http://bugzilla.songbirdnest.com/buglist.cgi?quicksearch=123,456&someotherparam"
      q.should be_is_static
      q.to_s.should == "/buglist.cgi?order=bugs.bug_id&quicksearch=123,456"
    end

    it "should detect static queries url encoded" do
      q = Query.from_s "http://bugzilla.songbirdnest.com/buglist.cgi?quicksearch=6607%2C6693%2C4845%2C6923%2C5981%2C6316%2C6294%2C6346%2C6490%2C6796%2C6912%2C6922%2C6933%2C6937%2C6949%2C6952%2C6953%2C6954%2C6955%2C6963%2C6989%2C6993%2C7005%2C7006%2C7008%2C7009"
      q.should be_is_static
      q.to_s.should == "/buglist.cgi?order=bugs.bug_id&quicksearch=4845,5981,6294,6316,6346,6490,6607,6693,6796,6912,6922,6923,6933,6937,6949,6952,6953,6954,6955,6963,6989,6993,7005,7006,7008,7009"
    end
    
    it "should build query wiht optional params" do
      q = Query.open("Dokken", {:products => %w(Songbird)})
      q.to_s.should == "/buglist.cgi?query_format=advanced&product=Songbird&target_milestone=Dokken&bug_status=UNCONFIRMED&bug_status=NEW&bug_status=ASSIGNED&bug_status=REOPENED&priority=---&priority=P1&priority=P2&priority=P3&field0-0-0=cf_type_&type0-0-0=notequals&value0-0-0=Feature"
    end

    it "should build query for all" do
      q = Query.all("Dokken")
      q.to_s.should == "/buglist.cgi?query_format=advanced&target_milestone=Dokken&field0-0-0=cf_type_&type0-0-0=notequals&value0-0-0=Feature"
    end

    it "should support array of target milestones" do
      q = Query.all(["Dokken", "Cosmo"])
      q.to_s.should == "/buglist.cgi?query_format=advanced&target_milestone=Dokken&target_milestone=Cosmo&field0-0-0=cf_type_&type0-0-0=notequals&value0-0-0=Feature"
    end
	end
end