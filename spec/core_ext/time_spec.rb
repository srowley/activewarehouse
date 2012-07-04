require "spec_helper"

describe "Time extensions", :new => true do
  
  describe "#week" do
    it "returns the calendar week for a given Time" do
      Time.parse('2005-01-01').week.should == 1
      Time.parse('2005-12-30').week.should == 52
    end
  end

  describe "#quarter" do
    it "returns the calendar quarter for a given Time" do
      Time.parse('2005-01-01').quarter.should == 1
      Time.parse('2005-12-30').quarter.should == 4
    end
  end

  describe "#fiscal_year_week" do
    context "when not provided an offset" do
      it "returns the fiscal year week using default offset for a given Time" do
        Time.parse('2005-10-01').fiscal_year_week.should == 1
        Time.parse('2005-11-01').fiscal_year_week.should == 5
      end
    end
    context "when provided an offset" do
      it "returns the fiscal year week using given offset for a given Time" do
        Time.parse('2006-07-01').fiscal_year_week(7).should == 1
      end
    end
  end  

  describe "#fiscal_year_month" do
    context "when not provided an offset" do
      it "returns the fiscal year month using default offset for a given Time" do
        Time.parse('2006-10-01').fiscal_year_month.should == 1
        Time.parse('2006-11-01').fiscal_year_month.should == 2
      end
    end
    
    context "when provided an offset" do
      it "returns the fiscal year month using given offset for a given Time" do
        Time.parse('2006-07-10').fiscal_year_month(7).should == 1
      end
    end
  end

  describe "#fiscal_year_quarter" do
    context "when not provided an offset" do
      it "returns the fiscal year quarter using default offset for a given Time" do
        Time.parse('2005-10-01').fiscal_year_quarter.should == 1
        Time.parse('2005-12-31').fiscal_year_quarter.should == 1
        Time.parse('2006-01-01').fiscal_year_quarter.should == 2
        Time.parse('2006-04-01').fiscal_year_quarter.should == 3
      end
    end
    
    context "when provided an offset" do
      it "returns the fiscal year quarter using given offset for a given Time" do
        Time.parse('2006-07-01').fiscal_year_quarter(7).should == 1
      end
    end
  end  

  describe "#fiscal_year" do
    context "when not provided an offset" do
      it "returns the fiscal year using default offset for a given Time" do
        Time.parse('2005-10-01').fiscal_year.should == 2006
        Time.parse('2005-12-31').fiscal_year.should == 2006
        Time.parse('2006-01-01').fiscal_year.should == 2006
        Time.parse('2006-10-10').fiscal_year.should == 2007
      end
    end
    
    context "when provided an offset" do
      it "returns the fiscal year using given offset for a given Time" do
        Time.parse('2005-07-01').fiscal_year(7).should == 2006
      end
    end
  end

  describe "#fiscal_year_yday" do
    it "returns the day of the fiscal year for a given Time" do
      Time.parse('2005-10-01').fiscal_year_yday.should == 1
      Time.parse('2006-9-30').fiscal_year_yday.should == 365
    end
  end

end
