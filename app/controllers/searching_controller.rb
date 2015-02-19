class SearchingController < ApplicationController
  unloadable


  def index
  end

  def esearch
    klass = params[:klass] || "Issue"
    klass = klass.constantize
    conditions = set_condition if params[:condition]
    @results = klass.elastic_search params[:esearch], where: conditions, operator: "or", page: params[:page], per_page: 10
    @results = {
      next_page: @results.current_page + 1,
      total_pages: @results.total_pages,
      entries: @results.entries,
      klass: klass.name,
      total: @results.total_entries,
      load_more_count: @results.total_entries - (@results.current_page * 10),
      esearch: params[:esearch]
    }
    render layout: false
  end

  def set_condition
    {
      project_id: params[:project_id]
    }
  end
end
