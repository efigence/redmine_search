require_dependency 'wiki_page'

module RedmineSearch
  module Patches
    module WikiPagePatch
      def self.included(base)
        base.class_eval do
          unloadable

          Searchkick.search_method_name = :elastic_search
          unless WikiPage.respond_to?(:searchkick_index)
            searchkick language: RedmineSearch.elastic_search_language,
              # index_name: 'redmine_wiki',
              callbacks: :async,
              highlight: [:content_text],
              merge_mappings: true,
              mappings: {
                _default_: {
                  properties: {
                    wiki_attachment: {
                      type: :nested,
                      include_in_parent: true,
                      properties: {
                        filename: {
                          type: :string,
                          term_vector: :with_positions_offsets
                        },
                        text: {
                          type: :string,
                          term_vector: :with_positions_offsets
                        }
                      }
                    }
                  }
                }
              }
          end
          # , settings: {properties: {content_text: {type: 'string'}}}
          def search_data
            attributes.merge(
              content_text: content.text.to_s.mb_chars.limit(32766).to_s,
              project_id: wiki.project_id,
              wiki_attachment: attachments.order('id DESC').map(&:search_data),
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
