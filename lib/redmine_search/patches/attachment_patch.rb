require_dependency 'attachment'

module RedmineSearch
  module Patches
    module AttachmentPatch
      def self.included(base)
        base.class_eval do
          unloadable

          after_commit :reindex_association

          def search_data
            {
              filename: filename.to_s.mb_chars.limit(32766).to_s,
              text: read_attached_file(diskfile).to_s.mb_chars.limit(32766).to_s
            }
          end

          private

          def read_attached_file filepath
            max_file_size = Setting.plugin_redmine_search['file_size'].to_i.megabytes
            begin
              if File.exists?(filepath) && File.size?(filepath) && File.size?(filepath) <= max_file_size
                return Tika.read( :text, filepath ) #only text, without encoding etc..
              end
            rescue Errno::EPIPE => ex
              Rails.logger.error "Could not parse attachment file for search #{ ex.message }"
            end
            return ''
          end

          def reindex_association
            if self.container_type
              model = self.container_type.constantize
              if model.respond_to?(:searchkick_index)
                id = self.container_id.to_i
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

unless Attachment.included_modules.include?(RedmineSearch::Patches::AttachmentPatch)
  Attachment.send(:include, RedmineSearch::Patches::AttachmentPatch)
end
