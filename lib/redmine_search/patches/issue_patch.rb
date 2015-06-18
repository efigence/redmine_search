require_dependency 'issue'

module RedmineSearch
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          unloadable

          Searchkick.search_method_name = :elastic_search
          unless Issue.respond_to?(:searchkick_index)
            searchkick language: RedmineSearch.elastic_search_language,
              # index_name: 'redmine_issue',
              callbacks: :async,
              batch_size: 100,
              highlight: [:subject, :description],
              merge_mappings: true,
              mappings: {
                _default_: {
                  properties: {
                    issue_attachment: {
                      type: :nested,
                      include_in_parent: true,
                      properties: {
                        filename: {
                          type: :string,
                          fields: {
                            analyzed: {
                              type: "string",
                              term_vector: "with_positions_offsets"
                            }
                          }
                        },
                        text: {
                          type: :string,
                          fields: {
                            analyzed: {
                              type: "string",
                              term_vector: "with_positions_offsets"
                            }
                          }
                        }
                      }
                    },
                    issue_journal: {
                      type: :nested,
                      include_in_parent: true,
                      properties: {
                        notes: {
                          type: :string,
                          fields: {
                            analyzed: {
                              type: "string",
                              term_vector: "with_positions_offsets"
                            }
                          }
                        },
                      }
                    }
                  }
                }
              }
            def search_data
              attributes.merge(
                description: description.to_s.mb_chars.limit(32766).to_s,
                issue_attachment: attachments.order('id DESC').map(&:search_data),
                issue_journal: journals.order('id DESC').map(&:search_data)
              )
            end
          end
        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineSearch::Patches::IssuePatch)
  Issue.send(:include, RedmineSearch::Patches::IssuePatch)
end
