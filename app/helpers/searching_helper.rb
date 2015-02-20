module SearchingHelper

  def periods
    [
      [l(:label_last_hour), "h"],
      [l(:label_last_24_hours), "24h"],
      [l(:label_last_week), "w"],
      [l(:label_last_month), "m"],
      [l(:label_last_year),"y"]
    ]
  end
end
