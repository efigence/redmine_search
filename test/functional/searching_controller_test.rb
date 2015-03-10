require File.expand_path('../../test_helper', __FILE__)

class SearchingControllerTest < ActionController::TestCase

  def setup
    setup_client
    set_plugin_fixtures_attachments_directory
    %w(Issue Project WikiPage).each {|model| setup_index(model)}
    @request.session[:user_id] = 1
  end

  def setup_client
    config = {:hosts=>["http://127.0.0.1:9200"], :transport_options=>{:proxy=>{:uri=>""}, :headers=>{:user_agent=>"front"}, :request=>{:timeout=>60}}}
    Searchkick.client = Elasticsearch::Client.new(config)
  end

  def setup_index model
    model = model.constantize
    model.searchkick_index.delete if model.searchkick_index.exists?
    model.enable_search_callbacks
    model.reindex
  end

  def set_settings
    Setting.destroy_all
    Setting.clear_cache
    Setting['plugin_redmine_search'] = {
      'users' => ["1"],
      'search_language' => 'English',
      'file_size' => "5",
      'async_indexing' => "0"
    }
  end

  def allow_user_admin
    @request.session[:user_id] = 4
    @request.session[:allowed_to_private] = true
  end

  # -----------------Fixtures-----------------
  %w(Issue Project Wiki WikiPage WikiContent Attachment Member User).each {|m| puts "#{m} -> #{m.constantize.count}"}

  # ------------------ISSUES------------------
  test 'search issues without conditions' do
    get :esearch, esearch: 'test', klass: "Issue"
    assert_equal "Issue", assigns(:results)[:klass], 'Wrong class name!'
    assert_equal 2, assigns(:results)[:total], 'Wrong total count! Should equal 2!'
    assert_equal assigns(:results)[:total].to_i, assigns(:results)[:entries].count, "There should not be difference!"
    entries = assigns(:results)[:entries].collect(&:id)
    issues = User.current.projects.joins(:issues).collect(&:id).uniq
    assert_equal issues.sort, entries.sort, 'Wrong issues selected!'
  end

  test 'search issues with project condition' do
    get :esearch, esearch: 'test', klass: "Issue", condition: "true", project_id: [1]
    assert_equal 1, assigns(:results)[:total], 'Wrong total count! Should equal 1!'
    entries = assigns(:results)[:entries].collect(&:id)
    issues = User.current.projects.joins(:issues).where(projects: {id:1 }).collect(&:id)
    assert_equal issues, entries, 'Wrong issues selected!'
  end

  test 'search issues with period condition' do
    get :esearch, esearch: 'test', klass: "Issue", condition: true, period: "w"
    assert_equal 1, assigns(:results)[:total], 'Wrong total count! Should equal 1!'
  end

  test 'search issues with tracker condition' do
    get :esearch, esearch: 'test', klass: "Issue", condition: true, tracker_id: [1]
    assert_equal 2, assigns(:results)[:total], 'Wrong total count! Should equal 2!'
  end

  test 'search issues with user condition' do
    get :esearch, esearch: 'test', klass: "Issue", condition: true, assigned_to_id: [1]
    assert_equal 2, assigns(:results)[:total], 'Wrong total count! Should equal 2!'
  end

  test 'search issues with priority condition' do
    get :esearch, esearch: 'test', klass: "Issue", condition: true, priority_id: [4]
    assert_equal 1, assigns(:results)[:total], 'Wrong total count! Should equal 1!'
  end

  test 'search issues with status condition' do
     get :esearch, esearch: 'test', klass: "Issue", condition: true, status_id: [1]
    assert_equal 1, assigns(:results)[:total], 'Wrong total count! Should equal 1!'
  end

  test 'search issues with multiple conditions' do
      get :esearch, esearch: 'test', klass: "Issue", condition: true, status_id: [1], project_id: [1, 2], period: "w",
                                                                    tracker_id: [1], assigned_to_id: [1], priority_id: [4]
    assert_equal 1, assigns(:results)[:total], 'Wrong total count! Should equal 1!'
  end

  #----------------PERMISSIONS-----------------
  test 'search without defined permissions' do
    @request.session[:allowed_to_private] = false
    get :esearch, esearch: 'test', klass: "Issue"
    assert_equal 2, assigns(:results)[:total], 'Wrong total count! Should equal 2!'
  end

  test 'search as admin' do
    set_settings
    allow_user_admin
    get :esearch, esearch: 'test', klass: "Issue"
    assert_equal 5, assigns(:results)[:total], 'Wrong total count! Should equal 5!'
  end

  test 'search as user with permission' do
    set_settings
    @request.session[:allowed_to_private] = true
    get :esearch, esearch: 'test', klass: "Issue"
    assert_equal 3, assigns(:results)[:total], 'Wrong total count! Should equal 2!'
  end

  test 'search as user should not be possible to find private issues' do
    @request.session[:allowed_to_private] = false
    get :esearch, esearch: 'test', klass: "Issue", is_private: 'true'
    assert_equal 2, assigns(:results)[:total], 'Wrong total count! Should equal 2!'
  end

  test 'search as allowed user should be possible to find private issues' do
    @request.session[:allowed_to_private] = true
    get :esearch, esearch: 'test', klass: "Issue", is_private: 'true'
    assert_equal 1, assigns(:results)[:total], 'Wrong total count! Should equal 2!'
  end

  test 'search as not allowed user' do
    @request.session[:allowed_to_private] = false
    get :esearch, esearch: '*', klass: "Issue", is_private: 'true'
    entries = assigns(:results)[:entries].collect(&:id)
    priv_issues = Issue.select('id, is_private').where(is_private: true).collect(&:id)
    assert_equal 0, (entries & priv_issues).size, 'There should no be found private issues.'
    assert_equal 2, assigns(:results)[:total], 'Wrong total count! Should equal 2!'
  end

  test 'search all as allowed user' do
    @request.session[:allowed_to_private] = true
    get :esearch, esearch: '*', klass: "Issue", is_private: 'true'
    entries = assigns(:results)[:entries].collect(&:id)
    priv_issues = Issue.select('id, is_private').where(is_private: true).collect(&:id)
    assert_equal true, (entries & priv_issues).size > 0, 'Should found private issue.'
  end

  test 'search admin should see all issue(private, public)' do
    allow_user_admin
    get :esearch, esearch: '*', klass: "Issue", is_private: 'all'
    entries_priv = assigns(:results)[:entries].collect(&:is_private).count(true)
    issues_priv = Issue.where(is_private: true).count
    assert_equal issues_priv, entries_priv, 'Should equal to private issues!'
    assert_equal 10, assigns(:results)[:total], 'Should found 10 issue! - all issues'
  end

  #------------------PROJECTS------------------
  test 'search projects without conditions' do
    get :esearch, esearch: 'test', klass: "Project"
    assert_equal 2, assigns(:results)[:total], 'Wrong total count! Should equal 2!'
  end

  test 'search projects with project conditions' do
    get :esearch, esearch: 'test', klass: "Project", condition: true, status: 1
    assert_equal 1, assigns(:results)[:total], 'Wrong total count! Should equal 1!'
  end

  test 'search projects with period conditions' do
    get :esearch, esearch: 'test', klass: "Project", condition: true, period: "w"
    assert_equal 1, assigns(:results)[:total], 'Wrong total count! Should equal 1!'
  end

  test 'should return all projects when query *' do
    allow_user_admin
    get :esearch, esearch: '*', klass: "Project"
    assert_equal Project.count, assigns(:results)[:total], 'Wrong total count! Should return projects!'
    assert_equal 4, assigns(:results)[:total], 'Wrong total count! Should return 4!'
  end

  #------------------ATTACHMENTS(PDF/ODT/CSV/DOC/ODP)-----------------
  test 'search issue only by attachments content' do
    set_settings
    allow_user_admin
    get :esearch, esearch: 'test', klass: "Issue", is_private: 'all', attachment: "only"
    assert_equal 5, assigns(:results)[:total], 'Wrong total count! Should return 5!'
  end

  test 'search issue with attachments content' do
    #by defautl return 3 but with attachments should return 8
    set_settings
    allow_user_admin
    get :esearch, esearch: 'test', klass: "Issue", is_private: 'all', attachment: "with"
    assert_equal 10, assigns(:results)[:total], 'Wrong total count! Should return 10(issues test and attach test!'
  end

  test 'search wikipages' do
    allow_user_admin
    get :esearch, esearch: 'test', klass: "WikiPage"
    assert_equal 1, assigns(:results)[:total], 'Wrong count of WikiPages! Should be 1!'
  end
end
