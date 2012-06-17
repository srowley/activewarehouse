require 'spec_helper'
require 'factories/facts.rb'

describe ActiveWarehouse::Fact, :new => true do  
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
  
  describe "#has_semiadditive_fact?" do
    it "returns false when the fact table doesn't have semi-additive facts" do
      PosRetailSalesTransactionFact.has_semiadditive_fact?.should be_false
    end
    
    it "returns true when the fact table has semi-additive facts" do
      StoreInventorySnapshotFact.has_semiadditive_fact?.should be_true
    end
  end
  
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
  
  describe "#belongs_to_relationship?" do                      
    it "returns true if the fact belongs_to the given dimension" do
      DailySalesFact.belongs_to_relationship?(:date).should be_true
    end
  end
  
  describe "#has_and_belongs_to_many_relationship?" do                      
    it "returns true if the fact has_many of and belongs_to the given dimension" do
      DailySalesFact.has_and_belongs_to_many_relationship?(:product).should be_true
    end
  end
  
end


