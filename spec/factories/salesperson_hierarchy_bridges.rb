FactoryGirl.define do

  factory :parent_salesperson, :class => SalespersonHierarchyBridge do
    num_levels_from_parent 0
    bottom_flag 0
    effective_date Time.gm(2006, 1, 1)
    expiration_date Time.gm(9999, 1, 1)
    
    factory :root_salesperson, :class => SalespersonHierarchyBridge do
      is_top 'Y'
    end
  end
    
  factory :child_salesperson, :class => SalespersonHierarchyBridge do
    effective_date Time.gm(2006, 1, 1)
    expiration_date Time.gm(9999, 1, 1)
    is_top 'N'
  end
    
end