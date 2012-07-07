def set_up_classes
  model_date_dimension
  model_pos_retail_sales_transaction_fact
  model_product_dimension
  create_promotion_dimension
  model_store_dimension
  model_customer_dimension
  model_daily_sales_facts
  model_store_inventory_snapshot_fact
  model_customer_hierarchy_bridge
  model_salesperson_sales_facts
  model_salesperson_dimension
  model_salesperson_hierarchy_bridge
  create_sales_products_bridge
end


def create_date_dimension
  create_class("DateDimension", ActiveWarehouse::DateDimension)
      
  ActiveRecord::Schema.define do
    create_table :date_dimension do |t| 
      t.column :date, :string, :null => false                               # 2005, 2006, 2007, etc.
      t.column :calendar_year, :string, :null => false                      # 2005, 2006, 2007, etc.
      t.column :calendar_quarter, :string, :null => false, :limit => 2      # Q1, Q2, Q3 or Q4
      t.column :calendar_month_name, :string, :null => false, :limit => 9   # January, February, etc.
      t.column :calendar_week, :string, :null => false, :limit => 7         # Week 1, Week 2,... Week 52
      t.column :day_of_week, :string, :null => false, :limit => 9           # Monday, Tuesday, etc.
      t.column :sql_date_stamp, :date
    end
  end
end

def model_date_dimension
  create_date_dimension  
  DateDimension.set_order :sql_date_stamp
  DateDimension.define_hierarchy :cy, [:calendar_year, :calendar_quarter, :calendar_month_name, :calendar_week, :day_of_week]
  DateDimension.define_hierarchy :fy, [:fiscal_year, :fiscal_quarter, :calendar_month_name, :fiscal_week, :day_of_week]
  DateDimension.define_hierarchy :rollup, [:calendar_year, :calendar_month_number_in_year, :calendar_week_start_date, :sql_date_stamp]
end

def create_pos_retail_sales_transaction_facts
  create_class("PosRetailSalesTransactionFact", ActiveWarehouse::Fact)
  
  ActiveRecord::Schema.define do
    create_table :pos_retail_sales_transaction_facts do |t| 
      t.column :date_id, :integer
      t.column :product_id, :integer
      t.column :store_id, :integer
      t.column :promotion_id, :integer
      t.column :customer_id, :integer
      t.column :pos_transaction_number, :string
      t.column :sales_quantity, :integer
      t.column :sales_dollar_amount, :float
      t.column :cost_dollar_amount, :float
      t.column :gross_profit_dollar_amount, :float
    end
  end
end

def model_pos_retail_sales_transaction_fact
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

def create_product_dimension
  create_class("ProductDimension", ActiveWarehouse::Dimension)
  
  ActiveRecord::Schema.define do
    create_table :product_dimension do |t|
      t.column :product_id, :integer
      t.column :product_description, :string
      t.column :sku_number, :string
      t.column :brand_description, :string
      t.column :category_description, :string
      t.column :department_description, :string
      t.column :package_type_description, :string
      t.column :package_size, :string
      t.column :fat_content, :string
      t.column :diet_type, :string
      t.column :weight, :integer
      t.column :weight_units_of_measure, :string
      t.column :storage_type, :string
      t.column :shelf_life_type, :string
      t.column :shelf_width, :string
      t.column :shelf_height, :string
      t.column :shelf_depth, :string
      t.column :latest_version, :boolean
      t.column :effective_date, :datetime
      t.column :expiration_date, :datetime
    end
  end
end

def model_product_dimension
  create_product_dimension
#  create_class("DailySalesFact", ActiveWarehouse::Fact)
  ProductDimension.acts_as_slowly_changing_dimension
  ProductDimension.define_hierarchy :brand, [:brand_description]
# ProductDimension.has_and_belongs_to_many :sales, :class_name => DailySalesFact,
#                        :join_table => 'sales_products_bridge', :association_foreign_key => 'sale_id'
  
end

def create_promotion_dimension
  create_class("PromotionDimension", ActiveWarehouse::Dimension)
  
  ActiveRecord::Schema.define do
    create_table :promotion_dimension do |t|
      t.column :promotion_name, :string
      t.column :price_reduction_type, :string
      t.column :promotion_media_type, :string
      t.column :ad_type, :string
      t.column :display_type, :string
      t.column :coupon_type, :string
      t.column :ad_media_name, :string
      t.column :display_provider, :string
      t.column :promotion_cost, :integer
      t.column :promotion_begin_date, :integer # FK with date_dimension view
      t.column :promotion_end_date, :integer # FK with date_dimension view
    end
  end
end

def create_store_dimension
  create_class("StoreDimension", ActiveWarehouse::Dimension)
  
  ActiveRecord::Schema.define do
    create_table :store_dimension do |t|
      t.column :store_name, :string
      t.column :store_number, :string
      t.column :store_street_address, :string
      t.column :store_city, :string
      t.column :store_county, :string
      t.column :store_state, :string
      t.column :store_zip_code, :string
      t.column :store_manager, :string
      t.column :store_district, :string
      t.column :store_region, :string
      t.column :first_open_date, :integer # FK with view on date_dimension
      t.column :last_remodal_date, :integer # FK with view on date_dimension
    end
  end
end

def model_store_dimension
  create_store_dimension
  StoreDimension.define_hierarchy :location, [:store_state, :store_county, :store_city]
  StoreDimension.define_hierarchy :region, [:store_region, :store_district]
end

def create_customer_dimension
  create_class("CustomerDimension", ActiveWarehouse::Dimension)
  ActiveRecord::Schema.define do
    create_table :customer_dimension do |t|
      t.column :customer_name, :string
    end
  end
end

def model_customer_dimension
  create_customer_dimension
  CustomerDimension.acts_as_hierarchical_dimension
  CustomerDimension.define_hierarchy :customer_name, [:customer_name]
  CustomerDimension.child_bridge :child_bridge
  CustomerDimension.parent_bridge :parent_bridge
end

def create_daily_sales_fact
  create_class("DailySalesFact", ActiveWarehouse::Fact)
  ActiveRecord::Schema.define do
    create_table :daily_sales_facts do |t|
      t.column :date_id, :integer
      t.column :store_id, :integer
      t.column :cost, :integer
    end
  end
end

def model_daily_sales_facts
  create_daily_sales_fact
  DailySalesFact.aggregate :cost
  DailySalesFact.aggregate :id, :type => :count, :distinct => true, :label => 'Num Sales'
  DailySalesFact.dimension :date
  DailySalesFact.dimension :store
  DailySalesFact.has_and_belongs_to_many_dimension :product, 
                         :join_table => 'sales_products_bridge', :foreign_key => 'sale_id'
end                       
                       
def create_store_inventory_snapshot_facts
  create_class("StoreInventorySnapshotFact", ActiveWarehouse::Fact)

  ActiveRecord::Schema.define do
    create_table :store_inventory_snapshot_facts do |t|
      t.column :date_id, :integer
      t.column :product_id, :integer
      t.column :store_id, :integer
      t.column :quantity_on_hand, :integer
      t.column :quantity_sold, :integer
      t.column :dollar_value_at_cost, :decimal, :scale => 2, :precision => 18
      t.column :dollar_value_at_latest_selling_price, :decimal, :scale => 2, :precision => 18
    end
  end
end
              
def model_store_inventory_snapshot_fact
  create_store_inventory_snapshot_facts
  StoreInventorySnapshotFact.aggregate :quantity_on_hand, :semiadditive => :date, :label => 'Sum Quantity on Hand'
  StoreInventorySnapshotFact.aggregate :quantity_sold, :label => 'Sum Quantity Sold'
  StoreInventorySnapshotFact.aggregate :dollar_value_at_cost, :label => 'Sum Dollar Value At Cost'
  StoreInventorySnapshotFact.aggregate :dollar_value_at_latest_selling_price, :label => 'Sum Value At Latest Price'
 
  StoreInventorySnapshotFact.calculated_field (:gmroi) do |r| 
    (r.quantity_sold * (r.dollar_value_at_latest_selling_price - r.dollar_value_at_cost)) / 
    (r.quantity_on_hand * r.dollar_value_at_latest_selling_price)
  end
 
  StoreInventorySnapshotFact.dimension :date
  StoreInventorySnapshotFact.dimension :store
  StoreInventorySnapshotFact.dimension :product
end

def create_customer_hierarchy_bridge
  create_class("CustomerHierarchyBridge", ActiveWarehouse::HierarchyBridge)
  ActiveRecord::Schema.define do
    create_table :customer_hierarchy_bridge do |t|
      t.column :parent_id, :integer
      t.column :child_id, :integer
      t.column :num_levels_from_parent, :integer
      t.column :bottom_flag, :string
      t.column :is_top, :string
    end
  end
end

def model_customer_hierarchy_bridge
  create_customer_hierarchy_bridge
  CustomerHierarchyBridge.set_top_flag_value 'Y'
end

def create_salesperson_sales_facts
  create_class("SalespersonSalesFact", ActiveWarehouse::Fact)
  ActiveRecord::Schema.define do
    create_table :salesperson_sales_facts do |t|
      t.column :date_id, :integer
      t.column :product_id, :integer
      t.column :salesperson_id, :integer
      t.column :cost, :integer
    end
  end
end

def model_salesperson_sales_facts
  create_salesperson_sales_facts
  SalespersonSalesFact.aggregate :cost
  SalespersonSalesFact.aggregate :cost, :type => :count, :label => 'Num Sales'
  
  SalespersonSalesFact.dimension :date
  SalespersonSalesFact.dimension :salesperson, :slowly_changing => :date
  SalespersonSalesFact.dimension :product
end

def create_salesperson_dimension
  create_class("SalespersonDimension", ActiveWarehouse::Dimension)
  ActiveRecord::Schema.define do
    create_table :salesperson_dimension do |t|
      t.column :name, :string
      t.column :region, :string
      t.column :sub_region, :string
      t.column :effective_date,:datetime
      t.column :expiration_date, :datetime
    end
  end
end

def model_salesperson_dimension
  create_salesperson_dimension
  SalespersonDimension.acts_as_hierarchical_dimension
  SalespersonDimension.acts_as_slowly_changing_dimension
  SalespersonDimension.define_hierarchy :name, [:name]
  SalespersonDimension.define_hierarchy :region, [:region, :sub_region]
  SalespersonDimension.child_bridge :child_bridge
  SalespersonDimension.parent_bridge :parent_bridge
end

def create_salesperson_hierarchy_bridge
  create_class("SalespersonHierarchyBridge", ActiveWarehouse::HierarchyBridge)
  ActiveRecord::Schema.define do
    create_table :salesperson_hierarchy_bridge do |t|
      t.column :parent_id, :integer
      t.column :child_id, :integer
      t.column :num_levels_from_parent, :integer
      t.column :effective_date, :datetime
      t.column :expiration_date, :datetime
      t.column :bottom_flag, :string
      t.column :is_top, :string
    end
  end
end

def model_salesperson_hierarchy_bridge
  create_salesperson_hierarchy_bridge
  SalespersonHierarchyBridge.set_top_flag_value 'Y'
end

def create_sales_products_bridge
  create_class("SalesProductsBridge", ActiveWarehouse::Bridge)
  ActiveRecord::Schema.define do
    create_table :sales_products_bridge, :id => false do |t|
      t.column :sale_id, :integer
      t.column :product_id, :integer
    end
  end
end


def create_class(class_name, parent)
  Object.send(:remove_const, class_name) rescue nil
  Object.const_set class_name, Class.new(parent)
end