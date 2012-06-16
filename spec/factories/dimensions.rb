# TODO: figure out why sequences don't work to generate these.
FactoryGirl.define do
  # sequence :date do |n|
  #   Date.new(2001,1,1) + n.days
  # end

  factory :date_dimension do
    # calendar_year { generate(:date).strftime("%Y")}
    # calendar_quarter { generate(:date).strftime("%m")}
    # calendar_month_name { "Q#{(generate(:date).strftime("%B").to_i / 3).to_i + 1}" }
    # calendar_week { generate(:date).strftime("%U")}
    # day_of_week { generate(:date).strftime("%A")}
  end
    
end