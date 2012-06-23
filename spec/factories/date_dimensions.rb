FactoryGirl.define do

  factory :base_date, :class => DateDimension  do
    calendar_year { Date.parse(date).strftime("%Y") }
    calendar_month_name { Date.parse(date).strftime("%B") }
    calendar_quarter { "Q#{((Date.parse(date).strftime("%m").to_f + 1) / 3).round}" }
    calendar_week { "Week #{Date.parse(date).strftime("%-V")}" }
    day_of_week { Date.parse(date).strftime("%A") }
    
    factory :date_incremented_by_day, :class => DateDimension do
      sequence(:date) { |n| (Date.new(2000,12,31) + n.days).to_s }
    end
    
    factory :specific_date, :class => DateDimension do
      date "2001-01-01"
    end
    
  end
    
end