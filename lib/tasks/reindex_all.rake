namespace :redmine_search do
  desc "Reindex Models"
  task :reindex => :environment do
    puts "Reindexing"
    %w(Issue Project).each do |model|
      puts "#{model} reindex start."
      model.constantize.reindex
      puts "#{model} indexing done."
    end
  end
end