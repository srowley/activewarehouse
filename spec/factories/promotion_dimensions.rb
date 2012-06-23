FactoryGirl.define do
  factory :promotion, :class => PromotionDimension do
    promotion_name "Christmas Sale 2006"
    price_reduction_type "50% Off"
    promotion_media_type "Banner"
    ad_type "None"
    display_type "Banner"
    coupon_type "None"
    ad_media_name "None"
    display_provider "Internal"
    promotion_cost 10000
    promotion_begin_date 1
    promotion_end_date 10
  end
end