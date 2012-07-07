require 'spec_helper'

describe ActiveWarehouse::HierarchyBridge do
  
  #TODO: address the yuckiness of changing class attribute values in tests
  
  describe "#effective_date" do
    it "returns 'effective_date' by default" do
      ActiveWarehouse::HierarchyBridge.effective_date.should == 'effective_date'
    end
  end
  
  describe "#set_effective_date" do
    it "changes the value of effective_date" do
      ActiveWarehouse::HierarchyBridge.set_effective_date 'start_date'
      ActiveWarehouse::HierarchyBridge.effective_date.should == 'start_date'
      ActiveWarehouse::HierarchyBridge.set_effective_date 'effective_date' #breaks if examples not in order, so reset. yuck.
    end
  end

  describe "#expiration_date" do
    it "returns 'expiration_date' by default" do
      ActiveWarehouse::HierarchyBridge.expiration_date.should == 'expiration_date'
    end
  end
  
  describe "#set_expiration_date" do
    it "changes the value of expiration_date" do
      ActiveWarehouse::HierarchyBridge.set_expiration_date 'end_date'
      ActiveWarehouse::HierarchyBridge.expiration_date.should == 'end_date'
      ActiveWarehouse::HierarchyBridge.set_expiration_date 'expiration_date' #breaks if examples not in order, so reset. yuck.
    end
  end
  
  describe "#levels_from_parent" do
    it "returns 'num_levels_from_parent' by default" do
      ActiveWarehouse::HierarchyBridge.levels_from_parent.should == 'num_levels_from_parent'
    end
  end
  
  describe "#set_levels_from_parent" do
    it "changes the value of levels_from_parent" do
      ActiveWarehouse::HierarchyBridge.set_levels_from_parent 'num_levels'
      ActiveWarehouse::HierarchyBridge.levels_from_parent.should == 'num_levels'
      ActiveWarehouse::HierarchyBridge.set_levels_from_parent 'num_levels_from_parent' #breaks if examples not in order, so reset. yuck.
    end
  end

  describe "#top_flag" do
    it "returns 'is_top' by default" do
      ActiveWarehouse::HierarchyBridge.top_flag.should == 'is_top'
    end
  end
  
  describe "#set_top_flag" do
    it "changes the value of top_flag" do
      ActiveWarehouse::HierarchyBridge.set_top_flag 'top_level'
      ActiveWarehouse::HierarchyBridge.top_flag.should == 'top_level'
      ActiveWarehouse::HierarchyBridge.set_top_flag 'is_top' #breaks if examples not in order, so reset. yuck.
    end
  end
  
  describe "#top_flag_value" do
    it "returns true by default" do
      ActiveWarehouse::HierarchyBridge.top_flag_value.should be_true
    end
  end
  
  describe "#set_top_flag_value" do
    it "changes the value of top_flag_value" do
      ActiveWarehouse::HierarchyBridge.set_top_flag_value 'Yes'
      ActiveWarehouse::HierarchyBridge.top_flag_value.should == 'Yes'
      ActiveWarehouse::HierarchyBridge.set_top_flag_value true #breaks if examples not in order, so reset. yuck.
    end
  end

end