FactoryGirl.define do
  factory :salesperson_sale, :class => SalespersonSalesFact do
    association :date, factory: :specific_date
    association :salesperson, factory: :florida_store
    association :product, factory: :base_product
    cost 20
  end
                              
end