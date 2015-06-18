require_dependency 'journal'

module RedmineSearch
  module Patches
    module JournalPatch
      def self.included(base)
        base.class_eval do
          unloadable

          def search_data
            {
              notes: notes.to_s.mb_chars.limit(32766).to_s
            }
          end

          after_commit :reindex_association

          private

          def reindex_association
            if self.journalized_type
              model = self.journalized_type.constantize
              if model.respond_to?(:searchkick_index)
                id = self.journalized_id.to_i
                async_reindex = Setting.plugin_redmine_search['async_indexing'] == "1"
                async_reindex ? model.find(id).reindex_async : model.find(id).reindex
              end
            end
          end

        end
      end
    end
  end
end

unless Journal.included_modules.include?(RedmineSearch::Patches::JournalPatch)
  Journal.send(:include, RedmineSearch::Patches::JournalPatch)
end
