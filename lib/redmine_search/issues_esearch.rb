require_relative './date_condition'
require_relative './helpers/search_helper'

module RedmineSearch
  class IssuesEsearch < DateCondition

    def search params, allowed_to
      @allowed_to = allowed_to
      @params = params
      set_condition
      @results = Issue.elastic_search( @params[:esearch],
        fields: @fields,
        where: @conditions,
        highlight: {
          fields: {
            subject: {},
            description: {},
            'issue_attachment.filename' => {},
            'issue_attachment.text' => {},
            'issue_journal.notes' => {}
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
            end

            payload[:query][:dis_max][:queries] << journal_nested_query('issue')
            unless @params[:attachment].blank?
              payload[:query][:dis_max][:queries] << attachment_nested_query('issue')
            end
          end
        end
      @results
    end

    private

    include RedmineSearch::SearchHelper

    def set_condition
      @conditions = {}
      @fields = [ "subject^1.5", "description" ]
      set_issues_condition         unless User.current.admin?
      set_date_condition           unless @params[:period].blank?
      set_project_condition        unless @params[:project_id].blank?
      set_assigned_condition       unless @params[:assigned_to_id].blank?
      set_tracker_condition        unless @params[:tracker_id].blank?
      set_priority_condition       unless @params[:priority_id].blank?
      set_status_condition         unless @params[:status_id].blank?
      set_is_private_condition     unless (@params[:is_private].blank? || @params[:is_private] == 'all') && @allowed_to
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
      @params[:project_id] = @params[:project_id].kind_of?(Array) ? @params[:project_id] : @params[:project_id].to_s.split(',')
      @conditions[:project_id] = @params[:project_id]
    end
  end
end