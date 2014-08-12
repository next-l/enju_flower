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
      login_admin

      it "assigns all manifestations as @manifestations" do
        get :index
        assigns(:manifestations).should_not be_nil
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all manifestations as @manifestations" do
        get :index
        assigns(:manifestations).should_not be_nil
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns all manifestations as @manifestations" do
        get :index
        assigns(:manifestations).should_not be_nil
      end
    end

    describe "When not logged in" do
      it "assigns all manifestations as @manifestations" do
        get :index
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations in xml format without operation" do
        get :index, :format => 'xml'
        response.should be_success
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations in txt format without operation" do
        get :index, :format => 'txt'
        response.should be_success
        assigns(:manifestations).should_not be_nil
        response.should render_template('manifestations/index')
      end

      it "assigns all manifestations as @manifestations in sru format without operation" do
        get :index, :format => 'sru'
        assert_response :success
        assigns(:manifestations).should be_nil
        response.should render_template('manifestations/explain')
      end

      it "assigns all manifestations as @manifestations in sru format with operation" do
        get :index, :format => 'sru', :operation => 'searchRetrieve', :query => 'ruby'
        assigns(:manifestations).should_not be_nil
        response.should render_template('manifestations/index')
      end

      it "assigns all manifestations as @manifestations in sru format with operation and title" do
        get :index, :format => 'sru', :query => 'title=ruby', :operation => 'searchRetrieve'
        assigns(:manifestations).should_not be_nil
        response.should render_template('manifestations/index')
      end

      it "assigns all manifestations as @manifestations in openurl" do
        get :index, :api => 'openurl', :title => 'ruby'
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations when pub_date_from and pub_date_to are specified" do
        get :index, :pub_date_from => '2000', :pub_date_to => '2007'
        assigns(:query).should eq "date_of_publication_d:[#{Time.zone.parse('2000-01-01').utc.iso8601} TO #{Time.zone.parse('2007-12-31').end_of_year.utc.iso8601}]"
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations when acquired_from and pub_date_to are specified" do
        get :index, :acquired_from => '2000', :acquired_to => '2007'
        assigns(:query).should eq "acquired_at_d:[#{Time.zone.parse('2000-01-01').utc.iso8601} TO #{Time.zone.parse('2007-12-31').end_of_day.utc.iso8601}]"
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations when number_of_pages_at_least and number_of_pages_at_most are specified" do
        get :index, :number_of_pages_at_least => '100', :number_of_pages_at_least => '200'
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations in mods format" do
        get :index, :format => 'mods'
        assigns(:manifestations).should_not be_nil
        response.should render_template("manifestations/index")
      end

      it "assigns all manifestations as @manifestations in rdf format" do
        get :index, :format => 'rdf'
        assigns(:manifestations).should_not be_nil
        response.should render_template("manifestations/index")
      end

      it "should get index with manifestation_id" do
        get :index, :manifestation_id => 1
        response.should be_success
        assigns(:manifestation).should eq Manifestation.find(1)
        assigns(:manifestations).collect(&:id).should eq assigns(:manifestation).derived_manifestations.collect(&:id)
      end

      it "should get index with publisher_id" do
        get :index, :publisher_id => 1
        response.should be_success
        assigns(:manifestations).collect(&:id).should eq Agent.find(1).manifestations.order('created_at DESC').collect(&:id)
      end

      it "should get index with query" do
        get :index, :query => '2005'
        response.should be_success
        assigns(:manifestations).should_not be_blank
      end

      it "should get index with page number" do
        get :index, :query => '2005', :number_of_pages_at_least => 1, :number_of_pages_at_most => 100
        response.should be_success
        assigns(:query).should eq '2005 number_of_pages_i:[1 TO 100]'
      end

      it "should get index with pub_date_from" do
        get :index, :query => '2005', :pub_date_from => '2000'
        response.should be_success
        assigns(:manifestations).should be_truthy
        assigns(:query).should eq '2005 date_of_publication_d:[1999-12-31T15:00:00Z TO *]'
      end

      it "should get index with pub_date_to" do
        get :index, :query => '2005', :pub_date_to => '2000'
        response.should be_success
        assigns(:manifestations).should be_truthy
        assigns(:query).should eq '2005 date_of_publication_d:[* TO 2000-12-31T14:59:59Z]'
      end

      it "should get tag_cloud" do
        get :index, :query => '2005', :view => 'tag_cloud'
        response.should be_success
        response.should render_template("manifestations/_tag_cloud")
      end

      it "should show manifestation with isbn", :solr => true do
        get :index, :isbn => "4798002062"
        response.should be_success
        assigns(:manifestations).count.should eq 1
      end

      it "should not show missing manifestation with isbn", :solr => true do
        get :index, :isbn => "47980020620"
        response.should be_success
        assigns(:manifestations).should be_empty
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        assigns(:manifestation).should eq(Manifestation.find(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        assigns(:manifestation).should eq(Manifestation.find(1))
      end

      it "should show manifestation with agent who does not produce it" do
        get :show, :id => 3, :agent_id => 3
        assigns(:manifestation).should eq assigns(:agent).manifestations.find(3)
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        assigns(:manifestation).should eq(Manifestation.find(1))
      end

      it "should send manifestation detail email" do
        get :show, :id => 1, :mode => 'send_email'
        response.should redirect_to manifestation_url(assigns(:manifestation))
      end

      #it "should show myself" do
      #  get :show, :id => users(:user1).agent
      #  response.should be_success
      #end
    end

    describe "When not logged in" do
      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        assigns(:manifestation).should eq(Manifestation.find(1))
      end

      it "guest should show manifestation mods template" do
        get :show, :id => 22, :format => 'mods'
        assigns(:manifestation).should eq Manifestation.find(22)
        response.should render_template("manifestations/show")
      end

      it "should show manifestation rdf template" do
        get :show, :id => 22, :format => 'rdf'
        assigns(:manifestation).should eq Manifestation.find(22)
        response.should render_template("manifestations/show")
      end

      it "should show manifestation with holding" do
        get :show, :id => 1, :mode => 'holding'
        response.should be_success
      end

      it "should show manifestation with tag_edit" do
        get :show, :id => 1, :mode => 'tag_edit'
        response.should render_template('manifestations/_tag_edit')
        response.should be_success
      end

      it "should show manifestation with tag_list" do
        get :show, :id => 1, :mode => 'tag_list'
        response.should render_template('manifestations/_tag_list')
        response.should be_success
      end

      it "should show manifestation with show_creators" do
        get :show, :id => 1, :mode => 'show_creators'
        response.should render_template('manifestations/_show_creators')
        response.should be_success
      end

      it "should show manifestation with show_all_creators" do
        get :show, :id => 1, :mode => 'show_all_creators'
        response.should render_template('manifestations/_show_creators')
        response.should be_success
      end

      it "should not send manifestation's detail email" do
        get :show, :id => 1, :mode => 'send_email'
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested manifestation as @manifestation" do
        get :new
        assigns(:manifestation).should_not be_valid
      end

      it "should get new template without expression_id" do
        get :new
        response.should be_success
      end
  
      it "should get new template with expression_id" do
        get :new, :expression_id => 1
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested manifestation as @manifestation" do
        get :new
        assigns(:manifestation).should_not be_valid
      end

      it "should get new template without expression_id" do
        get :new
        response.should be_success
      end
  
      it "should get new template with expression_id" do
        get :new, :expression_id => 1
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested manifestation as @manifestation" do
        get :new
        assigns(:manifestation).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested manifestation as @manifestation" do
        get :new
        assigns(:manifestation).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested manifestation as @manifestation" do
        manifestation = FactoryGirl.create(:manifestation)
        get :edit, :id => manifestation.id
        assigns(:manifestation).should eq(manifestation)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested manifestation as @manifestation" do
        manifestation = FactoryGirl.create(:manifestation)
        get :edit, :id => manifestation.id
        assigns(:manifestation).should eq(manifestation)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested manifestation as @manifestation" do
        manifestation = FactoryGirl.create(:manifestation)
        get :edit, :id => manifestation.id
        response.should be_forbidden
      end

      it "should edit manifestation with tag_edit" do
        get :edit, :id => 1, :mode => 'tag_edit'
        response.should be_success
      end
    end

    describe "When not logged in" do
      it "should not assign the requested manifestation as @manifestation" do
        manifestation = FactoryGirl.create(:manifestation)
        get :edit, :id => manifestation.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = {:original_title => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "assigns a newly created manifestation as @manifestation" do
          post :create, :manifestation => @attrs
          assigns(:manifestation).should be_valid
        end

        it "assigns a series_statement" do
          post :create, :manifestation => @attrs.merge(:series_statements_attributes => {[0] => {:original_title => SeriesStatement.find(1).original_title}})
          assigns(:manifestation).reload
          assigns(:manifestation).series_statements.pluck(:original_title).include?(series_statements(:one).original_title).should be_truthy
        end

        it "redirects to the created manifestation" do
          post :create, :manifestation => @attrs
          response.should redirect_to(manifestation_url(assigns(:manifestation)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation as @manifestation" do
          post :create, :manifestation => @invalid_attrs
          assigns(:manifestation).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :manifestation => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created manifestation as @manifestation" do
          post :create, :manifestation => @attrs
          assigns(:manifestation).should be_valid
        end

        it "redirects to the created manifestation" do
          post :create, :manifestation => @attrs
          response.should redirect_to(manifestation_url(assigns(:manifestation)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation as @manifestation" do
          post :create, :manifestation => @invalid_attrs
          assigns(:manifestation).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :manifestation => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created manifestation as @manifestation" do
          post :create, :manifestation => @attrs
          assigns(:manifestation).should be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation as @manifestation" do
          post :create, :manifestation => @invalid_attrs
          assigns(:manifestation).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created manifestation as @manifestation" do
          post :create, :manifestation => @attrs
          assigns(:manifestation).should be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation as @manifestation" do
          post :create, :manifestation => @invalid_attrs
          assigns(:manifestation).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation => @invalid_attrs
          response.should redirect_to(new_user_session_url)
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
      login_admin

      describe "with valid params" do
        it "updates the requested manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
        end

        it "assigns a series_statement" do
          put :update, :id => @manifestation.id, :manifestation => @attrs.merge(:series_statements_attributes => {[0] => {:original_title => series_statements(:two).original_title, "_destroy"=>"false"}})
          assigns(:manifestation).reload
          assigns(:manifestation).series_statements.pluck(:original_title).include?(series_statements(:two).original_title).should be_truthy
        end

        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
          assigns(:manifestation).should eq(@manifestation)
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "updates the requested manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
        end

        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
          assigns(:manifestation).should eq(@manifestation)
          response.should redirect_to(@manifestation)
        end
      end

      describe "with invalid params" do
        it "assigns the manifestation as @manifestation" do
          put :update, :id => @manifestation, :manifestation => @invalid_attrs
          assigns(:manifestation).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @manifestation, :manifestation => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
        end

        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @attrs
          assigns(:manifestation).should eq(@manifestation)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @invalid_attrs
          response.should be_forbidden
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
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation as @manifestation" do
          put :update, :id => @manifestation.id, :manifestation => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @manifestation = FactoryGirl.create(:manifestation)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested manifestation" do
        delete :destroy, :id => @manifestation.id
      end

      it "redirects to the manifestations list" do
        delete :destroy, :id => @manifestation.id
        response.should redirect_to(manifestations_url)
      end

      it "should not destroy the reserved manifestation" do
        delete :destroy, :id => 2
        response.should be_forbidden
      end

      it "should not destroy manifestation contains items" do
        delete :destroy, :id => 1
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested manifestation" do
        delete :destroy, :id => @manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation.id
        response.should redirect_to(manifestations_url)
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested manifestation" do
        delete :destroy, :id => @manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested manifestation" do
        delete :destroy, :id => @manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
