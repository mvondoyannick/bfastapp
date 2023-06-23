class MyDashboard < Avo::Dashboards::BaseDashboard
  self.id = "my_dashboard"
  self.name = "Dashboard"
  # self.description = "Tiny dashboard description"
  # self.grid_cols = 3
  # self.visible = -> do
  #   true
  # end

  # cards go here
  card UsersMetric
  card UsersFemale
  card UsersMale
  card UsersUnknow
  card RequestMetric
  card UsersChart
  card RequestsChart
  card LangChart
  card StepsUsersChart
  # card UsersCount
end
