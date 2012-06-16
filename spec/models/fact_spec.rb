require 'spec_helper'
require 'factories/facts.rb'

describe ActiveWarehouse::Fact, :new => true do
  
  before(:all) do
    create_product_dimension
    create_promotion_dimension
    create_pos_retail_sales_transaction_facts
    PosRetailSalesTransactionFact.aggregate :sales_quantity, :label => 'Sum of Sales Quantity'
    PosRetailSalesTransactionFact.aggregate :sales_quantity, :label => 'Sum of Sales Quantity Self', :levels_from_parent => [0]
    PosRetailSalesTransactionFact.aggregate :sales_quantity, :label => 'Sum of Sales Quantity Me and Immediate children', :levels_from_parent => [:self, 1]
    PosRetailSalesTransactionFact.aggregate :sales_dollar_amount, :label => 'Sum of Sales Amount'
    PosRetailSalesTransactionFact.aggregate :cost_dollar_amount, :label => 'Sum of Cost'
    PosRetailSalesTransactionFact.aggregate :gross_profit_dollar_amount, :label => 'Sum of Gross Profit'
    PosRetailSalesTransactionFact.aggregate :sales_quantity, :type => :count, :label => 'Sales Quantity Count'
    PosRetailSalesTransactionFact.aggregate :sales_dollar_amount, :type => :avg, :label => 'Avg Sales Amount'

    PosRetailSalesTransactionFact.calculated_field (:gross_margin) { |r| r.gross_profit_dollar_amount / r.sales_dollar_amount}

    PosRetailSalesTransactionFact.dimension :date
    PosRetailSalesTransactionFact.dimension :store
    PosRetailSalesTransactionFact.dimension :product
    PosRetailSalesTransactionFact.dimension :promotion
    PosRetailSalesTransactionFact.dimension :customer

    PosRetailSalesTransactionFact.prejoin :product => [:category_description, :brand_description]
    PosRetailSalesTransactionFact.prejoin :promotion => [:promotion_name]
  end
    
  describe "#dimensions" do
    it "returns an array of the fact table's dimensions'" do
      PosRetailSalesTransactionFact.dimensions.sort { |a, b| a.to_s <=> b.to_s}.should == [:customer, :date, :product, :promotion, :store]
    end
  end
  
  describe "#define_aggregate" do
    context "given a non-existent fact field" do
      it "raises an ArgumentError" do
        expect { PosRetailSalesTransactionFact.define_aggregate :no_fact_by_this_name }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#last_modified" do
    it "returns a value" do
      PosRetailSalesTransactionFact.should_not be_nil
    end
  end
  
  describe "#table_name" do
    it "returns the name of the fact table" do
      PosRetailSalesTransactionFact.table_name.should == 'pos_retail_sales_transaction_facts'
    end
  end

  describe "#class_name" do
    context "when called on the fact subclass" do
      context "and passed the table name as a string" do
        it "returns the fact subclass name" do
          PosRetailSalesTransactionFact.class_name('pos_retail_sales_transaction').should == "PosRetailSalesTransactionFact"
        end
      end
      
      context "and passed the table name as a symbol" do
        it "returns the fact subclass name" do
          PosRetailSalesTransactionFact.class_name(:pos_retail_sales_transaction).should == "PosRetailSalesTransactionFact"
        end
      end
    end
    
    context "when called on the Fact class" do
      context "and passed the table name as a string" do
        it "returns the fact subclass name" do
          ActiveWarehouse::Fact.class_name('pos_retail_sales_transaction').should == "PosRetailSalesTransactionFact"
        end
      end
      
      context "and passed the table name as a symbol" do
        it "returns the fact subclass name" do
          ActiveWarehouse::Fact.class_name(:pos_retail_sales_transaction).should == "PosRetailSalesTransactionFact"
        end
      end
    end
  end
  
  describe "#class_for_name" do
    context "when called on the fact subclass" do
      context "and passed the table name as a string" do
        it "returns the fact subclass" do
          PosRetailSalesTransactionFact.class_for_name('pos_retail_sales_transaction').should == PosRetailSalesTransactionFact
        end
      end
      
      context "and passed the table name as a symbol" do
        it "returns the fact subclass" do
          PosRetailSalesTransactionFact.class_for_name(:pos_retail_sales_transaction).should == PosRetailSalesTransactionFact
        end
      end
    end
    
    context "when called on the Fact class" do
      context "and passed the table name as a string" do
        it "returns the fact subclass" do
          ActiveWarehouse::Fact.class_for_name('pos_retail_sales_transaction').should == PosRetailSalesTransactionFact
        end
      end
      
      context "and passed the table name as a symbol" do
        it "returns the fact subclass" do
          ActiveWarehouse::Fact.class_for_name(:pos_retail_sales_transaction).should == PosRetailSalesTransactionFact
        end
      end
    end
  end
  
  describe "#aggregate_fields" do    
    it "returns all the fields" do
      PosRetailSalesTransactionFact.aggregate_fields.should have(8).items
    end
    
    it "includes the fields specified" do
      PosRetailSalesTransactionFact.aggregate_fields.find {|f| f.name == "sales_quantity"}.should be_true
    end
  end
  
  describe "#aggregate_field_for_name" do
    it "returns a value" do
      PosRetailSalesTransactionFact.aggregate_field_for_name(:sales_quantity).should_not be_nil
    end
  end
  
  # TODO: move this where it belongs
  describe "AggregateField#strategy.name" do
    it "returns the strategy name for given AggregateField" do
      sales_quantity = PosRetailSalesTransactionFact.aggregate_field_for_name(:sales_quantity)
      sales_quantity.strategy_name.should == :sum
    end
  end
  
  describe "#has_semiadditive_fact?" do
    it "returns false when the fact table has no semi-additive facts" do
      PosRetailSalesTransactionFact.has_semiadditive_fact?.should be_false
    end
  end

#  def test_complex_aggregate_fields
#    aggregate_fields = StoreInventorySnapshotFact.aggregate_fields
#    assert_not_nil aggregate_fields
#    assert_equal 4, aggregate_fields.length
#    
#    quantity_on_hand = StoreInventorySnapshotFact.aggregate_field_for_name(:quantity_on_hand)
#    assert_not_nil quantity_on_hand
#    assert_equal :sum, quantity_on_hand.strategy_name
#    assert quantity_on_hand.is_semiadditive?
#    assert_equal DateDimension, quantity_on_hand.semiadditive_over
#    
#    assert StoreInventorySnapshotFact.has_semiadditive_fact?
#  end
#  
  describe "#calculated_field" do
    it "is missing a test"
  end
  
  describe "#field_for_name" do
    # TODO: Do better. This is like testing if "9".to_i.to_s == "9"
    it "returns the right field" do
      PosRetailSalesTransactionFact.field_for_name(:gross_margin).name.should == 'gross_margin'
    end
  end

  describe "#associations" do
    it "loads associations" do
      PosRetailSalesTransactionFact.new.should respond_to(:date)
    end
  end

  describe "#prejoined_fields" do
    it "returns a value" do
      PosRetailSalesTransactionFact.prejoined_fields.should_not be_nil
    end
    
    it "includes all the prejoined fields" do
      PosRetailSalesTransactionFact.prejoined_fields.should have(2).items
    end
  end
  
  describe "#prejoined_table_name" do
    it "returns a value" do
      PosRetailSalesTransactionFact.prejoined_table_name.should == "prejoined_pos_retail_sales_transaction_facts"
    end
  end
  
  describe "#dimension_relationships" do
    it "returns a value" do
      PosRetailSalesTransactionFact.dimension_relationships.should_not be_nil
    end
    
    it "includes all the relationships" do
      dimension_relationships = PosRetailSalesTransactionFact.dimension_relationships
      dimension_names = dimension_relationships.collect{|k,v| k}.sort{|a,b| a.to_s <=> b.to_s}
      dimension_names.should == [:customer, :date, :product, :promotion, :store]
    end    
  end
  
  describe "#populate" do
    it "doesn't raise an error when called" do
      expect {PosRetailSalesTransactionFact.populate }.to_not raise_error
    end
  end
  
  #  
  #  def test_dimension_relationship
  #    assert DailySalesFact.belongs_to_relationship?(:date)
  #    assert DailySalesFact.has_and_belongs_to_many_relationship?(:product)
  #  end
  
end


