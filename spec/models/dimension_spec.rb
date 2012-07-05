require 'spec_helper'

describe ActiveWarehouse::Dimension, :new => true do
  before(:all) do
    (Date.new(2001, 1, 1)..Date.new(2008, 12, 31)).each do |date|
      FactoryGirl.create(:date_incremented_by_day)
    end
  end
  
  after(:all) do
    DateDimension.delete_all
  end
  
  describe "#hierarchy" do
    it "returns an array of attributes in a hierarchy" do
      DateDimension.hierarchy(:cy).should == [:calendar_year, :calendar_quarter, :calendar_month_name, :calendar_week, :day_of_week]
    end
  end
  
  describe "#hierarchies" do
    it "returns an array of hierarchies" do
      DateDimension.hierarchies.should == [:cy, :fy, :rollup]
    end
  end
  
  describe "#table_name" do
    it "returns the name of the database table for the dimension" do
      DateDimension.table_name.should == "date_dimension"
    end
  end
  
  describe "#class_name" do
    context "given the dimension name as a symbol" do
      it "returns the name of the Dimension subclass" do
        DateDimension.class_name(:date).should == "DateDimension"
      end
    end
    
    context "given the dimension name as a string" do
      it "returns the name of the Dimension subclass" do
        DateDimension.class_name("date").should == "DateDimension"
      end
    end
    
    context "given the dimension table name as a string" do
      it "returns the name of the Dimension subclass" do
        DateDimension.class_name("date_dimension").should == "DateDimension"
      end
    end
  end
  
  describe "#class_for_name" do
    context "given the dimension name as a symbol" do
      it "returns the Dimension subclass" do
        DateDimension.class_for_name(:date).should == DateDimension
      end
    end
    
    context "given the dimension name as a string" do
      it "returns the Dimension subclass" do
        DateDimension.class_for_name("date").should == DateDimension
      end
    end
    
    context "given the dimension table name as a string" do
      it "returns the Dimension subclass" do
        DateDimension.class_for_name("date_dimension").should == DateDimension
      end
    end
  end
  
  describe "#last_modified" do
    it "returns a value" do
      DateDimension.last_modified.should_not be_nil
    end
  end
  
  describe "#to_dimension" do
    context "when called on the subclass" do
      context "given the dimension name as a symbol" do
        it "returns the Dimension subclass" do 
          DateDimension.to_dimension(:date).should == DateDimension
        end
      end
      context "given the Dimension subclass" do
        it "returns the Dimension subclass" do
          DateDimension.to_dimension(DateDimension).should == DateDimension
        end
      end
    end
    
    context "when called on the Dimension class" do
      context "given the dimension name as a symbol" do
        it "returns the Dimension subclass" do
          ActiveWarehouse::Dimension.to_dimension(:date).should == DateDimension
        end
      end
      
      context "given the Dimension class" do
        it "returns the dimension subclass" do
          ActiveWarehouse::Dimension.to_dimension(DateDimension).should == DateDimension
        end
      end
      
    end
  end

  describe "#foreign_key" do
    it "returns the name of the dimension's foreign key field in the fact table(s)" do
      DateDimension.foreign_key.should == "date_id"
    end
  end
  
  describe "#available_values" do
    it "returns the dimension values in order" do
      DateDimension.available_values(:calendar_year).should == ('2001'..'2008').to_a
    end
  end
  
  describe "#available_child_values" do
    context "given an empty array" do
      it "returns the values for the field at the hierarchy root" do
        DateDimension.available_child_values(:cy, []).should == ["2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008"]
      end
    end
    
    context "given a value in at the hierarchy root level" do
      it "returns the values for the children of that node" do
        DateDimension.available_child_values(:cy, ['2006']).should == ['Q1', 'Q2', 'Q3', 'Q4']
      end
    end

    context "given values two levels deep in the hierarchy" do
      it "returns the values for the children of that branch" do
        DateDimension.available_child_values(:cy, ['2006', 'Q1']).should == ['January', 'February', 'March']
      end
    end
  end

  # replaced original test based on Store dimension with one based on Date
  # in order to avoid creating/populating two dimension tables
  describe "#available_values_tree" do
    #TODO: why do we care?
    it "returns a value of 'All'" do
      root = DateDimension.available_values_tree(:cy)
      root.value.should == "All"
    end
  end
  
  describe "::Node#has_child?" do
    context "given a value for a child node that exists" do
      it "returns true" do
        root = DateDimension.available_values_tree(:cy)
        root.has_child?('2002').should be_true
      end
    end
  end
  
  describe "::Node#children" do  
    context "given a root node" do
      it "returns true" do
        root = DateDimension.available_values_tree(:cy)
        root.children.collect { |node| node.value}.should == ('2001'..'2008').to_a
      end  
    end
  end

  describe "#save" do
    it "doesn't raise an error when attributes changes are saved'" do
      space_odyssey = DateDimension.where(:calendar_year => '2001').first
      space_odyssey.calendar_year = '2010'
      expect { space_odyssey.save! }.to_not raise_error
    end
  end
    
  describe "#denominator_count" do
    # TODO: revisit the need for multiple examples in the two contexts below
    # including them all out of an abundance of caution, but feels like overkill
    context "given a hierarchy level to count distinct values of at a given level" do
      it "properly counts the number of possible values of children for that node" do
        DateDimension.denominator_count(:cy, :calendar_year, :calendar_quarter)["2002"].should == 4
        DateDimension.denominator_count(:cy, :calendar_year, :calendar_month_name)["2002"].should == 12
        DateDimension.denominator_count(:cy, :calendar_year, :calendar_week)["2002"].should == 52
        DateDimension.denominator_count(:cy, :calendar_year, :day_of_week)["2002"].should == 365
      end
    end
    
    context "given only a level at which to count values" do
      it "counts the number of values for that level at the most granular level" do
        DateDimension.denominator_count(:cy, :calendar_year)["2002"].should == 365
        DateDimension.denominator_count(:cy, :calendar_year)["2004"].should == 366
      end
    end
    
    context "given arguments that don't exist" do
      it "raises an ArgumentError when the level to be counted doesn't exist" do
        message = "The denominator level 'bogus_name' does not appear to exist"
        expect { DateDimension.denominator_count(:cy, :calendar_year, :bogus_name) }.to raise_error(ArgumentError, message)
      end
      
      it "raises an ArgumentError when the hierarchy for counting doesn't exist" do
        message = "The hierarchy 'bogus_name' does not exist in your dimension DateDimension"
        expect { DateDimension.denominator_count(:bogus_name, :calendar_year) }.to raise_error(ArgumentError, message)
      end
    end
      
    context "given a level to count that is below the base level" do
      message = "The index of the denominator level 'calendar_year' in the hierarchy 'cy' must be greater than or equal to the level 'calendar_month_name'"
      it "raises an ArgumentError with a useful message" do
        expect { DateDimension.denominator_count(:cy, :calendar_month_name, :calendar_year) }.to raise_error(ArgumentError, message)
      end
    end
  end
    
end
