require 'spec_helper'

describe ActiveWarehouse::Bridge, :new => true do
  describe "#table_name" do
    it "returns the bridge table name in downcase-underscore format" do
      CustomerHierarchyBridge.table_name.should == "customer_hierarchy_bridge"
    end
  end
  
end