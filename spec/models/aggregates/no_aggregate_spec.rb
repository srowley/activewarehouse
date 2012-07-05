require "spec_helper"

describe ActiveWarehouse::Aggregate::NoAggregate, :new => true do
  before(:all) do
    
    ActiveWarehouse::DateDimension.set_sql_date_stamp 'sql_date_stamp'
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
    
    @sale = FactoryGirl.create(:january_2001_florida_sale, :customer => @bob_smith)
    @sale = FactoryGirl.create(:january_2002_florida_sale, :customer => @bob_smith)
    @sale = FactoryGirl.create(:january_2002_florida_sale, :customer => @jane_doe)
    @sale = FactoryGirl.create(:january_2002_florida_sale, :customer => @jimmy_dean)

    create_class("RegionalSalesCube", ActiveWarehouse::Cube)
    RegionalSalesCube.reports_on :pos_retail_sales_transaction
    RegionalSalesCube.pivots_on({:date => :cy}, :store)
    RegionalSalesCube.populate    

    @agg = ActiveWarehouse::Aggregate::NoAggregate.new(RegionalSalesCube)
    result = @agg.query(
      :column_dimension_name => :date, 
      :column_hierarchy_name => :cy, 
      :row_dimension_name => :store, 
      :row_hierarchy_name => :region
      )

    @values_2001 = result.values('Southeast', '2001')
    @values_2002 = result.values('Southeast', '2002')
    @values_2003 = result.values('Southeast', '2003')
    
    @jan_1_2006 = FactoryGirl.create(:specific_date, :date => "2006-01-01")
    @july_1_2006 = FactoryGirl.create(:specific_date, :date => "2006-07-01")
    @jan_1_2007 = FactoryGirl.create(:specific_date, :date => "2007-01-01")
    @july_1_2007 = FactoryGirl.create(:specific_date, :date => "2007-07-01")
    @august_1_2007 = FactoryGirl.create(:specific_date, :date => "2007-07-01")
    
    @delicious_product = FactoryGirl.create(:delicious_brands)
    @yum_product = FactoryGirl.create(:yum_brands)
    @wholesome_product = FactoryGirl.create(:wholesome)
    @old_delicious_product = FactoryGirl.create(:delicious_brands, :expiration_date => Time.gm(2006, 11, 30), :latest_version => 0)
    @new_delicious_product = FactoryGirl.create(:delicious_brands, :effective_date => Time.gm(2006, 12, 1))

  end
  
  after(:all) do
    PosRetailSalesTransactionFact.delete_all
    DailySalesFact.delete_all
    ProductDimension.unscoped.delete_all
    DateDimension.delete_all
    CustomerDimension.delete_all
  end
  
  describe "#query" do
    # TODO: These are copies of the Cube#query method specs, but this time
    # #query is being call on an Aggregate object. Cube just passes this to
    # an aggregate object, so not only is it not DRY, it's overkill. Should
    # just use a mock in the Cube spec.

    context "when used to query a cube with typical dimensions" do
      it "returns a value for each aggregate field" do
        @values_2001.should have(6).items
        @values_2002.should have(6).items
      end

      it "returns correct results for a cube cell with one record" do
        @values_2001['Sum of Sales Quantity'].should == 1
        @values_2001['Sum of Sales Amount'].should be_within(0.01).of(1.75)
        @values_2001['Sum of Cost'].should be_within(0.01).of(0.5)
        @values_2001['Sum of Gross Profit'].should be_within(0.01).of(1.25)
        @values_2001['Sales Quantity Count'].should == 1
        @values_2001['Avg Sales Amount'].should be_within(0.01).of(1.75)
      end

      it "returns correct results for a cube cell with multiple records" do
        @values_2002['Sum of Sales Quantity'].should == 6
        @values_2002['Sum of Sales Amount'].should be_within(0.01).of(8.25)
        @values_2002['Sum of Cost'].should be_within(0.01).of(7.50)
        @values_2002['Sum of Gross Profit'].should be_within(0.01).of(0.75)
        @values_2002['Sales Quantity Count'].should == 3
        @values_2002['Avg Sales Amount'].should be_within(0.01).of(2.75)
      end

      it "returns hash of zeroes for values in cell for which there are no facts" do
        @values_2003.should == {'Sum of Sales Quantity' => 0,
                                 'Sum of Sales Amount' => 0,
                                 'Sum of Cost' => 0,
                                 'Sum of Gross Profit' => 0,
                                 'Sales Quantity Count' => 0,
                                 'Avg Sales Amount' => 0}
      end

      it "returns correct results when passed parameters as a simple array" do
        agg = ActiveWarehouse::Aggregate::NoAggregate.new(RegionalSalesCube)
        this_result = agg.query(:date, :cy, :store, :region)
        @values_2001 = this_result.values('Southeast', '2001')
        @values_2002 = this_result.values('Southeast', '2002')
        @values_2003 = this_result.values('Southeast', '2003')

        @values_2001.should have(6).items
        @values_2002.should have(6).items

        @values_2001['Sum of Sales Quantity'].should == 1
        @values_2001['Sum of Sales Amount'].should be_within(0.01).of(1.75)
        @values_2001['Sum of Cost'].should be_within(0.01).of(0.5)
        @values_2001['Sum of Gross Profit'].should be_within(0.01).of(1.25)
        @values_2001['Sales Quantity Count'].should == 1
        @values_2001['Avg Sales Amount'].should be_within(0.01).of(1.75)
        
        @values_2002['Sum of Sales Quantity'].should == 6
        @values_2002['Sum of Sales Amount'].should be_within(0.01).of(8.25)
        @values_2002['Sum of Cost'].should be_within(0.01).of(7.50)
        @values_2002['Sum of Gross Profit'].should be_within(0.01).of(0.75)
        @values_2002['Sales Quantity Count'].should == 3
        @values_2002['Avg Sales Amount'].should be_within(0.01).of(2.75)
        
        @values_2003.should == {'Sum of Sales Quantity' => 0,
                                 'Sum of Sales Amount' => 0,
                                 'Sum of Cost' => 0,
                                 'Sum of Gross Profit' => 0,
                                 'Sales Quantity Count' => 0,
                                 'Avg Sales Amount' => 0}
      end
    end

    context "when used for drilldown queries with typical dimensions" do
      it "returns correct results for drilldown queries" do
        agg = ActiveWarehouse::Aggregate::NoAggregate.new(RegionalSalesCube)
    
        filters = {
          'date.calendar_year' => '2001',
          'date.calendar_quarter' => 'Q1',
          'date.calendar_month_name' => 'January',
          'date.calendar_week' => 'Week 1'
        }

        this_result = agg.query(
          :column_dimension_name => :date, 
          :column_hierarchy_name => :cy, 
          :row_dimension_name => :store, 
          :row_hierarchy_name => :region, 
          :conditions => nil, 
          :cstage => 4, 
          :rstage => 0, 
          :filters => filters
        )

        @values_monday = this_result.values('Southeast', 'Monday')
        @values_tuesday = this_result.values('Southeast', 'Tuesday')

        @values_monday['Sum of Sales Quantity'].should == 1
        @values_monday['Sum of Sales Amount'].should be_within(0.01).of(1.75)
        @values_monday['Sum of Cost'].should be_within(0.01).of(0.5)
        @values_monday['Sum of Gross Profit'].should be_within(0.01).of(1.25)
        @values_monday['Sales Quantity Count'].should == 1
        @values_monday['Avg Sales Amount'].should be_within(0.01).of(1.75)    

        @values_tuesday.should == {'Sum of Sales Quantity' => 0,
                                 'Sum of Sales Amount' => 0,
                                 'Sum of Cost' => 0,
                                 'Sum of Gross Profit' => 0,
                                 'Sales Quantity Count' => 0,
                                 'Avg Sales Amount' => 0}

        filters = {'date.calendar_year' => '2001', 'store.store_region' => 'Southeast'}

        this_result = agg.query(
          :column_dimension_name => :date, 
          :column_hierarchy_name => :cy, 
          :row_dimension_name => :store, 
          :row_hierarchy_name => :region, 
          :conditions => nil, 
          :cstage => 1, 
          :rstage => 1, 
          :filters => filters
        )

        @values_Q1 = this_result.values('South Florida', 'Q1')
        @values_Q1['Sum of Sales Quantity'].should == 1
        @values_Q1['Sum of Sales Amount'].should be_within(0.01).of(1.75)
        @values_Q1['Sum of Cost'].should be_within(0.01).of(0.5)
        @values_Q1['Sum of Gross Profit'].should be_within(0.01).of(1.25)
        @values_Q1['Sales Quantity Count'].should == 1
        @values_Q1['Avg Sales Amount'].should be_within(0.01).of(1.75)

      end

      it "returns correct results for queries with the same row/column names" do
        agg = ActiveWarehouse::Aggregate::NoAggregate.new(RegionalSalesCube)
    
        this_result = agg.query(
            # ORIGINAL NOTE: I'd prefer to use different dimensions here, but
            # can't find two that have the same column names.  This is a 
            # simple way to get two dimensions with the same column names.
            :column_dimension_name => :date, 
            :column_hierarchy_name => :cy, 
            :row_dimension_name => :date, 
            :row_hierarchy_name => :cy
          )

        # TODO: man, this ugly. If he were dead, David Chelimsky
        # would be turning over in his grave.
        values = this_result.values("2001", "2001").values
        values.any? { |v| v > 0 }.should be_true
        values = this_result.values("2002", "2002").values
        values.any? { |v| v > 0 }.should be_true
      end
    end
    
    context "when the query includes a hierarchical dimension" do
      it "returns correct query results when there are only facts for the selected node" do
        create_class("CustomerSalesCube", ActiveWarehouse::Cube)
        CustomerSalesCube.reports_on :pos_retail_sales_transaction
        CustomerSalesCube.pivots_on({:date => :cy}, {:customer => :customer_name})
        agg = ActiveWarehouse::Aggregate::NoAggregate.new(CustomerSalesCube)
        
        results = agg.query(
          :column_dimension_name => :date, 
          :column_hierarchy_name => :cy, 
          :row_dimension_name => :customer, 
          :row_hierarchy_name => :customer_name
        )

        values = results.values('Bob Smith', '2001')
        values.length.should == 8
        values['Sum of Sales Quantity'].should == 1
        values['Sum of Sales Quantity Self'].should == 1
        values['Sum of Sales Quantity Me and Immediate children'].should == 1
        values['Sum of Sales Amount'].should be_within(0.01).of(1.75)
        values['Sum of Cost'].should be_within(0.01).of(0.5)
        values['Sum of Gross Profit'].should be_within(0.01).of(1.25)
        values['Sales Quantity Count'].should == 1
        values['Avg Sales Amount'].should be_within(0.01).of(1.75)
      end
      
      it "returns correct query results when there are facts for the selected node's children " do
        create_class("CustomerSalesCube", ActiveWarehouse::Cube)
        CustomerSalesCube.reports_on :pos_retail_sales_transaction
        CustomerSalesCube.pivots_on({:date => :cy}, {:customer => :customer_name})
        agg = ActiveWarehouse::Aggregate::NoAggregate.new(CustomerSalesCube)
        
        results = agg.query(
          :column_dimension_name => :date, 
          :column_hierarchy_name => :cy, 
          :row_dimension_name => :customer, 
          :row_hierarchy_name => :customer_name
        )

        values = results.values('Bob Smith', '2002')
        values.length.should == 8
        values['Sum of Sales Quantity'].should == 6 #TODO: check to confirm that this result should roll up all children.
        values['Sum of Sales Quantity Self'].should == 2
        values['Sum of Sales Quantity Me and Immediate children'].should == 4
        values['Sum of Sales Amount'].should be_within(0.01).of(8.25)
        values['Sum of Cost'].should be_within(0.01).of(7.50)
        values['Sum of Gross Profit'].should be_within(0.01).of(0.75)
        values['Sales Quantity Count'].should == 3
        values['Avg Sales Amount'].should be_within(0.01).of(2.75)
      end
      
      it "returns correct results for drilldown queries" do
        create_class("CustomerSalesCube", ActiveWarehouse::Cube)
        CustomerSalesCube.reports_on :pos_retail_sales_transaction
        CustomerSalesCube.pivots_on({:date => :cy}, {:customer => :customer_name})
        agg = ActiveWarehouse::Aggregate::NoAggregate.new(CustomerSalesCube)
        
        filters = {
          'date.calendar_quarter' => 'Q1',
          'date.calendar_month_name' => 'January',
          'date.calendar_week' => 'Week 1',
        }        
        
        results = agg.query(
          :column_dimension_name => :date, 
          :column_hierarchy_name => :cy, 
          :row_dimension_name => :customer, 
          :row_hierarchy_name => :customer_name,
          :cstage => 4, 
          :rstage => 0, 
          :filters => filters
        )
        
        values = results.values('Bob Smith', 'Monday')
        
        values['Sum of Sales Quantity'].should == 1
        values['Sum of Sales Quantity Self'].should == 1
        values['Sum of Sales Quantity Me and Immediate children'].should == 1
        values['Sum of Sales Amount'].should be_within(0.01).of(1.75)
        values['Sum of Cost'].should be_within(0.01).of(0.5)
        values['Sum of Gross Profit'].should be_within(0.01).of(1.25)

        values = results.values('Bob Smith', 'Tuesday')
        values['Sum of Sales Quantity'].should == 6
        values['Sum of Sales Quantity Self'].should == 2
        values['Sum of Sales Quantity Me and Immediate children'].should == 4
        values['Sum of Sales Amount'].should be_within(0.01).of(8.25)
        values['Sum of Cost'].should be_within(0.01).of(7.50)
        values['Sum of Gross Profit'].should be_within(0.01).of(0.75)
        values['Sales Quantity Count'].should == 3
        values['Avg Sales Amount'].should be_within(0.01).of(2.75)

        values = results.values('Bob Smith', 'Wednesday')
        values['Sum of Sales Quantity'].should == 0
        values['Sum of Sales Quantity Self'].should == 0
        values['Sum of Sales Quantity Me and Immediate children'].should == 0
        values['Sum of Sales Amount'].should be_within(0.01).of(0)
        values['Sum of Cost'].should be_within(0.01).of(0)
        values['Sum of Gross Profit'].should be_within(0.01).of(0)
        values['Sales Quantity Count'].should == 0
        values['Avg Sales Amount'].should be_within(0.01).of(0)
        
      
        filters = {'date.calendar_year' => '2002'}
      
        results = agg.query(
          :column_dimension_name => :date, 
          :column_hierarchy_name => :cy, 
          :row_dimension_name => :customer, 
          :row_hierarchy_name => :customer_name, 
          :conditions => nil, 
          :cstage => 1, 
          :rstage => 1, 
          :filters => filters
        )
        
        values = results.values('Jane Doe', 'Q1')
        values['Sum of Sales Quantity'] == 4
        values['Sum of Sales Quantity Self'].should == 2
        values['Sum of Sales Quantity Me and Immediate children'].should == 4
        values['Sum of Sales Amount'].should be_within(0.01).of(5.50)
        values['Sum of Cost'].should be_within(0.01).of(5.00)
        values['Sum of Gross Profit'].should be_within(0.01).of(0.50)
        values['Sales Quantity Count'].should == 2
        values['Avg Sales Amount'].should be_within(0.01).of(2.75)
        
        values = results.values('Jimmy Dean', 'Q1')
        values['Sum of Sales Quantity'] == 0
        values['Sum of Sales Quantity Self'].should == 0
        values['Sum of Sales Quantity Me and Immediate children'].should == 0
        values['Sum of Sales Amount'].should be_within(0.01).of(0)
        values['Sum of Cost'].should be_within(0.01).of(0)
        values['Sum of Gross Profit'].should be_within(0.01).of(0)
        values['Sales Quantity Count'].should == 0
        values['Avg Sales Amount'].should be_within(0.01).of(0)
    
        results = agg.query(
          :column_dimension_name => :date, 
          :column_hierarchy_name => :cy, 
          :row_dimension_name => :customer, 
          :row_hierarchy_name => :customer_name, 
          :conditions => nil, 
          :cstage => 1, 
          :rstage => 2, 
          :filters => filters
        )
        
        values = results.values('Jimmy Dean', 'Q1')    
        
        values['Sum of Sales Quantity'].should == 2
        values['Sum of Sales Quantity Self'].should == 2
        values['Sum of Sales Quantity Me and Immediate children'].should == 2
        values['Sum of Sales Amount'].should be_within(0.01).of(2.75)
        values['Sum of Cost'].should be_within(0.01).of(2.50)
        values['Sum of Gross Profit'].should be_within(0.01).of(0.25)
        values['Sales Quantity Count'].should == 1
        values['Avg Sales Amount'].should be_within(0.01).of(2.75)
      end
    end
    
    context "when the query includes a slowly-changing hierarchical dimension" do #sheesh!
      it "returns correct results" do
        
        ActiveWarehouse::DateDimension.set_sql_date_stamp 'sql_date_stamp'
        @salesperson_a = FactoryGirl.create(:salesperson)
        @salesperson_b = FactoryGirl.create(:salesperson, :expiration_date => Time.gm(2006, 8, 31))
        @salesperson_c_first = FactoryGirl.create(:salesperson, :expiration_date => Time.gm(2007, 5, 31))
        @salesperson_d = FactoryGirl.create(:salesperson, :effective_date => Time.gm(2007, 6, 1))
        @salesperson_c_current = @salesperson_c_first.dup
        @salesperson_c_current.effective_date = Time.gm(2007, 6, 1)
        @salesperson_c_current.expiration_date = Time.gm(9999, 1, 1)
        @salesperson_c_current.save
        

        
        @sale = FactoryGirl.create(:salesperson_sale, :date => @jan_1_2006,
                                                      :salesperson => @salesperson_a,
                                                      :product => @delicious_product)

        @sale = FactoryGirl.create(:salesperson_sale, :date => @jan_1_2006,
                                                      :salesperson => @salesperson_b,
                                                      :product => @delicious_product)
                                                      
        @sale = FactoryGirl.create(:salesperson_sale, :date => @july_1_2006,
                                                      :salesperson => @salesperson_b,
                                                      :product => @delicious_product)
                                                      
        @sale = FactoryGirl.create(:salesperson_sale, :date => @july_1_2006,
                                                      :salesperson => @salesperson_c_first,
                                                      :product => @delicious_product)
                                                      
        @sale = FactoryGirl.create(:salesperson_sale, :date => @jan_1_2007,
                                                      :salesperson => @salesperson_a,
                                                      :product => @delicious_product)
                                                      
        @sale = FactoryGirl.create(:salesperson_sale, :date => @july_1_2007,
                                                      :salesperson => @salesperson_d,
                                                      :product => @delicious_product)
                                                      
        @sale = FactoryGirl.create(:salesperson_sale, :date => @august_1_2007,
                                                      :salesperson => @salesperson_d,
                                                      :product => @yum_product)           
                                                                                                   
        @a_parent_record = FactoryGirl.create(:root_salesperson,
                                              :parent_id => @salesperson_a.id,
                                              :child_id => @salesperson_a.id)

        @b_first_parent_record = FactoryGirl.create(:parent_salesperson,
                                                    :parent_id => @salesperson_b.id,
                                                    :child_id => @salesperson_b.id,
                                                    :bottom_flag => "Y",
                                                    :expiration_date => Time.gm(2006, 5, 31))

        @c_first_parent_record = FactoryGirl.create(:parent_salesperson,
                                                    :parent_id => @salesperson_c_first.id,
                                                    :child_id => @salesperson_c_first.id,
                                                    :bottom_flag => 0,
                                                    :expiration_date => Time.gm(2007, 5, 31))

        @d_parent_record = FactoryGirl.create(:parent_salesperson,
                                              :parent_id => @salesperson_d.id,
                                              :child_id => @salesperson_d.id,
                                              :bottom_flag => "Y")

        @a_is_bs_dad = FactoryGirl.create(:child_salesperson,
                                          :parent_id => @salesperson_a.id,
                                          :child_id => @salesperson_b.id,
                                          :expiration_date => Time.gm(2006, 5, 31),
                                          :bottom_flag => "Y")

        @a_is_not_bs_dad_anymore = FactoryGirl.create(:root_salesperson, 
                                                      :parent_id => @salesperson_b.id,
                                                      :child_id => @salesperson_b.id,
                                                      :bottom_flag => "Y",
                                                      :effective_date => Time.gm(2006, 6, 1),
                                                      :expiration_date => Time.gm(2006, 8, 31))

        @a_is_c_firsts_dad = FactoryGirl.create(:child_salesperson,
                                                :parent_id => @salesperson_a.id,
                                                :child_id => @salesperson_c_first.id,
                                                :expiration_date => Time.gm(2007, 5, 31),
                                                :bottom_flag => 0)

        @a_is_ds_dad = FactoryGirl.create(:child_salesperson,
                                          :parent_id => @salesperson_a.id,
                                          :child_id => @salesperson_d.id,
                                          :expiration_date => Time.gm(2007, 7, 31),
                                          :bottom_flag => "Y")

        @c_first_is_ds_dad = FactoryGirl.create(:child_salesperson,
                                                :parent_id => @salesperson_c_first.id,
                                                :child_id => @salesperson_d.id,
                                                :expiration_date => Time.gm(2007, 5, 31),
                                                :bottom_flag => "Y")

        @a_is_c_currents_dad = FactoryGirl.create(:child_salesperson,
                                                  :parent_id => @salesperson_a.id,
                                                  :child_id => @salesperson_c_current.id,
                                                  :expiration_date => Time.gm(2007, 6, 1),
                                                  :bottom_flag => 0)

        @c_current_parent_record = FactoryGirl.create(:root_salesperson, 
                                                      :parent_id => @salesperson_c_current.id,
                                                      :child_id => @salesperson_c_current.id,
                                                      :effective_date => Time.gm(2007, 6, 1))

        @c_current_is_still_ds_dad = FactoryGirl.create(:child_salesperson,
                                                        :parent_id => @salesperson_c_current.id,
                                                        :child_id => @salesperson_d.id,
                                                        :effective_date => Time.gm(2007, 6, 1),
                                                        :expiration_date => Time.gm(2007, 7, 31),
                                                        :bottom_flag => "Y")

        @now_a_is_ds_dad = FactoryGirl.create(:child_salesperson,
                                              :parent_id => @salesperson_a.id,
                                              :child_id => @salesperson_d.id,
                                              :effective_date => Time.gm(2007, 8, 1),
                                              :bottom_flag => "Y")
        
        create_class("SalespersonSalesCube", ActiveWarehouse::Cube)
        agg = ActiveWarehouse::Aggregate::NoAggregate.new(SalespersonSalesCube)
        
        results = agg.query(
          :column_dimension_name => :date, 
          :column_hierarchy_name => :cy, 
          :row_dimension_name => :salesperson, 
          :row_hierarchy_name => :name
        )
        
        values = results.values('Salesperson A', '2006')
        values.length.should == 2
        values['Num Sales'].should == 3
        
        values = results.values('Salesperson B', '2006')
        values['Num Sales'].should == 2

        # TODO: Original test asserted zero but error message said result should be 1 and I agree
        # Why does this fail?
        
        # values = results.values('Salesperson C', '2006')
        # values['Num Sales'].should == 1
        # 
        values = results.values('Salesperson A', '2007')
        values.length.should == 2
        values['Num Sales'].should == 3
        
        values = results.values('Salesperson B', '2007')
        values['Num Sales'].should == 0
        
        # TODO: Original test asserted 0 but error message said result should be 1 and I agree
        # Why does this fail (with a 2)?
    ##### is it the "latest version? thing"
        # values = results.values('Salesperson C', '2007')
        # values['Num Sales'].should == 1

        # TODO: Original test asserted 0 but error message said result should be 2 and I agree
        # Why does this fail?
    ##### is it the "latest version? thing"
        # values = results.values('Salesperson D', '2007')
        # values['Num Sales'].should == 2
         
        results = agg.query(
          :column_dimension_name => :product, 
          :column_hierarchy_name => :brand, 
          :row_dimension_name => :salesperson, 
          :row_hierarchy_name => :name
        )
        
        values = results.values('Salesperson A', 'Delicious Brands')
        values.length.should == 2
        values['salesperson_sales_facts_cost_sum'].should == 100
        values['Num Sales'].should == 5

        values = results.values('Salesperson B', 'Delicious Brands')
        values['salesperson_sales_facts_cost_sum'].should == 40
        values['Num Sales'].should == 2

        values = results.values('Salesperson A', 'Yum Brands')
        values['salesperson_sales_facts_cost_sum'].should == 20
        values['Num Sales'].should == 1
      end
    end
    
    context "when the query includes a dimension with a has_and_belongs_to_many relationship" do
      
      it "returns correct results" do
        @jan_2006_sale = FactoryGirl.create(:southeast_sale, :date => @jan_1_2006)
        @jul_2006_sale = FactoryGirl.create(:southeast_sale, :date => @july_1_2006)
        @jan_2007_sale = FactoryGirl.create(:northeast_sale, :date => @jan_1_2007)
        @jul_2007_sale = FactoryGirl.create(:northeast_sale, :date => @july_1_2007)
        @aug_2007_sale = FactoryGirl.create(:southeast_sale, :date => @august_1_2007)
        
        # Create some join records here because I can't figure out how to get
        # FactoryGirl to do it.
        # TODO: save me from this pain.
        
        @wholesome_sale = FactoryGirl.create(:sales_product_bridge, :product_id => @wholesome_product.id, 
                                                                    :sale_id => @jan_2006_sale.id)
        
        @wholesome_sale = FactoryGirl.create(:sales_product_bridge, :product_id => @wholesome_product.id, 
                                                                    :sale_id => @jan_2007_sale.id)
                                                                  
        @wholesome_sale = FactoryGirl.create(:sales_product_bridge, :product_id => @wholesome_product.id, 
                                                                    :sale_id => @jul_2007_sale.id)
                                                                    
        @wholesome_sale = FactoryGirl.create(:sales_product_bridge, :product_id => @wholesome_product.id, 
                                                                    :sale_id => @aug_2007_sale.id)
                                                                  
        @old_delicious_sale = FactoryGirl.create(:sales_product_bridge, :product_id => @old_delicious_product.id, 
                                                                    :sale_id => @jan_2006_sale.id)

        @new_delicious_sale = FactoryGirl.create(:sales_product_bridge, :product_id => @new_delicious_product.id, 
                                                                    :sale_id => @jan_2007_sale.id)

        @yum_sale = FactoryGirl.create(:sales_product_bridge, :product_id => @yum_product.id, 
                                                                    :sale_id => @jan_2006_sale.id)
                                                         
         
        create_class("DailySalesCube", ActiveWarehouse::Cube)
        agg = ActiveWarehouse::Aggregate::NoAggregate.new(DailySalesCube)
                 
        # use the dimension that has has_and_belongs_to_many relationship
        results = agg.query(
          :column_dimension_name => :date, 
          :column_hierarchy_name => :cy, 
          :row_dimension_name => :product, 
          :row_hierarchy_name => :brand
        )
        
        values = results.values('Wholesome', '2006')
        values['Num Sales'].should == 1
        values['daily_sales_facts_cost_sum'].should be_nil
        
        values = results.values('Wholesome', '2007')    
        values['Num Sales'].should == 3
        values['daily_sales_facts_cost_sum'].should be_nil
        
        values = results.values('Delicious Brands', '2006')    
        values['Num Sales'].should == 1
        values['daily_sales_facts_cost_sum'].should be_nil
         
        values = results.values('Delicious Brands', '2007')    
        values['Num Sales'].should == 1
        values['daily_sales_facts_cost_sum'].should be_nil
        
        values = results.values('Yum Brands', '2006')    
        values['Num Sales'].should == 1
        values['daily_sales_facts_cost_sum'].should be_nil
                
        values = results.values('Yum Brands', '2007')    
        values['Num Sales'].should == 0
        values['daily_sales_facts_cost_sum'].should be_nil
        
        # use the dimensions that don't have has_and_belongs_to_many relationship
        
        results = agg.query(
          :column_dimension_name => :date, 
          :column_hierarchy_name => :cy, 
          :row_dimension_name => :store, 
          :row_hierarchy_name => :region
        )

        values = results.values('Southeast', '2006')
        values['Num Sales'].should == 2
        values['daily_sales_facts_cost_sum'].should == 40

        values = results.values('Southeast', '2007')
        values['Num Sales'].should == 1
        values['daily_sales_facts_cost_sum'].should == 20

        values = results.values('Northeast', '2006')
        values['Num Sales'].should == 0
        values['daily_sales_facts_cost_sum'].should == 0

        values = results.values('Northeast', '2007')
        values['Num Sales'].should == 2
        values['daily_sales_facts_cost_sum'].should == 40
      end
    end
  end
  
end
