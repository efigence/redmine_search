class SearchingController < ApplicationController
  unloadable


  def index
  end

  def esearch
    klass = params[:klass] || "Issue"
    klass = klass.constantize
    conditions = set_condition if params[:condition]
    conditions = params[:load_with_condition] if params[:load_with_condition]
    @results = klass.elastic_search params[:esearch], where: conditions, operator: "or", page: params[:page], per_page: 10
    @results = {
      next_page: @results.current_page + 1,
      total_pages: @results.total_pages,
      entries: @results.entries,
      klass: klass.name,
      total: @results.total_entries,
      load_more_count: @results.total_entries - (@results.current_page * 10),
      esearch: params[:esearch],
      conditions: conditions
    }
    render layout: false
  end

  def set_condition
    @conditions = {}
    set_data_condition if params[:period] != ""
    set_project_condition if params[:project_id]
    set_assigned_condition if params[:assigned_to_id]
    set_tracker_condition if params[:tracker_id]
    @conditions
  end

  private

  def set_tracker_condition
    @conditions[:tracker_id] = params[:tracker_id]
  end

  def set_assigned_condition
    @conditions[:assigned_to_id] = params[:assigned_to_id]
  end

  def set_project_condition
    @conditions[:project_id] = params[:project_id]
  end

  def set_data_condition
    case params[:period]
    when "h"
      p = 1.hour.ago..DateTime.now
    when "24h"
      p = 24.hours.ago..DateTime.now
    when "w"
      p = 1.week.ago..DateTime.now
    when "m"
      p = 1.month.ago..DateTime.now
    when "y"
      p = 1.year.ago..DateTime.now
    end
    @conditions[:created_on] = p
  end
end
