class SearchingController < ApplicationController

  unloadable

  include RedmineSearch

  def index
    # if !session[:esearch].blank?
    #   params.merge!(session[:esearch])
    #   esearch
    # end
  end

  def esearch
    @resutls = get_results
    @results = {
      next_page: @results.current_page + 1,
      total_pages: @results.total_pages,
      entries: @results.entries,
      klass: params[:klass].constantize.name,
      total: @results.total_entries,
      load_more_count: @results.total_entries - (@results.current_page * 10),
      esearch: params[:esearch]
    }
    # session[:esearch] = params
    render partial: 'esearch' if request.xhr?
  end

  def cleanup
    session[:esearch] = nil
    redirect_to :action => "index"
  end
end
