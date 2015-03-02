class SearchingController < ApplicationController
  unloadable


  def index
  end

  def esearch
    klass = params[:klass].constantize
    conditions = set_condition if params[:condition]
    order_by = params[:order].blank? ? 'desc' : params[:order]
    @results = klass.elastic_search params[:esearch], where: conditions, operator: "or", order: {created_on: order_by.to_sym}, page: params[:page], per_page: 10
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
    @conditions = {}
    set_data_condition if params[:period] != ""
    set_project_condition if params[:project_id]
    set_assigned_condition if params[:assigned_to_id]
    set_tracker_condition if params[:tracker_id]
    set_priority_condition if params[:priority_id]
    @conditions
  end

  private

  def set_priority_condition
    @conditions[:priority_id] = params[:priority_id]
  end

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
    when "dr"
      from = params[:from].blank? ? DateTime.now : params[:from].to_datetime
      to = params[:to].blank? ? DateTime.now : params[:to].to_datetime
      p = from..to
    end
    @conditions[:created_on] = p
  end
end
