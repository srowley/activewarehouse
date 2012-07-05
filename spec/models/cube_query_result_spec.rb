require "spec_helper"

describe ActiveWarehouse::CubeQueryResult, :new => true do
  
  before(:each) do
    @cqr = ActiveWarehouse::CubeQueryResult.new(StoreInventorySnapshotFact.aggregate_fields)
    @cqr.add_data('a', 'b', {"Sum Quantity Sold" => 1, "Sum Dollar Value At Cost" => 2})
  end
  
  describe "#add_data" do
    it "adds the correct values to the result object again" do
      @cqr.add_data(2003, 'c', {"Sum Quantity Sold" => 1, "Sum Dollar Value At Cost" => 2})
      @cqr.values(2003, 'c').should == {"Sum Quantity Sold" => 1, "Sum Dollar Value At Cost" => 2}
    end
  end
  
  describe "#value" do
    it "returns the correct values for each aggregate field at the specified row & column" do
      @cqr.value('a', 'b', "Sum Quantity Sold").should == 1
      @cqr.value('a', 'b', "Sum Dollar Value At Cost").should == 2
    end
    
    it "returns 0 for values at row/column combinations that don't exist" do
      @cqr.value('b', 'b', "Sum Dollar Value At Cost").should == 0
    end
    
    it "raises an ArgumentError when specified aggregate field doesn't exist" do
      expect { @cqr.add_data('a', 'b', {"doesn't exist" => 1, "Sum Dollar Value At Cost" => 2}) }.to raise_error ArgumentError
    end
  end
  
  describe "#new" do
    it "raises an error when no object is passed to it" do
      expect{ @cqr = ActiveWarehouse::CubeQueryResult.new(nil) }.to raise_error ArgumentError
    end
  end
  
  describe "#has_row_values" do
    context "when it is passed a string for which there is a row value" do
      it "returns true" do
        @cqr.has_row_values?('a').should be_true
      end
    end
    
    context "when it is passed a string for which there is not a row value" do
      it "returns false" do
        @cqr.has_row_values?('b').should be_false
      end
    end
  end
  
end