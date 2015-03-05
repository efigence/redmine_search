require_dependency 'wiki_page'

module RedmineSearch
  module Patches
    module WikiPagePatch
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
          searchkick language: elastic_search_language unless WikiPage.respond_to?(:searchkick_index)
        end
      end
    end
  end
end

unless WikiPage.included_modules.include?(RedmineSearch::Patches::WikiPagePatch)
  WikiPage.send(:include, RedmineSearch::Patches::WikiPagePatch)
end
