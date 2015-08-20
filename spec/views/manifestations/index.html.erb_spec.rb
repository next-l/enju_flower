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
end
