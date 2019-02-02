defmodule OpenSubmissionsWeb.ProblemController do
  use OpenSubmissionsWeb, :controller

  alias OpenSubmissions.Problems
  alias OpenSubmissions.Problems.Problem

  action_fallback OpenSubmissionsWeb.FallbackController

  def index(conn, _params) do
    problems = Problems.list_problems()
    render(conn, "index.json", problems: problems)
  end

  def create(conn, %{"problem" => problem_params}) do
    with {:ok, %Problem{} = problem} <- Problems.create_problem(problem_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.problem_path(conn, :show, problem))
      |> render("show.json", problem: problem)
    end
  end

  def show(conn, %{"id" => id}) do
    problem = Problems.get_problem!(id)
    render(conn, "show.json", problem: problem)
  end

  def update(conn, %{"id" => id, "problem" => problem_params}) do
    problem = Problems.get_problem!(id)

    with {:ok, %Problem{} = problem} <- Problems.update_problem(problem, problem_params) do
      render(conn, "show.json", problem: problem)
    end
  end

  def delete(conn, %{"id" => id}) do
    problem = Problems.get_problem!(id)

    with {:ok, %Problem{}} <- Problems.delete_problem(problem) do
      send_resp(conn, :no_content, "")
    end
  end
end
