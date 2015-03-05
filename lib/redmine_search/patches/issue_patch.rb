require_dependency 'issue'

module RedmineSearch
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          unloadable

          Searchkick.search_method_name = :elastic_search
          searchkick language: RedmineSearch.elastic_search_language unless Issue.respond_to?(:searchkick_index)
        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineSearch::Patches::IssuePatch)
  Issue.send(:include, RedmineSearch::Patches::IssuePatch)
end
