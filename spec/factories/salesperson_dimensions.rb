FactoryGirl.define do
  
  factory :salesperson, :class => SalespersonDimension do
    sequence(:name) { |n| "Salesperson #{('A'..'Z').to_a[n - 1]}" }
    region "North America"
    effective_date Time.gm(2006, 1, 1)
    expiration_date Time.gm(9999, 1, 1) 
  end
  
end

# Salesperson A,World,World,2006-01-01,9999-01-01
# Salesperson B,Asia Pacific,Hawaii,2006-01-01,2006-08-31
# Salesperson C,North America,Mexico,2006-01-01,2007-05-31
# Salesperson D,North America,Canada,2007-06-01,9999-01-01
# Salesperson C,North America,United States,2007-06-01,9999-01-01

# :name, :string
# :region, :string
# :sub_region, :string
# :effective_date,:datetime
# :expiration_date, :datetime