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
    set_date_condition           unless params[:period].blank?
    set_project_condition        unless params[:project_id].blank?
    set_assigned_condition       unless params[:assigned_to_id].blank?
    set_tracker_condition        unless params[:tracker_id].blank?
    set_priority_condition       unless params[:priority_id].blank?
    set_status_condition         unless params[:status_id].blank?
    set_project_status_condition unless params[:status].blank?
    @conditions
  end

  private

  def set_project_status_condition
    @conditions[:status] = params[:status]
  end

  def set_status_condition
    @conditions[:status_id] = params[:status_id]
  end

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

  def set_date_condition
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
      p = from > to ? to..from : from..to
    end
    @conditions[:created_on] = p
  end
end
