require_relative './date_condition'
module RedmineSearch
  class WikiPageEsearch < DateCondition

    def search params, allowed_to
      @params = params
      set_condition
      order_by = @params[:order].blank? ? 'desc' : @params[:order]
      @results = WikiPage.elastic_search @params[:esearch], where: @conditions, operator: "or", order: {created_on: order_by.to_sym}, page: @params[:page], per_page: 10
    end

    private

    def set_condition
      @conditions = {}
      set_available_projects       unless User.current.admin?
      set_date_condition           unless @params[:period].blank?
    end

    def set_available_projects
      ids = User.current.members.select('members.user_id, members.project_id, roles.permissions').where('permissions LIKE "% :view_wiki_pages\n%"').joins(:roles).map(&:project_id)
      @conditions[:project_id] = ids
    end
  end
end