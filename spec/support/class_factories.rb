module ClassFactories
  
  def create_class(class_name, parent)
    Object.send(:remove_const, class_name) rescue nil
    Object.const_set class_name, Class.new(parent)
  end
  
  def create_date_dimension
    ActiveRecord::Schema.define(:version => 1) do
      create_table :date_dimension do |t| 
        t.column :calendar_year, :string, :null => false                      # 2005, 2006, 2007, etc.
        t.column :calendar_quarter, :string, :null => false, :limit => 2      # Q1, Q2, Q3 or Q4
        t.column :calendar_month_name, :string, :null => false, :limit => 9   # January, February, etc.
        t.column :calendar_week, :string, :null => false, :limit => 2         # 1, 2, 3, ... 52
        t.column :day_of_week, :string, :null => false, :limit => 9           # Monday, Tuesday, etc.
      end
    end

    create_class("DateDimension", ActiveWarehouse::Dimension)
    
  end
  
end
