# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

def set_plugin_fixtures_attachments_directory
    Attachment.storage_path = "#{Rails.root}/plugins/redmine_search/test/fixtures/files"
end

class ActionController::TestCase

  # XXX: redmine master branch is not compatible with other branches
  fx = [:attachments, :projects, :issues, :members, :wikis, :wiki_pages, :wiki_contents]
  fx2 = [:users]

  fixtures *fx
  fixtures *fx2

  if Gem::Version.new(Rails.version) >= Gem::Version.new('4.0')
    ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/master/', fx2)
  else
    ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/default/', fx2)
  end

  ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/', fx)
end