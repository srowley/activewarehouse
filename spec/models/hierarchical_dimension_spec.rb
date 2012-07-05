require "spec_helper"

describe "HierarchicalDimension", :new => true do
  
  before(:all) do
    @bob_smith = FactoryGirl.create(:customer, :customer_name => "Bob Smith")
    @jane_doe = FactoryGirl.create(:customer, :customer_name => "Jane Doe")
    @jimmy_dean = FactoryGirl.create(:customer, :customer_name => "Jimmy Dean")
    
    @root_customer = FactoryGirl.create(:root_customer, :parent_id => @bob_smith.id,
                                                      :child_id => @bob_smith.id)
                                                      
    @child_customer = FactoryGirl.create(:parent_bridge_record, :parent_id => @jane_doe.id,
                                                                :child_id => @jane_doe.id,
                                                                :is_top => 'N')

    @bob_is_janes_dad = FactoryGirl.create(:child_bridge_record, :parent_id => @bob_smith.id,
                                                                 :child_id => @jane_doe.id,
                                                                 :num_levels_from_parent => 1,
                                                                 :bottom_flag => 'N')

    @grandchild_customer = FactoryGirl.create(:parent_bridge_record, :parent_id => @jimmy_dean.id,
                                                                :child_id => @jimmy_dean.id,
                                                                :is_top => 'N',
                                                                :bottom_flag => 'Y')
                                                                
    @jane_is_jimmys_mom = FactoryGirl.create(:child_bridge_record, :parent_id => @jane_doe.id,
                                                                   :child_id => @jimmy_dean.id,
                                                                   :num_levels_from_parent => 1,
                                                                   :bottom_flag => 'Y')

    @bob_is_jimmys_grandpa = FactoryGirl.create(:child_bridge_record, :parent_id => @bob_smith.id,
                                                                      :child_id => @jimmy_dean.id,
                                                                      :num_levels_from_parent => 2,
                                                                      :bottom_flag => 'Y')
  end
  
  after(:all) do
    CustomerDimension.delete_all
    CustomerHierarchyBridge.delete_all
  end
  
  describe "#bridge_class" do
    it "returns the bridge class for a given dimension class" do
      CustomerDimension.bridge_class.should == CustomerHierarchyBridge
    end
  end
  
  describe "#bridge_class_name" do  
    it "returns the bridge class name as a string for a given dimension class" do
      CustomerDimension.bridge_class_name.should == "CustomerHierarchyBridge"
    end
  end

  describe "#parent" do
    context "when called on a record with no parent" do
      it "returns nil" do
        @bob_smith.parent.should be_nil
      end
    end
    
    context "when called on a record with a parent" do
      it "returns the record's parent object" do
        @jane_doe.parent.should == @bob_smith
      end
    end
  end

  describe "#children" do
    it "returns something" do
      @bob_smith.children.should_not be_nil
    end
    
    it "returns an array of the record's children" do
      @bob_smith.children.should include(@jane_doe)
    end
    
    it "does not include grandchildren in the returned array" do
      @bob_smith.children.should_not include(@jimmy_dean)
    end
  end
  
end