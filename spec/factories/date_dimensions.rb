FactoryGirl.define do

  factory :base_date, :class => DateDimension  do
    sql_date_stamp { Time.utc(Date.parse(date).year, Date.parse(date).month, Date.parse(date).day) }
    calendar_year { sql_date_stamp.strftime("%Y") }
    calendar_month_name { sql_date_stamp.strftime("%B") }
    calendar_quarter { "Q#{((sql_date_stamp.strftime("%m").to_f + 1) / 3).round}" }
    calendar_week { "Week #{sql_date_stamp.strftime("%-V")}" }
    day_of_week { sql_date_stamp.strftime("%A") }
    
    factory :date_incremented_by_day, :class => DateDimension do
      sequence(:date) { |n| (Time.utc(2000,12,31) + n.days).to_s }
    end
    
    factory :specific_date, :class => DateDimension do
      date "2001-01-01"
    end
    
  end
    
end