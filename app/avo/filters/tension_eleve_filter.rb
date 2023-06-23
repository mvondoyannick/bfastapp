class TensionEleveFilter < Avo::Filters::SelectFilter
  self.name = "Tension à risque"
  # self.visible = -> do
  #   true
  # end

  def apply(request, query, value)
    case value
    when "risk"
      query.where(tension_droite: 100.180)
    when "norisk"
      query.where(tension_droite: 90..100)
    else
      query
    end
    query
  end

  def options
    {
      risk: "A risque",
      norisk: "Normale",
    }
  end
end
