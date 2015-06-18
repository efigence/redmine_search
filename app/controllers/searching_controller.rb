class SearchingController < ApplicationController

  unloadable

  include RedmineSearch

  def index
    params[:klass] ||= "Issue"
    session[:allowed_to_private] = allowed_to_private?
    if params[:esearch]
      fetch
    end
  end

  def esearch
    params[:klass] ||= "Issue"
    fetch
    render partial: 'esearch'
  end

  def cleanup
    redirect_to :action => "index"
  end

  private

  def fetch
    @resutls = get_results
    @klass = params[:klass].constantize.name
    @load_more_count = @results.total_entries - (@results.current_page * 10)
  end


  def allowed_to_private?
    return true if User.current.admin?
    cond_g = !!Setting.plugin_redmine_search['groups'] && User.current.groups.where(id: Setting.plugin_redmine_search['groups']).any?
    cond_u = [Setting.plugin_redmine_search['users']].flatten.include?(User.current.id.to_s)
    cond_u || cond_g
  end
end
