# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :series_statement_relationship do |f|
    f.parent_id{FactoryGirl.create(:series_statement).id}
    f.child_id{FactoryGirl.create(:series_statement).id}
  end
end
