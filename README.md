# Redmine Search with Searchkick

This is work in progress, do not use it!

Make sure that you have installed Elastisearch or install from: example.com.

See sample config files in initializers/ and config/.

run: <tt> bundle exec rake redmine_search:reindex </tt>

# Searching
  - Go to /searching or click top menu button
  - For now there is few tabs available. When u switch between tabs then search date will be remembered.
  - To see all issues/projects/etc.. set query : "*".
  - 10 results per page + load more button
  - Searching in files(attachmets like doc/pdf/csv/xml/xlsx/odt/etc..)

# Available filters
  0. Base(in every tabs)
    - Date(periods/data range) - remembered on tab switch.
    - Order (newest/oldest) - by default order by newest.
  1. Issues
    - Projects
    - Tracker
    - User
    - Priority
    - Status
    - Issue type(private/public), by default only Admin user is allowed to search in private issues(change setting if you want allow some users or some groups).
    - Attachments - (without/with/only) - it's means that you can search issues only by attachments content or with or do not take attachments in search params.
  2. Projects
    - Project status(all/open/close/archive)
    - My role - ex. search Project 'x' where I'm 'Developer and Project Manager'
  3. Wiki Pages
    - Attachments

# Settings
  - Set allowed groups/users to search in private issues.
  - If you are using sidekiq then enable Index Async, to speed up (it's recommended because after_commit on attached file is really slow).
  - By default searchkick use English language and stemm. After change search language run reindexing.
