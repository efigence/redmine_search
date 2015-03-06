require 'yomu'
require_dependency 'wiki_page'

module RedmineSearch
  module Patches
    module WikiPagePatch
      def self.included(base)
        base.class_eval do
          unloadable
          Searchkick.search_method_name = :elastic_search
          searchkick language: RedmineSearch.elastic_search_language unless WikiPage.respond_to?(:searchkick_index)
          # , settings: {properties: {content_text: {type: 'string'}}}
          def search_data
            attributes.merge(
              content_text: content.text,
              project_id: wiki.project_id,
              attachment: attachments.map(&:filename),
              attachment_text: RedmineSearch.read_attached_files(attachments)
            )
          end
        end
      end
    end
  end
end

unless WikiPage.included_modules.include?(RedmineSearch::Patches::WikiPagePatch)
  WikiPage.send(:include, RedmineSearch::Patches::WikiPagePatch)
end
