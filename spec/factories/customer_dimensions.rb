FactoryGirl.define do
    
  factory :customer, :class => CustomerDimension do
    customer_name Faker::Name.name
  end
  
end