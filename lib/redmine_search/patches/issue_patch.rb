require_dependency 'issue'

module RedmineSearch
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          unloadable

          def self.elastic_search_language
            default = "English"
            Setting.plugin_redmine_search['search_language'] || default
          rescue
            default
          end

          Searchkick.search_method_name = :elastic_search
          searchkick language: elastic_search_language unless Issue.respond_to?(:searchkick_index)
        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineSearch::Patches::IssuePatch)
  Issue.send(:include, RedmineSearch::Patches::IssuePatch)
end
