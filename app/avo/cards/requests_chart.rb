class RequestsChart < Avo::Dashboards::ChartkickCard
  self.id = "requests_chart"
  self.label = "Diagramme des requetes"
  self.chart_type = :column_chart
  # self.description = "Some tiny description"
  # self.cols = 2
  self.cols = 3
  self.rows = 3
  self.flush = true
  self.legend = true
  self.scale = true
  self.legend_on_left = true
  self.legend_on_right = true
  self.initial_range = 30
  self.ranges = {
    "7 days": 7,
    "30 days": 30,
    "60 days": 60,
    "365 days": 365,
    Today: "TODAY",
    "Month to date": "MTD",
    "Quarter to date": "QTD",
    "Year to date": "YTD",
    All: "ALL",
  }
  # self.chart_options = { library: { plugins: { legend: { display: true } } } }
  # self.flush = true

  def query
    points = 16
    i = Time.new.year.to_i - points
    base_data = Array.new(points).map do
      i += 1
      [i.to_s, rand(0..20)]
    end.to_h

    from = Date.today.beginning_of_year
    to = Date.today.end_of_year

    if range.present?
      if range.to_s == range.to_i.to_s
        # from = DateTime.current - range.to_i.days
        from = Time.at(0)
      else
        case range
        when "TODAY"
          from = DateTime.current.beginning_of_day
        when "MTD"
          from = DateTime.current.beginning_of_month
        when "QTD"
          from = DateTime.current.beginning_of_quarter
        when "YTD"
          from = DateTime.current.beginning_of_year
        when "ALL"
          from = Time.at(0)
        end
      end
    end

    request = Journal.group("date(created_at)").where(created_at: from..to).count(:id)

    result [
      { name: "Requetes", data: request.map { |k, v| [k, v] }.to_h },
    ]
  end
end
