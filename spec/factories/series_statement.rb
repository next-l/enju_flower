FactoryGirl.define do
  factory :series_statement do |f|
    f.sequence(:original_title){|n| "series_statement_#{n}"}
  end
  factory :series_statement_serial, class: SeriesStatement do |f|
    f.sequence(:original_title){|n| "series_statement_serial_#{n}" }
    #f.root_manifestation_id{FactoryGirl.create(:manifestation_serial).id}
    f.series_master{true}
  end
end
