defmodule OpenSubmissionsWeb.SubmissionController do
  use OpenSubmissionsWeb, :controller

  alias OpenSubmissions.Submissions
  alias OpenSubmissions.Submissions.Submission
  alias OpenSubmissions.Problems
  alias OpenSubmissions.Execution.Execution

  action_fallback OpenSubmissionsWeb.FallbackController

  def submit(conn, %{"id" => problem_id, "submission" => submission_params}) do
    submission_params = Map.merge(submission_params, %{"problem_id" => problem_id, "status" => "pending"})
    with {:ok, %Submission{problem_id: problem_id} = submission} <- Submissions.create_submission(submission_params) do
      _problem = Problems.get_problem!(problem_id)
#      cases =
#      result = Execution.execute_all(submission, problem)
      conn
      |> put_status(:created)
      |> render("show.json", submission: submission)
    end
  end

  def index(conn, _params) do
    submissions = Submissions.list_submissions()
    render(conn, "index.json", submissions: submissions)
  end

  def show(conn, %{"id" => id}) do
    submission = Submissions.get_submission!(id)
    render(conn, "show.json", submission: submission)
  end

  def update(conn, %{"id" => id, "submission" => submission_params}) do
    submission = Submissions.get_submission!(id)

    with {:ok, %Submission{} = submission} <- Submissions.update_submission(submission, submission_params) do
      render(conn, "show.json", submission: submission)
    end
  end

  def delete(conn, %{"id" => id}) do
    submission = Submissions.get_submission!(id)

    with {:ok, %Submission{}} <- Submissions.delete_submission(submission) do
      send_resp(conn, :no_content, "")
    end
  end
end
