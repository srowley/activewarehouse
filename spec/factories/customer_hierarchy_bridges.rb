FactoryGirl.define do

  factory :parent_bridge_record, :class => CustomerHierarchyBridge do
    num_levels_from_parent 0
    bottom_flag 'N'
    
    factory :root_customer, :class => CustomerHierarchyBridge do
      is_top 'Y'
    end
  end
    
  factory :child_bridge_record, :class => CustomerHierarchyBridge do
    is_top 'N'
  
  end
    
end