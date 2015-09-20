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

  it "should renders series_statement" do
    series_statement = FactoryGirl.create(:series_statement,
      creator_string: "Series Creator",
      volume_number_string: "Volume 12"
    )
    @manifestation.series_statements << series_statement
    render
    expect(rendered).to include series_statement.original_title
    expect(rendered).to include series_statement.volume_number_string
    expect(rendered).to include series_statement.creator_string
  end

  describe "call_number_label" do
    before(:each) do
      profile = FactoryGirl.create(:profile, :library_id => 2)
      user = FactoryGirl.create(:user, :profile => profile)
      sign_in user
    end
    # Ref: next-l/enju_leaf#735
    it "should renders call_number table even if identifier is nil" do
      item = FactoryGirl.create(:item_for_checkout, :item_identifier => nil, :call_number => '010')
      @manifestation.items << item
      render
      expect(rendered).to match /010/
    end
  end
end
