require_relative './date_condition'
require_relative './helpers/search_helper'

module RedmineSearch
  class WikiPageEsearch < DateCondition

    def search params, allowed_to
      @params = params
      set_condition
      @results = WikiPage.elastic_search( @params[:esearch],
        fields: @fields,
        where: @conditions,
        highlight: {
          fields: {
            content_text: {},
            'wiki_attachment.filename' => {},
            'wiki_attachment.text' => {}
          }
        },
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
              unless @params[:attachment].blank?
                payload[:query][:dis_max][:queries] << attachment_nested_query('wiki')
              end
            end
          end
        end
    end

    private

    include RedmineSearch::SearchHelper

    def set_condition
      @conditions = {}
      @fields = [ "content_text^1.5" ]
      if !@params[:project_id].blank?
        set_project_condition
      else
        set_available_projects  unless User.current.admin?
      end
      set_date_condition  unless @params[:period].blank?
    end

    def set_project_condition
      @params[:project_id] = @params[:project_id].kind_of?(Array) ? @params[:project_id] : @params[:project_id].to_s.split(',')
      @conditions[:project_id] = @params[:project_id]
    end

    def set_available_projects
      ids = User.current.members.select('members.user_id, members.project_id, roles.permissions').where('permissions LIKE "% :view_wiki_pages\n%"').joins(:roles).map(&:project_id)
      @conditions[:project_id] = ids
    end
  end
end
