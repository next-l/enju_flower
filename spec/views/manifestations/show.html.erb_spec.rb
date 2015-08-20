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

  it "render items with default sort order" do
    allow(view).to receive(:policy).and_return double(create?: true, update?: true)
    @manifestation.items = [ @item1, @item2 ]
    @manifestation.save
    render
    expect( rendered ).to have_selector( "table.holding tr:nth-child(3) td:first-child a", visible: true, text: @item2.item_identifier)
  end

  it "render items with sort order to prefer user's library" do
    user = FactoryGirl.create(:user)
    user.profile = FactoryGirl.create(:profile, library_id: 3)
    sign_in( user )

    @manifestation.items = [ @item1, @item2 ]
    @manifestation.save
    render
    expect( rendered ).to have_selector( "table.holding tr:nth-child(3) td:first-child a", visible: true, text: @item2.item_identifier)
  end

  #it "render items with sort order to prefer user's library for a different user" do
  #  user = FactoryGirl.create(:user)
  #  user.profile = FactoryGirl.create(:profile, library_id: 2)
  #  sign_in( user )
  #
  #  @manifestation.items = [ @item2, @item1 ]
  #  @manifestation.save
  #  render
  #  expect( rendered ).to have_selector( "table.holding tr:nth-child(3) td:first-child a", visible: true, text: @item1.item_identifier)
  #end
end
