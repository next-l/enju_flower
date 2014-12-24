require 'spec_helper'

describe ManifestationsController do
  fixtures :all

  def valid_attributes
    FactoryGirl.attributes_for(:manifestation)
  end

  describe "GET index", :solr => true do
    before do
      Manifestation.reindex
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all manifestations as @manifestations" do
        get :index
        expect(assigns(:manifestations)).to_not be_nil
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all manifestations as @manifestations" do
        get :index
        expect(assigns(:manifestations)).to_not be_nil
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns all manifestations as @manifestations" do
        get :index
        expect(assigns(:manifestations)).to_not be_nil
      end
    end

    describe "When not logged in" do
      it "assigns all manifestations as @manifestations" do
        get :index
        expect(assigns(:manifestations)).to_not be_nil
      end

      it "assigns all manifestations as @manifestations in xml format without operation" do
        get :index, :format => 'xml'
        expect(response).to be_success
        expect(assigns(:manifestations)).to_not be_nil
      end

      it "assigns all manifestations as @manifestations in txt format without operation" do
        get :index, :format => 'txt'
        expect(response).to be_success
        expect(assigns(:manifestations)).to_not be_nil
        expect(response).to render_template('manifestations/index')
      end

      it "assigns all manifestations as @manifestations in sru format without operation" do
        get :index, :format => 'sru'
        assert_response :success
        expect(assigns(:manifestations)).to be_nil
        expect(response).to render_template('manifestations/explain')
      end

      it "assigns all manifestations as @manifestations in sru format with operation" do
        get :index, :format => 'sru', :operation => 'searchRetrieve', :query => 'ruby'
        expect(assigns(:manifestations)).to_not be_nil
        expect(response).to render_template('manifestations/index')
      end

      it "assigns all manifestations as @manifestations in sru format with operation and title" do
        get :index, :format => 'sru', :query => 'title=ruby', :operation => 'searchRetrieve'
        expect(assigns(:manifestations)).to_not be_nil
        expect(response).to render_template('manifestations/index')
      end

      it "assigns all manifestations as @manifestations in openurl" do
        get :index, :api => 'openurl', :title => 'ruby'
        expect(assigns(:manifestations)).to_not be_nil
      end

      it "assigns all manifestations as @manifestations when pub_date_from and pub_date_to are specified" do
        get :index, :pub_date_from => '2000', :pub_date_to => '2007'
        assigns(:query).should eq "date_of_publication_d:[#{Time.zone.parse('2000-01-01').utc.iso8601} TO #{Time.zone.parse('2007-12-31').end_of_year.utc.iso8601}]"
        expect(assigns(:manifestations)).to_not be_nil
      end

      it "assigns all manifestations as @manifestations when acquired_from and pub_date_to are specified" do
        get :index, :acquired_from => '2000', :acquired_to => '2007'
        assigns(:query).should eq "acquired_at_d:[#{Time.zone.parse('2000-01-01').utc.iso8601} TO #{Time.zone.parse('2007-12-31').end_of_day.utc.iso8601}]"
        expect(assigns(:manifestations)).to_not be_nil
      end

      it "assigns all manifestations as @manifestations when number_of_pages_at_least and number_of_pages_at_most are specified" do
        get :index, :number_of_pages_at_least => '100', :number_of_pages_at_least => '200'
        expect(assigns(:manifestations)).to_not be_nil
      end

      it "assigns all manifestations as @manifestations in mods format" do
        get :index, :format => 'mods'
        expect(assigns(:manifestations)).to_not be_nil
        expect(response).to render_template("manifestations/index")
      end

      it "assigns all manifestations as @manifestations in rdf format" do
        get :index, :format => 'rdf'
        expect(assigns(:manifestations)).to_not be_nil
        expect(response).to render_template("manifestations/index")
      end

      it "should get index with manifestation_id" do
        get :index, :manifestation_id => 1
        expect(response).to be_success
        expect(assigns(:manifestation)).to eq Manifestation.find(1)
        assigns(:manifestations).collect(&:id).should eq assigns(:manifestation).derived_manifestations.collect(&:id)
      end

      it "should get index with query" do
        get :index, :query => '2005'
        expect(response).to be_success
        expect(assigns(:manifestations)).to_not be_blank
      end

      it "should get index with page number" do
        get :index, :query => '2005', :number_of_pages_at_least => 1, :number_of_pages_at_most => 100
        expect(response).to be_success
        assigns(:query).should eq '2005 number_of_pages_i:[1 TO 100]'
      end

      it "should get index with pub_date_from" do
        get :index, :query => '2005', :pub_date_from => '2000'
        expect(response).to be_success
        expect(assigns(:manifestations)).to be_truthy
        assigns(:query).should eq '2005 date_of_publication_d:[1999-12-31T15:00:00Z TO *]'
      end

      it "should get index with pub_date_to" do
        get :index, :query => '2005', :pub_date_to => '2000'
        expect(response).to be_success
        expect(assigns(:manifestations)).to be_truthy
        assigns(:query).should eq '2005 date_of_publication_d:[* TO 2000-12-31T14:59:59Z]'
      end

      it "should get tag_cloud" do
        get :index, :query => '2005', :view => 'tag_cloud'
        expect(response).to be_success
        expect(response).to render_template("manifestations/_tag_cloud")
      end

      it "should show manifestation with isbn", :solr => true do
        get :index, :isbn => "4798002062"
        expect(response).to be_success
        expect(assigns(:manifestations).count).to eq 1
      end

      it "should not show missing manifestation with isbn", :solr => true do
        get :index, :isbn => "47980020620"
        expect(response).to be_success
        expect(assigns(:manifestations)).to be_empty
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        expect(assigns(:manifestation)).to eq(Manifestation.find(1))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        expect(assigns(:manifestation)).to eq(Manifestation.find(1))
      end

      it "should show manifestation with agent who does not produce it" do
        get :show, :id => 3, :agent_id => 3
        expect(assigns(:manifestation)).to eq assigns(:agent).manifestations.find(3)
        expect(response).to be_success
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        expect(assigns(:manifestation)).to eq(Manifestation.find(1))
      end

      it "should send manifestation detail email" do
        get :show, :id => 1, :mode => 'send_email'
        expect(response).to redirect_to manifestation_url(assigns(:manifestation))
      end

      #it "should show myself" do
      #  get :show, :id => users(:user1).agent
      #  expect(response).to be_success
      #end
    end

    describe "When not logged in" do
      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        expect(assigns(:manifestation)).to eq(Manifestation.find(1))
      end

      it "guest should show manifestation mods template" do
        get :show, :id => 22, :format => 'mods'
        expect(assigns(:manifestation)).to eq Manifestation.find(22)
        expect(response).to render_template("manifestations/show")
      end

      it "should show manifestation rdf template" do
        get :show, :id => 22, :format => 'rdf'
        expect(assigns(:manifestation)).to eq Manifestation.find(22)
        expect(response).to render_template("manifestations/show")
      end

      it "should show manifestation with holding" do
        get :show, :id => 1, :mode => 'holding'
        expect(response).to be_success
      end

      it "should show manifestation with tag_edit" do
        get :show, :id => 1, :mode => 'tag_edit'
        expect(response).to render_template('manifestations/_tag_edit')
        expect(response).to be_success
      end

      it "should show manifestation with tag_list" do
        get :show, :id => 1, :mode => 'tag_list'
        expect(response).to render_template('manifestations/_tag_list')
        expect(response).to be_success
      end

      it "should show manifestation with show_creators" do
        get :show, :id => 1, :mode => 'show_creators'
        expect(response).to render_template('manifestations/_show_creators')
        expect(response).to be_success
      end

      it "should show manifestation with show_all_creators" do
        get :show, :id => 1, :mode => 'show_all_creators'
        expect(response).to render_template('manifestations/_show_creators')
        expect(response).to be_success
      end

      it "should not send manifestation's detail email" do
        get :show, :id => 1, :mode => 'send_email'
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested manifestation as @manifestation" do
        get :new
        expect(assigns(:manifestation)).to_not be_valid
      end

      it "should get new template without expression_id" do
        get :new
        expect(response).to be_success
      end
  
      it "should get new template with expression_id" do
        get :new, :expression_id => 1
        expect(response).to be_success
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested manifestation as @manifestation" do
        get :new
        expect(assigns(:manifestation)).to_not be_valid
      end

      it "should get new template without expression_id" do
        get :new
        expect(response).to be_success
      end
  
      it "should get new template with expression_id" do
        get :new, :expression_id => 1
        expect(response).to be_success
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested manifestation as @manifestation" do
        get :new
        expect(assigns(:manifestation)).to_not be_valid
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested manifestation as @manifestation" do
        get :new
        expect(assigns(:manifestation)).to_not be_valid
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested manifestation as @manifestation" do
        manifestation = FactoryGirl.create(:manifestation)
        get :edit, :id => manifestation.id
        expect(assigns(:manifestation)).to eq(manifestation)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested manifestation as @manifestation" do
        manifestation = FactoryGirl.create(:manifestation)
        get :edit, :id => manifestation.id
        expect(assigns(:manifestation)).to eq(manifestation)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested manifestation as @manifestation" do
        manifestation = FactoryGirl.create(:manifestation)
        get :edit, :id => manifestation.id
        expect(response).to be_forbidden
      end

      it "should edit manifestation with tag_edit" do
        get :edit, :id => 1, :mode => 'tag_edit'
        expect(response).to be_success
      end
    end

    describe "When not logged in" do
      it "should not assign the requested manifestation as @manifestation" do
        manifestation = FactoryGirl.create(:manifestation)
        get :edit, :id => manifestation.id
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = {:original_title => ''}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "assigns a newly created manifestation as @manifestation" do
          post :create, :manifestation => @attrs
          expect(assigns(:manifestation)).to be_valid
        end

        it "assigns a series_statement" do
          post :create, :manifestation => @attrs.merge(:series_statements_attributes => {"0" => {:original_title => SeriesStatement.find(1).original_title}})
          assigns(:manifestation).reload
          assigns(:manifestation).series_statements.pluck(:original_title).include?(series_statements(:one).original_title).should be_truthy
        end

        it "redirects to the created manifestation" do
          post :create, :manifestation => @attrs
          expect(response).to redirect_to(manifestation_url(assigns(:manifestation)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation as @manifestation" do
          post :create, :manifestation => @invalid_attrs
          expect(assigns(:manifestation)).to_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :manifestation => @invalid_attrs
          expect(response).to render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "assigns a newly created manifestation as @manifestation" do
          post :create, :manifestation => @attrs
          expect(assigns(:manifestation)).to be_valid
        end

        it "redirects to the created manifestation" do
          post :create, :manifestation => @attrs
          expect(response).to redirect_to(manifestation_url(assigns(:manifestation)))
        end

        #it "accepts an attachment file" do
        #  post :create, :manifestation => @attrs.merge(attachment: fixture_file_upload("/../../examples/resource_import_file_sample1.tsv", 'text/csv'))
        #  expect(assigns(:manifestation)).to be_valid
        #end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation as @manifestation" do
          post :create, :manifestation => @invalid_attrs
          expect(assigns(:manifestation)).to_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :manifestation => @invalid_attrs
          expect(response).to render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "assigns a newly created manifestation as @manifestation" do
          post :create, :manifestation => @attrs
          expect(assigns(:manifestation)).to be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation => @attrs
          expect(response).to be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation as @manifestation" do
          post :create, :manifestation => @invalid_attrs
          expect(assigns(:manifestation)).to_not be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation => @invalid_attrs
          expect(response).to be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created manifestation as @manifestation" do
          post :create, :manifestation => @attrs
          expect(assigns(:manifestation)).to be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation => @attrs
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation as @manifestation" do
          post :create, :manifestation => @invalid_attrs
          expect(assigns(:manifestation)).to_not be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation => @invalid_attrs
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @manifestation = FactoryGirl.create(:manifestation)
      @manifestation.series_statements = [SeriesStatement.find(1)]
      @attrs = valid_attributes
      @invalid_attrs = {:original_title => ''}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "updates the requested manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
        end

        it "assigns a series_statement" do
          put :update, :id => @manifestation.id, :manifestation => @attrs.merge(:series_statements_attributes => {"0" => {:original_title => series_statements(:two).original_title, "_destroy"=>"false"}})
          assigns(:manifestation).reload
          assigns(:manifestation).series_statements.pluck(:original_title).include?(series_statements(:two).original_title).should be_truthy
        end

        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
          expect(assigns(:manifestation)).to eq(@manifestation)
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @invalid_attrs
          expect(response).to render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "updates the requested manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
        end

        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
          expect(assigns(:manifestation)).to eq(@manifestation)
          expect(response).to redirect_to(@manifestation)
        end
      end

      describe "with invalid params" do
        it "assigns the manifestation as @manifestation" do
          put :update, :id => @manifestation, :manifestation => @invalid_attrs
          expect(assigns(:manifestation)).to_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @manifestation, :manifestation => @invalid_attrs
          expect(response).to render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
        end

        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
          expect(assigns(:manifestation)).to eq(@manifestation)
          expect(response).to be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @invalid_attrs
          expect(response).to be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @invalid_attrs
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @manifestation = FactoryGirl.create(:manifestation)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested manifestation" do
        delete :destroy, :id => @manifestation.id
      end

      it "redirects to the manifestations list" do
        delete :destroy, :id => @manifestation.id
        expect(response).to redirect_to(manifestations_url)
      end

      it "should not destroy the reserved manifestation" do
        delete :destroy, :id => 2
        expect(response).to be_forbidden
      end

      it "should not destroy manifestation contains items" do
        delete :destroy, :id => 1
        expect(response).to be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested manifestation" do
        delete :destroy, :id => @manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation.id
        expect(response).to redirect_to(manifestations_url)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested manifestation" do
        delete :destroy, :id => @manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation.id
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested manifestation" do
        delete :destroy, :id => @manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation.id
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
