require "spec_helper"

describe "ActiveWarehouse::DateDimension", :new => true do
  
  describe "#sql_date_stamp" do
    it "returns 'sql_date_stamp' by default" do
      ActiveWarehouse::DateDimension.sql_date_stamp.should == 'sql_date_stamp'
    end
  end
  
  describe "#set_sql_date_stamp" do
    it "sets the sql_date_stamp to the passed string" do
      ActiveWarehouse::DateDimension.set_sql_date_stamp 'full_date'
      ActiveWarehouse::DateDimension.sql_date_stamp.should == 'full_date'
    end
  end

end