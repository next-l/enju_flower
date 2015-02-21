require 'spec_helper'

describe "manifestations/index" do
  fixtures :all

  before(:each) do
    @manifestations = assign(:manifestations, 
      Kaminari.paginate_array( [ 
        FactoryGirl.create(:manifestation),
      ], total_count: 1).page(1)
    )
    @count = { query_result: 1 }
    @reservable_facet = @carrier_type_facet = @language_facet = @library_facet = @pub_year_facet = [] 
    @index_agent = {}
    @seconds = 0
    @max_number_of_results = 500

    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it "render works" do
    allow(view).to receive(:policy).and_return double(create?: true, update?: true)
    render
    expect( rendered ).to match(/1/)
  end

  it "render items for checkouts" do
    3.times do |i|
      item = FactoryGirl.create( :item_for_checkout )
      @manifestations.first.items << item
    end
    expect( @manifestations.first.items.size ).to eq 3
    render
    #expect( rendered ).to have_selector( "div.holding_index tr td:first-child", count: 3, visible: false )
  end

  it "render items with default sort order" do
    allow(view).to receive(:policy).and_return double(create?: true, update?: true)
    item1 = FactoryGirl.create( :item_for_checkout, shelf_id: 2 )
    item2 = FactoryGirl.create( :item_for_checkout, shelf_id: 4 )
    @manifestations.first.items = [ item1, item2 ]
    render
    #expect( rendered ).to have_selector( "div.holding_index tr td:first-child a", visible: false, text: item1.item_identifier )
  end

  it "render items with sort order to prefer user's library" do
    allow(view).to receive(:policy).and_return double(create?: true, update?: true)
    user = FactoryGirl.create(:user)
    user.profile = FactoryGirl.create(:profile, library_id: 3)
    sign_in( user )

    item1 = FactoryGirl.create( :item_for_checkout, shelf_id: 2 )
    item2 = FactoryGirl.create( :item_for_checkout, shelf_id: 4 )
    @manifestations.first.items = [ item1, item2 ]
    render
    #expect( rendered ).to have_selector( "div.holding_index tr:nth-child(2) td:first-child a", visible: false, text: item1.item_identifier )
  end
end
