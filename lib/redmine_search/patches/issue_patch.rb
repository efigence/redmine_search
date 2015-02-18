require_dependency 'issue'

module RedmineSearch
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          unloadable
          default = "English"

          Searchkick.search_method_name = :elastic_search
          searchkick language: default unless Issue.respond_to?(:searchkick_index)
        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineSearch::Patches::IssuePatch)
  Issue.send(:include, RedmineSearch::Patches::IssuePatch)
end
