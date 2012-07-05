FactoryGirl.define do
  factory :base_product, :class => ProductDimension do
    sku_number "00399494302"
    latest_version 1
    effective_date Time.gm(2006, 1, 1)
    expiration_date Time.gm(9999, 1, 1)
    
    factory :delicious_brands, :class => ProductDimension do
      department_description "Snack Foods"
      brand_description "Delicious Brands"
      product_description "Crunchy Chips"
    end

    factory :yum_brands, :class => ProductDimension do
      department_description "Snack Foods"
      brand_description "Yum Brands"
      product_description "Wingdings"
    end

    factory :wholesome, :class => ProductDimension do
      department_description "Bakery"
      brand_description "Wholesome"
      product_description "Low Fat White Bread"
    end
  end
end