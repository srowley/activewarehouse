require 'spec_helper'

describe ActiveWarehouse::AggregateField, :new => true do
  
  before(:each) do
    @field = ActiveWarehouse::AggregateField.new(StoreInventorySnapshotFact,
        StoreInventorySnapshotFact.columns_hash["quantity_sold"])
  end

  describe "fact_class" do
    it "returns the class of the parent fact table" do
      @field.fact_class.should == StoreInventorySnapshotFact
    end
  end
  
  describe "#is_semiadditive?" do
    context "given a field that is not semi-additive" do
      it "returns false" do
        @field.is_semiadditive?.should be_false
      end
    end
    context "given a field that is semi-additive" do
      it "returns true" do
        @field = ActiveWarehouse::AggregateField.new(StoreInventorySnapshotFact,
            StoreInventorySnapshotFact.columns_hash["quantity_sold"], :sum, :semiadditive => :date)
        @field.is_semiadditive?.should be_true
      end
    end
  end

  describe "#strategy_name" do
    context "given a fact table with simple aggregation" do
      it "returns the strategy name for given AggregateField" do
        sales_quantity = PosRetailSalesTransactionFact.aggregate_field_for_name(:sales_quantity)
        sales_quantity.strategy_name.should == :sum
      end
    end
    
    context "given a fact table with more complex aggregation" do  
      it "returns the strategy name for given AggregateField" do
        quantity_on_hand  = StoreInventorySnapshotFact.aggregate_field_for_name(:quantity_on_hand )
        quantity_on_hand.strategy_name.should == :sum
      end
    end 
  end
  
  describe "#semiadditive_over" do
    it "returns dimension over which aggregate field is semi-additive" do
      quantity_on_hand = StoreInventorySnapshotFact.aggregate_field_for_name(:quantity_on_hand)
      quantity_on_hand.semiadditive_over.should == DateDimension
    end
  end
  
  describe "#default_strategy_name" do
    it "returns :sum as the default strategy name" do
      @field.strategy_name.should == :sum
    end
  end

  describe "#strategy_name_specified" do
    it "returns the specified strategy name" do
      @field = ActiveWarehouse::AggregateField.new(StoreInventorySnapshotFact,
          StoreInventorySnapshotFact.columns_hash["quantity_sold"], :count)
      @field.strategy_name.should == :count
    end
  end

  describe "#default_label" do
    it "returns 'fact_table_name_aggregate_column_strategy_name'" do
      @field.label.should == "store_inventory_snapshot_facts_quantity_sold_sum"
    end
  end

  describe "#label" do
    it "returns the label specified in options" do
        @field = ActiveWarehouse::AggregateField.new(StoreInventorySnapshotFact,
            StoreInventorySnapshotFact.columns_hash["quantity_sold"], :sum, :label => "My Sum")
        @field.label.should == "My Sum"
    end
  end
  
  describe "#label_for_table" do
    it "returns the label name in downcase-underscore format" do
      @field = ActiveWarehouse::AggregateField.new(StoreInventorySnapshotFact,
          StoreInventorySnapshotFact.columns_hash["quantity_sold"], :sum, :label => "My Sum")
      @field.label_for_table.should == "my_sum"
    end
  end
  
end