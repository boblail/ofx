require "spec_helper"

describe OFX::Parser::OFX211 do
  before do
    @ofx = OFX::Parser::Base.new("spec/fixtures/v211.ofx")
    @parser = @ofx.parser
  end
  
  it "should have a version" do
    OFX::Parser::OFX211::VERSION.should == "2.1.1"
  end
  
  it "should set headers" do
    @parser.headers.should == @ofx.headers
  end
  
  it "should set body" do
    @parser.body.should == @ofx.body
  end
  
  it "should set account" do
    @parser.account.should be_a_kind_of(OFX::Account)
  end
  
  
  # See 3.2.8.2 Date and Datetime in the OFX 2.1.1 specification
  
  context "parsing dates" do
    it "should parse YYYYMMDD dates with the time 12:00 AM, GMT" do
      parse("20050811").should == Time.gm(2005, 8, 11, 0, 0, 0)
    end
    
    it "should parse YYYYMMDDHHMMSS dates with the specified time, GMT" do
      parse("20050811080530").should == Time.gm(2005, 8, 11, 8, 5, 30)
    end
    
    it "should parse YYYYMMDDHHMMSS.XXX dates with the specified milliseconds, GMT" do
      parse("20050811080530.154").should == Time.gm(2005, 8, 11, 8, 5, 30.154)
    end
    
    # Whole number offsets don't require the : and the minutes part
    it "should parse +1 as a valid whole number offset" do
      parse("20050811000000.000[+1:CET]").should == Time.new(2005, 8, 11, 0, 0, 0, "+01:00")
    end
    
    # The plus sign is optional, so is the time zone name
    it "should parse 1 as a valid whole number offset" do
      parse("20050811000000.000[1]").should == Time.new(2005, 8, 11, 0, 0, 0, "+01:00")
    end
    
    it "should parse -7 as a valid whole number offset" do
      parse("20050811000000.000[-7:MST]").should == Time.new(2005, 8, 11, 0, 0, 0, "-07:00")
    end
    
    it "should parse +09:30 as a valid fractional offset" do
      parse("20050811000000.000[+09:30]").should == Time.new(2005, 8, 11, 0, 0, 0, "+09:30")
    end
    
    def parse(date)
      @parser.send(:build_date, date)
    end
    
  end
  
  
  context "transactions" do
    before do
      @transactions = @parser.account.transactions
    end

    # Test file contains only three transactions. Let's just check
    # them all.
    context "first" do
      before do
        @t = @transactions[0]
      end

      it "should contain the correct values" do
        @t.amount.should == -80
        @t.fit_id.should == "219378"
        @t.memo.should be_empty
        @t.posted_at.should == Time.gm(2005, 8, 24, 8, 0, 0)
        @t.name.should == "FrogKick Scuba Gear"
      end
    end

    context "second" do
      before do
        @t = @transactions[1]
      end
      
      it "should contain the correct values" do
        @t.amount.should == -23
        @t.fit_id.should == "219867"
        @t.memo.should be_empty
        @t.posted_at.should == Time.gm(2005, 8, 11, 8, 0, 0)
        @t.name.should == "Interest Charge"
      end
    end
    
    context "third" do
      before do
        @t = @transactions[2]
      end
      
      it "should contain the correct values" do
        @t.amount.should == 350
        @t.fit_id.should == "219868"
        @t.memo.should be_empty
        @t.posted_at.should == Time.gm(2005, 8, 11, 8, 0, 0)
        @t.name.should == "Payment - Thank You"
      end
    end
  end
end

