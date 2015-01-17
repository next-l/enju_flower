FactoryGirl.define do
  factory :item do |f|
    f.sequence(:item_identifier){|n| "item_#{n}"}
    f.circulation_status_id{CirculationStatus.find(1).id}
    f.manifestation_id{FactoryGirl.create(:manifestation).id}
  end

  factory :item_for_checkout, class: Item do |f|
    f.sequence(:item_identifier){|n| "item_#{n}"}
    f.shelf_id {Shelf.find(2).id}
    f.circulation_status_id {CirculationStatus.find(2).id}
    f.use_restriction {UseRestriction.find(4)}
    f.manifestation_id {FactoryGirl.create(:manifestation).id}
  end
end
