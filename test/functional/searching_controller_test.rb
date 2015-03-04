require File.expand_path('../../test_helper', __FILE__)

class SearchingControllerTest < ActionController::TestCase
  self.fixture_path = File.join(File.dirname(__FILE__), '../fixtures')

  fixtures :issues, :projects, :members

  def setup
    setup_client
    setup_issue_index
    setup_project_index
  end

  def setup_client
    config = {:hosts=>["http://127.0.0.1:9200"], :transport_options=>{:proxy=>{:uri=>""}, :headers=>{:user_agent=>"front"}, :request=>{:timeout=>60}}}
    Searchkick.client = Elasticsearch::Client.new(config)
  end

  def setup_issue_index
    Issue.searchkick_index.delete if Issue.searchkick_index.exists?
    Issue.enable_search_callbacks
    Issue.reindex
  end

  def setup_project_index
    Project.searchkick_index.delete if Project.searchkick_index.exists?
    Project.enable_search_callbacks
    Project.reindex
  end

  #------------------ISSUES------------------
  test 'search issues without conditions' do
    get :esearch, esearch: 'test', klass: "Issue"
    assert_equal "Issue", assigns(:results)["klass"], 'Wrong class name!'
    assert_equal 2, assigns(:results)["total"], 'Wrong total count! Should equal 2!'
    assert_equal assigns(:results)["total"].to_i, assigns(:results)["entries"].count, "There should not be difference!"
  end

  test 'search issues with project condition' do
    get :esearch, esearch: 'test', klass: "Issue", condition: "true", project_id: [1]
    assert_equal 1, assigns(:results)["total"], 'Wrong total count! Should equal 1!'
  end

  test 'search issues with period condition' do
    get :esearch, esearch: 'test', klass: "Issue", condition: true, period: "w"
    assert_equal 1, assigns(:results)["total"], 'Wrong total count! Should equal 1!'
  end

  test 'search issues with tracker condition' do
    get :esearch, esearch: 'test', klass: "Issue", condition: true, tracker_id: [1]
    assert_equal 2, assigns(:results)["total"], 'Wrong total count! Should equal 2!'
  end

  test 'search issues with user condition' do
    get :esearch, esearch: 'test', klass: "Issue", condition: true, assigned_to_id: [1]
    assert_equal 2, assigns(:results)["total"], 'Wrong total count! Should equal 2!'
  end

  test 'search issues with priority condition' do
    get :esearch, esearch: 'test', klass: "Issue", condition: true, priority_id: [4]
    assert_equal 1, assigns(:results)["total"], 'Wrong total count! Should equal 1!'
  end

  test 'search issues with status condition' do
     get :esearch, esearch: 'test', klass: "Issue", condition: true, status_id: [1]
    assert_equal 1, assigns(:results)["total"], 'Wrong total count! Should equal 1!'
  end

  # test 'search issues with multiple conditions' do
  #     get :esearch, esearch: 'test', klass: "Issue", condition: true, status_id: [1], project_id: [1, 2], period: "w",
  #                                                                   tracker_id: [1], assigned_to_id: [1], priority_id: [4]
  #   assert_equal 1, assigns(:results)["total"], 'Wrong total count! Should equal 1!'
  # end
  #------------------PROJECTS------------------
  test 'search projects without conditions' do
    get :esearch, esearch: 'test', klass: "Project"
    assert_equal 2, assigns(:results)["total"], 'Wrong total count! Should equal 2!'
  end

  test 'search projects with project conditions' do
    get :esearch, esearch: 'test', klass: "Project", condition: true, status: 1
    assert_equal 1, assigns(:results)["total"], 'Wrong total count! Should equal 1!'
  end

  test 'search projects with period conditions' do
    get :esearch, esearch: 'test', klass: "Project", condition: true, period: "w"
    assert_equal 1, assigns(:results)["total"], 'Wrong total count! Should equal 1!'
  end
end
