require 'spec_helper'

describe "manifestations/show" do
  fixtures :all

  before(:each) do
    @manifestation = FactoryGirl.create(:manifestation)
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
    @item1 = FactoryGirl.create( :item_for_checkout, shelf_id: 2 )
    @item2 = FactoryGirl.create( :item_for_checkout, shelf_id: 4 )
    assign(:manifestation, @manifestation)
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
