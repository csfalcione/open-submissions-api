defmodule OpenSubmissionsWeb.ProblemView do
  use OpenSubmissionsWeb, :view
  alias OpenSubmissionsWeb.ProblemView

  def render("index.json", %{problems: problems}) do
    %{data: render_many(problems, ProblemView, "problem.json")}
  end

  def render("show.json", %{problem: problem}) do
    %{data: render_one(problem, ProblemView, "problem.json")}
  end

  def render("problem.json", %{problem: problem}) do
    %{id: problem.id,
      name: problem.name,
      description: problem.description}
  end
end
