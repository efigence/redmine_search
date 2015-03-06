class SearchingController < ApplicationController

  unloadable

  include RedmineSearch

  def index
    session[:allowed_to_private] = allowed_to_private?
    # if !session[:esearch].blank?
    #   params.merge!(session[:esearch])
    #   esearch
    # end
  end

  def esearch
    @resutls = get_results
    @results = {
      next_page: @results.next_page,
      total_pages: @results.total_pages,
      entries: @results.entries,
      klass: params[:klass].constantize.name,
      total: @results.total_entries,
      load_more_count: @results.total_entries - (@results.current_page * 10),
      esearch: params[:esearch]
    }
    # session[:esearch] = params
    render partial: 'esearch'
  end

  def cleanup
    session[:esearch] = nil
    redirect_to :action => "index"
  end

  def allowed_to_private?
    return true if User.current.admin?
    cond_g = !!Setting.plugin_redmine_search['groups'] && User.current.groups.where(id: Setting.plugin_redmine_search['groups']).any?
    cond_u = [Setting.plugin_redmine_search['users']].flatten.include?(User.current.id.to_s)
    cond_u || cond_g
  end
end
