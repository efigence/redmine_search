module RedmineSearch
  class DateCondition
    private
    def set_date_condition
      case @params[:period]
      when "h"
        p = 1.hour.ago..DateTime.now
      when "24h"
        p = 24.hours.ago..DateTime.now
      when "w"
        p = 1.week.ago..DateTime.now
      when "m"
        p = 1.month.ago..DateTime.now
      when "y"
        p = 1.year.ago..DateTime.now
      when "dr"
        from = @params[:from].blank? ? DateTime.now : @params[:from].to_datetime
        to = @params[:to].blank? ? DateTime.now : @params[:to].to_datetime
        p = from > to ? to..from : from..to
      end
      @conditions[:created_on] = p
end
  end
end