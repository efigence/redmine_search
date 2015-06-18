require_dependency 'projects_controller'

module RedmineSearch
  module Patches
    module SearchControllerPatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          def index
            question = params[:q] || ""
            question.strip!

            # quick jump to an issue
            if (m = question.match(/^#?(\d+)$/)) && (issue = Issue.visible.find_by_id(m[1].to_i))
              redirect_to issue_path(issue)
              return
            end

            path = {
              controller: 'searching',
              action: 'index',
              klass: "Issue",
              esearch: question
            }

            path[:project_id] = params[:project_id] unless params[:project_id].blank?

            redirect_to  path
          end
        end
      end


      module InstanceMethods

      end
    end
  end
end

unless SearchController.included_modules.include?(RedmineSearch::Patches::SearchControllerPatch)
  SearchController.send(:include, RedmineSearch::Patches::SearchControllerPatch)
end

