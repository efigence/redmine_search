# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
def set_plugin_fixtures_attachments_directory
    Attachment.storage_path = "#{Rails.root}/plugins/redmine_search/test/fixtures/files"
end