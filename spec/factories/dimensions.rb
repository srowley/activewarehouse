ActiveRecord::Schema.define(:version => 1) do
  create_table :date_dimension do |t| 
    t.column :calendar_year, :string, :null => false                      # 2005, 2006, 2007, etc.
    t.column :calendar_quarter, :string, :null => false, :limit => 2      # Q1, Q2, Q3 or Q4
    t.column :calendar_month_name, :string, :null => false, :limit => 9   # January, February, etc.
    t.column :calendar_week, :string, :null => false, :limit => 2         # 1, 2, 3, ... 52
    t.column :day_of_week, :string, :null => false, :limit => 9           # Monday, Tuesday, etc.
  end
end

DateDimension = Class.new(ActiveWarehouse::Dimension)
DateDimension.delete_all

FactoryGirl.define do
  # sequence :date do |n|
  #   Date.new(2001,1,1) + n.days
  # end

  factory :date_dimension do
    # calendar_year { generate(:date).strftime("%Y")}
    # calendar_quarter { generate(:date).strftime("%m")}
    # calendar_month_name { "Q#{(generate(:date).strftime("%B").to_i / 3).to_i + 1}" }
    # calendar_week { generate(:date).strftime("%U")}
    # day_of_week { generate(:date).strftime("%A")}
  end
    
end