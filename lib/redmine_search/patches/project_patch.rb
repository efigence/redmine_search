require_dependency 'project'

module RedmineSearch
  module Patches
    module ProjectPatch
      def self.included(base)
        base.class_eval do
          unloadable
          default = "English"

          Searchkick.search_method_name = :elastic_search
          searchkick language: default unless Project.respond_to?(:searchkick_index)
        end
      end
    end
  end
end

unless Project.included_modules.include?(RedmineSearch::Patches::ProjectPatch)
  Project.send(:include, RedmineSearch::Patches::ProjectPatch)
end
