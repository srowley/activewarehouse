require 'spec_helper'

describe ActiveWarehouse::CalculatedField, :new => true  do
  
  before(:each) do
    @field = ActiveWarehouse::CalculatedField.new(
      StoreInventorySnapshotFact, :average_quantity_sold) { |r| r[:x] * 10 }
  end

  describe "#owning_class" do
    it "returns the class for the parent fact table" do
      @field.owning_class.should == StoreInventorySnapshotFact
    end
  end
  
  describe "#default_label" do
    it "returns 'fact_table_name_calculated_column'" do
      @field.label.should == "store_inventory_snapshot_facts_average_quantity_sold"
    end
  end
  
  describe "#label" do
    it "returns the label specified in options" do
      @field = ActiveWarehouse::CalculatedField.new(StoreInventorySnapshotFact,
          :average_quantity_sold, :float, :label => "My Sum") { |r| r[:x] }
      @field.label.should == "My Sum"  
    end
  end
  
  describe "#label_for_table" do
    it "returns the label name in downcase-underscore format" do
      @field = ActiveWarehouse::CalculatedField.new(StoreInventorySnapshotFact,
          :average_quantity_sold, :float, :label => "My Sum") { |r| r[:x] }
      @field.label_for_table.should == "my_sum"  
    end
  end 

  describe "#calculate" do
    it "correctly performs the given calculation" do
      @field.calculate(:x => 2).should == 20
    end
  end
  
  describe "#new" do
    it "raises an ArgumentError if no calculation block is provided" do
      expect { ActiveWarehouse::CalculatedField.new(StoreInventorySnapshotFact, :foo) }.to raise_error(ArgumentError)
    end
  end 
  
end