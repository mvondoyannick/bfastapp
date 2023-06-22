class UsersChart < Avo::Dashboards::ChartkickCard
  self.id = "users_chart"
  self.label = "Graphique utilisateurs"
  self.chart_type = :area_chart
  self.description = "Some tiny description"
  self.cols = 3
  self.rows = 3
  self.flush = true
  self.legend = true
  self.scale = true
  self.legend_on_left = true
  self.legend_on_right = true
  self.initial_range = 30
  self.ranges = {
    "7 jours": 7,
    "30 jours": 30,
    "60 jours": 60,
    "365 jours": 365,
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
        from = DateTime.current - range.to_i.days
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
    men = Customer.group("date(created_at)").where(sexe: "masculin").where(created_at: from..to).count(:id)
    women = Customer.group("date(created_at)").where(sexe: "feminin").where(created_at: from..to).count(:id)
    all = Customer.group("date(created_at)").where.not(sexe: ["masculin", "feminin"]).where(created_at: from..to).count(:id)

    puts "voila : #{men}"

    result [
      { name: "Hommes", data: men.map { |k, v| [k, v] }.to_h },
      { name: "Femme", data: women.map { |k, v| [k, v] }.to_h },
      { name: "all", data: all.map { |k, v| [k, v] }.to_h },
    # { name: "batch 2", data: e.map { |k, v| [k, rand(0..40)] }.to_h },
    # { name: "batch 3", data: e.map { |k, v| [k, rand(0..10)] }.to_h },
    # { name: "batch 3", data: e.map { |k, v| [k, rand(0..50)] }.to_h },

    ]
  end
end
