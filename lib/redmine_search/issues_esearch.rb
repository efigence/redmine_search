require_relative './date_condition'

module RedmineSearch
  class IssuesEsearch < DateCondition

    def search params
      @params = params
      set_condition
      order_by = @params[:order].blank? ? 'desc' : @params[:order]
      @results = Issue.elastic_search @params[:esearch], where: @conditions, operator: "or", order: {created_on: order_by.to_sym}, page: @params[:page], per_page: 10
    end

    private

    def set_condition
      @conditions = {}
      set_issues_condition         unless User.current.admin?
      set_date_condition           unless @params[:period].blank?
      set_project_condition        unless @params[:project_id].blank?
      set_assigned_condition       unless @params[:assigned_to_id].blank?
      set_tracker_condition        unless @params[:tracker_id].blank?
      set_priority_condition       unless @params[:priority_id].blank?
      set_status_condition         unless @params[:status_id].blank?
    end

    def set_issues_condition
      @conditions[:project_id] = User.current.projects.collect(&:id)
    end

    def set_status_condition
      @conditions[:status_id] = @params[:status_id]
    end

    def set_priority_condition
      @conditions[:priority_id] = @params[:priority_id]
    end

    def set_tracker_condition
      @conditions[:tracker_id] = @params[:tracker_id]
    end

    def set_assigned_condition
      @conditions[:assigned_to_id] = @params[:assigned_to_id]
    end

    def set_project_condition
      @conditions[:project_id] = @params[:project_id]
    end
  end
end