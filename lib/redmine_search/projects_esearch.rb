require_relative './date_condition'
module RedmineSearch
  class ProjectsEsearch < DateCondition

    def search params, allowed_to
      @params = params
      set_condition
      @results = Project.elastic_search( @params[:esearch],
        fields: fields,
        highlight: true,
        where: @conditions,
        operator: "and",
        order: { _score: 'desc'},
        page: @params[:page], per_page: 10 ) do |payload|
          if payload[:query] && payload[:query][:dis_max] && payload[:query][:dis_max][:queries]
            if @params[:esearch_mode] && @params[:esearch_mode] != 'analyzed'
              payload[:query][:dis_max][:queries].each do |query|
                query[:match].each do |k,v|
                  v[:type] = query_type
                end
              end
            end
          end
        end
      @results
    end

    private

    def fields
      @fields = [ "name^1.5", "description" ]
    end

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