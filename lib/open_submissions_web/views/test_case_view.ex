defmodule OpenSubmissionsWeb.TestCaseView do
  use OpenSubmissionsWeb, :view
  alias OpenSubmissionsWeb.TestCaseView

  def render("index.json", %{test_cases: test_cases}) do
    %{data: render_many(test_cases, TestCaseView, "test_case.json")}
  end

  def render("show.json", %{test_case: test_case}) do
    %{data: render_one(test_case, TestCaseView, "test_case.json")}
  end

  def render("test_case.json", %{test_case: test_case}) do
    %{id: test_case.id,
      problem_id: test_case.problem_id,
      input: test_case.input,
      output: test_case.output}
  end
end
