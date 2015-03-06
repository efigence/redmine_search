require File.expand_path('../../test_helper', __FILE__)

class SearchingControllerTest < ActionController::TestCase
  self.fixture_path = File.join(File.dirname(__FILE__), '../fixtures')

  fixtures :issues, :projects, :members, :users
  # TODO - Attachments test
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

  def set_settings
    Setting.destroy_all
    Setting.clear_cache
    Setting['plugin_redmine_search'] = {
      'users' => ["1"]
    }
  end

  #------------------ISSUES------------------
  test 'search issues without conditions' do
    get :esearch, esearch: 'test', klass: "Issue"
    assert_equal "Issue", assigns(:results)["klass"], 'Wrong class name!'
    assert_equal 2, assigns(:results)["total"], 'Wrong total count! Should equal 2!'
    assert_equal assigns(:results)["total"].to_i, assigns(:results)["entries"].count, "There should not be difference!"
    entries = assigns(:results)["entries"].collect(&:id)
    issues = User.current.projects.joins(:issues).collect(&:id).uniq
    assert_equal issues, entries, 'Wrong issues selected!'
  end

  test 'search issues with project condition' do
    get :esearch, esearch: 'test', klass: "Issue", condition: "true", project_id: [1]
    assert_equal 1, assigns(:results)["total"], 'Wrong total count! Should equal 1!'
    entries = assigns(:results)["entries"].collect(&:id)
    issues = User.current.projects.joins(:issues).where(projects: {id:1 }).collect(&:id)
    assert_equal issues, entries, 'Wrong issues selected!'
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

  test 'search issues with multiple conditions' do
      get :esearch, esearch: 'test', klass: "Issue", condition: true, status_id: [1], project_id: [1, 2], period: "w",
                                                                    tracker_id: [1], assigned_to_id: [1], priority_id: [4]
    assert_equal 1, assigns(:results)["total"], 'Wrong total count! Should equal 1!'
  end

  #----------------PERMISSIONS-----------------
  test 'search without defined permissions' do
    session[:allowed_to_private] = false
    get :esearch, esearch: 'test', klass: "Issue"
    assert_equal 2, assigns(:results)["total"], 'Wrong total count! Should equal 2!'
  end

  test 'search as admin' do
    set_settings
    session[:allowed_to_private] = true
    a = User.current
    a.admin = true
    a.save
    get :esearch, esearch: 'test', klass: "Issue"
    assert_equal 5, assigns(:results)["total"], 'Wrong total count! Should equal 5!'
  end

  test 'search as user with permission' do
    set_settings
    session[:allowed_to_private] = true
    get :esearch, esearch: 'test', klass: "Issue"
    assert_equal 3, assigns(:results)["total"], 'Wrong total count! Should equal 2!'
  end

  test 'search as user should not be possible to find private issues' do
    session[:allowed_to_private] = false
    get :esearch, esearch: 'test', klass: "Issue", is_private: 'true'
    assert_equal 2, assigns(:results)["total"], 'Wrong total count! Should equal 2!'
  end

  test 'search as allowed user should be possible to find private issues' do
    session[:allowed_to_private] = true
    get :esearch, esearch: 'test', klass: "Issue", is_private: 'true'
    assert_equal 1, assigns(:results)["total"], 'Wrong total count! Should equal 2!'
  end

  test 'search as not allowed user' do
    session[:allowed_to_private] = false
    get :esearch, esearch: '*', klass: "Issue", is_private: 'true'
    entries = assigns(:results)["entries"].collect(&:id)
    priv_issues = Issue.select('id, is_private').where(is_private: true).collect(&:id)
    assert_equal 0, (entries & priv_issues).size, 'There should no be found private issues.'
    assert_equal 2, assigns(:results)["total"], 'Wrong total count! Should equal 2!'
  end

  test 'search all as allowed user' do
    session[:allowed_to_private] = true
    get :esearch, esearch: '*', klass: "Issue", is_private: 'true'
    entries = assigns(:results)["entries"].collect(&:id)
    priv_issues = Issue.select('id, is_private').where(is_private: true).collect(&:id)
    assert_equal true, (entries & priv_issues).size > 0, 'Should found private issue.'
  end

  test 'search admin should see all issue(private, public)' do
    session[:allowed_to_private] = true
    a = User.current
    a.admin = true
    a.save
    get :esearch, esearch: '*', klass: "Issue", is_private: 'all'
    entries_priv = assigns(:results)["entries"].collect(&:is_private).count(true)
    issues_priv = Issue.where(is_private: true).count
    assert_equal issues_priv, entries_priv, 'Should equal to private issues!'
    assert_equal 5, assigns(:results)["total"], 'Should found 5 issue!'
  end

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
