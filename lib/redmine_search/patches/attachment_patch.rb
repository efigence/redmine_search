require_dependency 'attachment'

module RedmineSearch
  module Patches
    module AttachmentPatch
      def self.included(base)
        base.class_eval do
          unloadable

          after_commit :reindex_association 

          def reindex_association
            model = self.container_type.constantize
            if model.respond_to?(:searchkick_index)
              id = self.container_id.to_i
              model.find(id).reindex
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
