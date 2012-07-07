require "spec_helper"

describe ActiveWarehouse::Aggregate::PipelinedRolapAggregate do
  
  before(:all) do
    create_class("RollupSalesTransactionsCube", ActiveWarehouse::Cube)
    RollupSalesTransactionsCube.aggregate_class ActiveWarehouse::Aggregate::PipelinedRolapAggregate, 
                                              {:truncate=>false, :new_records_only=>{:dimension => :date}}

    RollupSalesTransactionsCube.reports_on :pos_retail_sales_transaction
    RollupSalesTransactionsCube.pivots_on({:date=>:cy}, {:store=>:region}, {:product=>:product_id})

    @aggregate = RollupSalesTransactionsCube.aggregate
    
  end
  
  describe "#initialize" do
    it "returns something" do
      RollupSalesTransactionsCube.aggregate.should be_true
    end
  end

  describe "#aggregate_dimension_fields" do
    it "doesn't really have a test put there's the output above" do
      cols = @aggregate.aggregate_dimension_fields
      cols.each{|d,cols| cols.each{|c| puts "#{d.name} #{c.name} #{c.type}"}}
    end
  end

  describe "#aggregated_fact_column_sql" do
    it "returns something, and here's some output above" do
      sql = @aggregate.aggregated_fact_column_sql
      puts sql
      sql.should be_true
    end
  end
  
  describe "#tables_and_joins" do
    it "returns something, and here's some output above" do
      sql = @aggregate.tables_and_joins
      puts sql
      sql.should be_true
    end
  end  
  
  describe "#populate" do
    it "returns something (but only for MySQL, otherwise error)" do
      if PosRetailSalesTransactionFact.connection_config[:adapter] == 'mysql'
        RollupSalesTransactionsCube.populate.should be_true
      end
    end
  end
  
  
  # def test_query
  # 
  #   filters = {
  #     'date.calendar_year' => '2001',
  #     'store.store_region'=>'Northeast'
  #   }
  # 
  #   cube = RollupSalesTransactionsCube.new
  #   results = cube.query(
  #     :column => :date, 
  #     :row => :product,
  #     :cstage => 3, 
  #     :rstage => 0,
  #     :filters => filters,
  #     :conditions => nil
  #   )
  #   
  #   puts results.inspect
  #   
  # end
  # 
  # def test_query_super
  # 
  #   filters = {
  #     'date.calendar_year' => '2001'
  #   }
  # 
  #   cube = RollupSalesTransactionsCube.new
  #   results = cube.query(
  #     :column_dimension_name => :date,
  #     :column_hierarchy_name => :cy,
  #     :row_dimension_name => :product,
  #     :row_hierarchy_name => :brand,
  #     :cstage => 3, 
  #     :rstage => 0,
  #     :filters => filters,
  #     :conditions => nil
  #   )
  #   
  #   puts results.inspect
  #   
  # end
end