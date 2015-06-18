module RedmineSearch
  module SearchHelper

    def query_type
      @query_type ||= case @params[:esearch_mode]
                      when 'analyzed'
                        "boolean"
                      when 'phrase'
                        "phrase"
                      else
                        "boolean"
                      end
    end

    def journal_nested_query kind=nil
      { nested: {
        path: "#{kind}_journal",
        score_mode: "max",
        query: {
          bool: {
            should: [
              { match: {
                "#{kind}_journal.notes" => {
                  query: @params[:esearch] ,
                  fuzziness: 1,
                  max_expansions: 3,
                  type: query_type,
                  analyzer: "searchkick_search" } } },
              { match: {
                "#{kind}_journal.notes" => {
                  query: @params[:esearch] ,
                  fuzziness: 1,
                  max_expansions: 3,
                  type: query_type,
                  analyzer: "searchkick_search2" } } }
            ] } } } }
    end

    def attachment_nested_query kind=nil
      { nested: {
        path: "#{kind}_attachment",
        score_mode: "max",
        query: {
          bool: {
            should: [
              { match: {
                "#{kind}_attachment.filename" => {
                  query: @params[:esearch] ,
                  fuzziness: 1,
                  max_expansions: 3,
                  type: query_type,
                  analyzer: "searchkick_search" } } },
              { match: {
                "#{kind}_attachment.filename" => {
                  query: @params[:esearch] ,
                  fuzziness: 1,
                  max_expansions: 3,
                  type: query_type,
                  analyzer: "searchkick_search2" } } },
              { match: {
                "#{kind}_attachment.text" => {
                  query: @params[:esearch] ,
                  fuzziness: 1,
                  max_expansions: 3,
                  type: query_type,
                  analyzer: "searchkick_search" } } },
              { match: {
                "#{kind}_attachment.text" => {
                  query: @params[:esearch] ,
                  fuzziness: 1,
                  max_expansions: 3,
                  type: query_type,
                  analyzer: "searchkick_search2" } }
              } ] } } } }
    end
  end
end
