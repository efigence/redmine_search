require 'socket'
require 'stringio'

module RedmineSearch

  class Tika

    JAR_PATH = Rails.root.join('plugins/redmine_search/jar/tika.jar')

    class << self

      def read mode, filepath
        IO.popen "#{java} -Djava.awt.headless=true -jar #{Tika::JAR_PATH} #{switch(mode)} #{filepath}", 'r+' do |io|
          io.close_write
          return io.read
        end
        '' # sane default
      end

      def switch mode
        case mode
        when :text
          '-t'
        when :html
          '-h'
        when :metadata
          '-m -j'
        when :mimetype
          '-m -j'
        else
          ''
        end
      end

      private

      def java
        ENV['JAVA_HOME'] ? ENV['JAVA_HOME'] + '/bin/java' : 'java'
      end
    end
  end
end
