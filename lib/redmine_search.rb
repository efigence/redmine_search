require 'redmine_search/tika'
require 'redmine_search/issues_esearch'
require 'redmine_search/projects_esearch'
require 'redmine_search/wiki_page_esearch'

module RedmineSearch

  def get_search_class
    @results = set_class_name.new.search params, session[:allowed_to_private]
  end

  private

  def set_class_name
    case params[:klass]
    when "Issue"
      IssuesEsearch
    when "Project"
      ProjectsEsearch
    when "WikiPage"
      WikiPageEsearch
    end
  end

  def get_results
    get_search_class
  end

  def self.elastic_search_language
    default = "English"
    Setting.plugin_redmine_search['search_language'] || default
  rescue
    default
  end
end