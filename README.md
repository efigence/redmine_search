# Redmine Search with Searchkick

This plugin allows users to search information in Project, Issues, WikiPages by fuzzy or phrase method.
There is available many filters for each tabs. Moreover this plugin overrides redmine core search.

## Install
1. Make sure that JAVA and Elasticsearch was installed
 - Install ElasticSearch from <tt>http://www.elasticsearch.org/download/ </tt>
 - Test your connection <tt>curl -XGET 'http://localhost:9200'</tt> - status should equal 200
 - Switch search engine in Admin panel to <tt>Elasticsearch Engine</tt> and choose language. (by default is English)
 - Run Elasticsearch <tt>sudo service elasticsearch start</tt>
 - In main redmine catalog run: <tt> bundle exec rake redmine_search:reindex </tt>
2. If you want stop Elasticsearch engine
 - Run <tt>sudo service elasticsearch stop</tt>
3. If you are using PROXY
 - move <tt>config/initializers/elasticsearch.rb.default</tt> to <tt>redmine/config/initializers/</tt>
 - move <tt>config/elasticsearch.yml.default</tt> to <tt>redmine/config/</tt>
4. Another languages
 - Install plugin to elasticsearch, guide: http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-plugins.html
 - Write configuration(settings) in issue_patch.rb and add language to languages.yml file.
5. Elastic Management
 - If you want manege your elastic and indexes, then install plugin: http://www.elastichq.org/
 - If it's done then go to: <tt>http://localhost:9200/_plugin/HQ/</tt> and connect.

## Searching
  - Search will be available in top menu and in top right input search.
  - When you switch between tabs then search date will be remembered.
  - To see all issues/projects/etc.. set query : "*".
  - 10 results per page + load more button
  - Searching in files(attachmets like doc/pdf/csv/xml/xlsx/odt/etc..)
  - The matching words will be highlighted.

## Available filters
  0. Base(each tabs)
    - Date(periods/data range) - remembered on tab switch.
    - Order (newest/oldest) - by default order by newest.
  1. Issues
    - Projects
    - Tracker
    - User
    - Priority
    - Status
    - Issue type(private/public), by default only Admin user is allowed to search in private issues(change setting if you want allow some users or some groups).
    - With attachments - it's means that you can search issues and attachments content.
  2. Projects
    - Project status(all/open/close/archive)
    - My role - ex. search Project 'x' where I'm 'Developer and Project Manager'
  3. Wiki Pages
    - Attachments

## Settings
  - Set allowed groups/users to search in private issues.
  - If you are using sidekiq then enable Index Async, to speed up (it's recommended because after_commit on attached file is really slow).
  - By default searchkick use English language and stemm. After change search language run reindexing.

## License
  Redmine search plugin.
  Copyright (C) 2015 Efigence S.A.

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.