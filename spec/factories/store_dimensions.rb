FactoryGirl.define do
  
  factory :florida_store, :class => StoreDimension do
    store_name "Store 1"
    store_number "Store 1"
    store_street_address "101 SW 1st Street"
    store_city "Miami"
    store_county "Miami-Date"
    store_state "Florida"
    store_zip_code "33143"
    store_manager "Bob Smith"
    store_district "South Florida"
    store_region "Southeast"
    first_open_date 1
    last_remodal_date 600
  end
  
  factory :new_york_store, :class => StoreDimension do
    store_name "Store 2"
    store_number "Store 2"
    store_street_address "11 Broadway"
    store_city "New York"
    store_county "New York"
    store_state "New York"
    store_zip_code "00101"
    store_manager "John Smith"
    store_district "New York"
    store_region "Northeast"
    first_open_date 1
    last_remodal_date 600
  end
  
end