module SearchingHelper

  def periods
    [
      [l(:label_period), nil],
      [l(:label_last_hour), "h"],
      [l(:label_last_24_hours), "24h"],
      [l(:label_last_week), "w"],
      [l(:label_last_month), "m"],
      [l(:label_last_year),"y"],
      [date_range,"dr"]
    ]
  end

  def order_options
    [
      [l(:label_order_desc), "desc"],
      [l(:label_order_asc), "asc"]
    ]
  end

  def project_option
    [
      [l(:label_project_all), nil],
      [l(:label_project_open), Project::STATUS_ACTIVE],
      [l(:label_project_close), Project::STATUS_CLOSED],
      [l(:label_project_archive), Project::STATUS_ARCHIVED]
    ]
  end

  def issue_privacy_option
    [
      [l(:label_all), 'all'],
      [l(:label_public), false],
      [l(:label_private), true]
    ]
  end

  def date_range
    params[:period] == "dr" ? "#{params[:from]} - #{params[:to]}" : l(:label_data_range)
  end
end
