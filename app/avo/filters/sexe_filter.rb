class SexeFilter < Avo::Filters::SelectFilter
  self.name = "Filtre par sexe"
  # self.visible = -> do
  #   true
  # end

  def apply(request, query, value)
    case value
    when "published"
      query.where(sexe: "feminin")
    when "unpublished"
      query.where(sexe: "masculin")
    else
      query
    end
    # query
  end

  def options
    {
      published: "Feminin",
      unpublished: "Masculin",
    }
  end
end
