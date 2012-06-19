FactoryGirl.define do
  factory :product_dimension do
    product_description Faker::Product.product
    sku_number Faker.numerify("#########")
    brand_description Faker::Product.brand
    department_description "Fakery Department"
    latest_version 1
    effective_date Time.gm(2006, 1, 1)
    expiration_date Time.gm(9999, 1, 1)
  end
end