require "spec_helper"

describe ActiveWarehouse::Aggregate::DwarfAggregate do
  
  # TODO: the original test didn't check to see if this raised an error.
  # It actually made no assertions at all. So this is no worse, I guess.
  # Calling #create_dwarf_cube prints out some output that probably shows
  # the aggregate build path; need to look into that more.
  
  describe "#create_dwarf_cube" do 
    it "shouldn't raise an error" do
      fact_table = [
        ['S1','C2','P2',70],
        ['S1','C3','P1',40],
        ['S2','C1','P1',90],
        ['S2','C1','P2',50],
      ]
      agg = ActiveWarehouse::Aggregate::DwarfAggregate.new(nil)
      agg.number_of_dimensions = 3
      expect{ agg.create_dwarf_cube(fact_table) }.to_not raise_error
    end
  end
end

# TODO: Review these old tests to determine if they are needed, 
# were failing, or what, since they were commented out in the 
# original test suite

  # def test_populate
#     assert_nothing_raised do
#       agg = ActiveWarehouse::Aggregate::DwarfAggregate.new(MultiDimensionalRegionalSalesCube)
#       agg.populate
#     end
#   end
#
#   def test_query
#     agg = ActiveWarehouse::Aggregate::DwarfAggregate.new(MultiDimensionalRegionalSalesCube)
#     agg.populate
#     results = agg.query(:date, :cy, :store, :region)
#   end
  
