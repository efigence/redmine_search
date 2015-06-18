# encoding: utf-8
require 'redmine'
require 'redmine_search'

Redmine::Plugin.register :redmine_search do
  name 'Redmine Search plugin'
  author 'Marcin Świątkiewicz'
  description "This plugins allows you"
  version '0.0.2'
  url 'https://github.com/efigence/redmine_search'
  author_url 'http://www.efigence.com/'

  menu :top_menu,
    :searching, { controller: 'searching', action: 'index'},
    caption: :label_search, :after => :help,
    :if => proc { User.current.logged? }

  default_settings = {
    'search_language' => 'English',
    'file_size' => "5",
    'async_indexing' => "0"
  }

  settings(:default => default_settings, :partial => 'settings/redmine_search_settings')
end

ActiveSupport.on_load :after_initialize, yield: true do
  require 'redmine_search/patches/search_controller_patch'
  require 'redmine_search/patches/issue_patch'
  require 'redmine_search/patches/project_patch'
  require 'redmine_search/patches/wiki_page_patch'
  require 'redmine_search/patches/journal_patch'
  require 'redmine_search/patches/attachment_patch'
end
