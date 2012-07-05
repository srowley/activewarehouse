module ClassFactories
  
  def create_class(class_name, parent)
    Object.send(:remove_const, class_name) rescue nil
    Object.const_set class_name, Class.new(parent)
  end
  
  def create_date_dimension
    create_class("DateDimension", ActiveWarehouse::Dimension)
        
    ActiveRecord::Schema.define do
      create_table :date_dimension do |t| 
        t.column :calendar_year, :string, :null => false                      # 2005, 2006, 2007, etc.
        t.column :calendar_quarter, :string, :null => false, :limit => 2      # Q1, Q2, Q3 or Q4
        t.column :calendar_month_name, :string, :null => false, :limit => 9   # January, February, etc.
        t.column :calendar_week, :string, :null => false, :limit => 2         # 1, 2, 3, ... 52
        t.column :day_of_week, :string, :null => false, :limit => 9           # Monday, Tuesday, etc.
      end
    end
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
  
  def create_daily_sales_facts
    create_class("DailySalesFact", ActiveWarehouse::Fact)
    
    ActiveRecord::Schema.define do
      create_table :daily_sales_facts do |t|
        t.column :date_id, :integer
        t.column :store_id, :integer
        t.column :cost, :integer
      end
    end
  end
  
  def create_store_inventory_snapshot_fact
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
  
end
