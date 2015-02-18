class SearchingController < ApplicationController
  unloadable


  def index
  end

  def esearch
    klass = params[:klass] || "Issue"
    klass = klass.constantize
    @results = klass.elastic_search params[:esearch], operator: "or", limit: 10
    @results = {
      entries: @results.entries,
      klass: klass.name,
      total: @results.total_entries
    }
    render layout: false
  end
end
