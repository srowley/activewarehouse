FactoryGirl.define do
  factory :january_2001_florida_sale, :class => PosRetailSalesTransactionFact do
    association :date, factory: :specific_date
    association :store, factory: :florida_store
    promotion
    association :product, factory: :base_product
    customer
    sales_quantity 1
    sales_dollar_amount 1.75
    cost_dollar_amount 0.5
    gross_profit_dollar_amount 1.25
  end
  
  factory :january_2002_florida_sale, :class => PosRetailSalesTransactionFact do
    association :date, factory: :specific_date, :date => "2002-01-01"
    association :store, factory: :florida_store
    promotion
    association :product, factory: :base_product
    customer
    sales_quantity 2
    sales_dollar_amount 2.75
    cost_dollar_amount 2.5
    gross_profit_dollar_amount 0.25
  end
                          
end