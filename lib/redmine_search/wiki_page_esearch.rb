require_relative './date_condition'
module RedmineSearch
  class WikiPageEsearch < DateCondition

    def search params, allowed_to
      @params = params
      # set_condition
      order_by = @params[:order].blank? ? 'desc' : @params[:order]
      @results = WikiPage.elastic_search @params[:esearch], fields: ["title", "text"], where: @conditions, operator: "or", order: {created_on: order_by.to_sym}, page: @params[:page], per_page: 10
    end

    private

    def set_condition
      @conditions = {}
      set_available_projects       unless User.current.admin?
      set_date_condition           unless @params[:period].blank?
      set_project_status_condition unless @params[:status].blank?
      set_project_roles_condition  unless @params[:role_id].blank?
    end

    def set_available_projects
      @conditions[:id] = User.current.projects.collect(&:id)
    end

    def set_project_roles_condition
      ids = Member.joins(:roles).where(members: {user_id: User.current.id}, roles: {id: @params[:role_id]}).collect(&:project_id)
      @conditions[:id] = ids
    end

    def set_project_status_condition
      @conditions[:status] = @params[:status]
    end

  end
end