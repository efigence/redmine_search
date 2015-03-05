require_dependency 'wiki_page'

module RedmineSearch
  module Patches
    module WikiPagePatch
      def self.included(base)
        base.class_eval do
          unloadable
          default = "English"

          Searchkick.search_method_name = :elastic_search
          searchkick language: default unless WikiPage.respond_to?(:searchkick_index)
        end
      end
    end
  end
end

unless WikiPage.included_modules.include?(RedmineSearch::Patches::WikiPagePatch)
  WikiPage.send(:include, RedmineSearch::Patches::WikiPagePatch)
end
