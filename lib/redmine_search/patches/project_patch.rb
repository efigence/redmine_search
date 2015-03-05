require_dependency 'project'

module RedmineSearch
  module Patches
    module ProjectPatch
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
          searchkick language: elastic_search_language unless Project.respond_to?(:searchkick_index)
        end
      end
    end
  end
end

unless Project.included_modules.include?(RedmineSearch::Patches::ProjectPatch)
  Project.send(:include, RedmineSearch::Patches::ProjectPatch)
end
