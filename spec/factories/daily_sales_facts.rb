FactoryGirl.define do
  
  factory :daily_sale, :class => DailySalesFact do
    association :date, factory: :specific_date
    cost 20
    #products { [FactoryGirl.create(:wholesome)] }
        
    factory :southeast_sale do |x|
      association :store, factory: :florida_store
    end
    
    factory :northeast_sale do
      association :store, factory: :new_york_store
    end
  
  end
  
end