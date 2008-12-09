require File.dirname(__FILE__) + '/spec_helper'
module SDP
  describe "Dokken iteration 3" do
    before(:all) do
      @iteration = Iteration.new(3, "Dokken", Date.parse('01/21/2008'), Date.parse('01/25/2008'))

      s = <<EOQ
http://bugzilla.songbirdnest.com/buglist.cgi?quicksearch=632%2C754%2C2025%2C3370%2C3600%2C3708%2C3921%2C4017%2C4030%2C4161%2C4200%2C4461%2C4544%2C4571%2C4809%2C5008%2C5026%2C5382%2C5428%2C5496%2C5609%2C5774%2C6198%2C6206%2C6247%2C6248%2C6253%2C6294%2C6322%2C6324%2C6325%2C6329%2C6337%2C6356%2C6371%2C6427%2C6459%2C6471%2C6472%2C6486%2C6515%2C6519%2C6524%2C6525%2C6537%2C6640%2C6642%2C6652%2C6671%2C6676%2C6677%2C6678%2C6680%2C6681%2C6684%2C6685%2C6686%2C6688%2C6699%2C6705%2C6706%2C6707%2C6708%2C6709%2C6710%2C6711%2C6712%2C6713%2C6714%2C6715%2C6717%2C6726%2C6736%2C6788%2C6797%2C6804%2C6805%2C6806%2C6807%2C6808%2C6810%2C6811%2C6812%2C6813%2C6815%2C6816%2C6817%2C6818%2C6819%2C6820%2C6821%2C6822%2C6823%2C6824%2C6825%2C6826%2C6827%2C6828%2C6829%2C6830%2C6831%2C6834%2C6838%2C6839%2C6841%2C6853%2C6854%2C6856%2C6857%2C6858%2C6859%2C6860%2C6861%2C6862%2C6863%2C6864%2C6865%2C6866%2C6867%2C6868%2C6904%2C6905
EOQ
      @iteration.remaining_at_start = View.from_query(Query.from_s(s))

      s = <<EOQ
http://bugzilla.songbirdnest.com/buglist.cgi?quicksearch=2025%2C3370%2C3600%2C3921%2C4017%2C4030%2C4161%2C4200%2C4461%2C4544%2C4571%2C4809%2C4845%2C5008%2C5026%2C5382%2C5428%2C5496%2C5609%2C5774%2C5981%2C6198%2C6206%2C6247%2C6253%2C6316%2C6322%2C6324%2C6325%2C6337%2C6346%2C6356%2C6371%2C6427%2C6459%2C6471%2C6472%2C6486%2C6490%2C6515%2C6519%2C6537%2C6640%2C6642%2C6652%2C6671%2C6676%2C6677%2C6680%2C6684%2C6685%2C6688%2C6699%2C6705%2C6706%2C6707%2C6708%2C6709%2C6710%2C6711%2C6712%2C6713%2C6714%2C6715%2C6717%2C6726%2C6736%2C6788%2C6796%2C6797%2C6804%2C6807%2C6808%2C6810%2C6811%2C6812%2C6813%2C6815%2C6816%2C6817%2C6818%2C6819%2C6820%2C6821%2C6822%2C6823%2C6824%2C6825%2C6826%2C6827%2C6828%2C6829%2C6830%2C6831%2C6834%2C6838%2C6839%2C6860%2C6862%2C6863%2C6864%2C6865%2C6866%2C6867%2C6868%2C6904%2C6905%2C6912%2C6922%2C6933%2C6937%2C6949%2C6952%2C6953%2C6954%2C6955%2C6963%2C6989%2C6993%2C7005%2C7006%2C7008%2C7009
EOQ
      @iteration.remaining_at_end = View.from_query(Query.from_s(s))

      s = <<EOQ
http://bugzilla.songbirdnest.com/buglist.cgi?quicksearch=754%2C6329%2C6607%2C6681%2C6693%2C6841%2C6853%2C6854%2C6856%2C6857%2C6858%2C6248%2C6524%2C6525%2C6678%2C6805%2C6806%2C6859%2C6923%2C632%2C3708%2C6686%2C6861
EOQ
      @iteration.completed = View.from_query(Query.from_s(s))    

            s = <<EOQ
http://bugzilla.songbirdnest.com/buglist.cgi?quicksearch=2244%2C4017%2C4030%2C4461%2C4809%2C5611%2C6248%2C6346%2C6371%2C6708%2C6713%2C6714%2C6715%2C6807%2C6808%2C6810%2C6811%2C6860%2C6862%2C6863%2C6865%2C6866%2C6905%2C6933%2C6963%2C6989%2C6864
EOQ
      @iteration.carry_over = View.from_query(Query.from_s(s))    

            s = <<EOQ
http://bugzilla.songbirdnest.com/buglist.cgi?quicksearch=754%2C3708%2C4017%2C4030%2C4461%2C6329%2C6371%2C6678%2C6681%2C6686%2C6708%2C6713%2C6714%2C6715%2C6805%2C6810%2C6841%2C6853%2C6854%2C6856%2C6857%2C6858%2C6859%2C6860%2C6861%2C6862%2C6866
EOQ
      @iteration.planned = View.from_query(Query.from_s(s))    
    end

    it "should have length" do
      @iteration.length.should == 4
    end

    it "should have expected items remaining at start" do
      @iteration.remaining_at_start.size.should == 122
    end

    it "should have expected cost remaining at start" do
      begin
        @iteration.remaining_at_start.total_cost.should == 200
      rescue View::CostMissingException => e
        puts e.view
      end
    end

    it "should have expected items planned" do
      @iteration.planned.size.should == 27
    end

    it "should have expected cost planned" do
      begin
        @iteration.planned.total_cost.should == 45
      rescue View::CostMissingException => e
        puts e.view
      end
    end

    it "should have expected items remaining at end" do
      @iteration.remaining_at_end.size.should == 123
    end

    it "should have expected cost remaining at end" do
      begin
        @iteration.remaining_at_end.total_cost.should == 192
      rescue View::CostMissingException => e
        puts e.view
      end
    end

    it "should have expected items carried over" do
      @iteration.carry_over.size.should == 27
    end

    it "should have expected cost for carried over" do
      @iteration.carry_over.total_cost.should == 47
    end
    
    it "should have expected items completed" do
      @iteration.completed.size.should == 23
    end

    it "should have expected cost for completed" do
      @iteration.completed.total_cost.should == 39
    end

    it "should have expected velocity" do
      @iteration.velocity.should == 9.75
    end
    
    it "should compute changed" do
      q =<<EOQ
http://bugzilla.songbirdnest.com/buglist.cgi?quicksearch=6607%2C6693%2C4845%2C6923%2C5981%2C6316%2C6294%2C6346%2C6490%2C6796%2C6912%2C6922%2C6933%2C6937%2C6949%2C6952%2C6953%2C6954%2C6955%2C6963%2C6989%2C6993%2C7005%2C7006%2C7008%2C7009
EOQ
      @iteration.changed.should == View.from_query(Query.from_s(q))
    end

    it "should have expected items that changed" do
      @iteration.changed.size.should == 26
    end

    it "should compute net intake cost" do
      @iteration.changed_net_cost.should == 31
    end
  end
end