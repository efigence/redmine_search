require_relative './date_condition'

module RedmineSearch
  class IssuesEsearch < DateCondition

    def search params, allowed_to
      @allowed_to = allowed_to
      @params = params
      set_condition
      order_by = @params[:order].blank? ? 'desc' : @params[:order]
      @results = Issue.elastic_search @params[:esearch],
                      fields: @fields,
                      where: @conditions,
                      operator: "or",
                      order: {created_on: order_by.to_sym},
                      page: @params[:page], per_page: 10
    end

    private

    def set_condition
      @conditions = {}
      @fields = ["subject^1.5", "description"]
      set_issues_condition         unless User.current.admin?
      set_date_condition           unless @params[:period].blank?
      set_project_condition        unless @params[:project_id].blank?
      set_assigned_condition       unless @params[:assigned_to_id].blank?
      set_tracker_condition        unless @params[:tracker_id].blank?
      set_priority_condition       unless @params[:priority_id].blank?
      set_status_condition         unless @params[:status_id].blank?
      set_is_private_condition     unless (@params[:is_private].blank? || @params[:is_private] == 'all') && @allowed_to
      set_attachments_condition    unless @params[:attachment].blank?
    end

    def set_attachments_condition
      if @params[:attachment] == "only"
        @fields = ["attachment", "attachment_text"]
      else
        @fields << "attachment"
        @fields << "attachment_text"
      end
    end

    def set_is_private_condition
      return @conditions[:is_private] = false if !@allowed_to
      p = @params[:is_private] == "false" ? false : true
      @conditions[:is_private] = p
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