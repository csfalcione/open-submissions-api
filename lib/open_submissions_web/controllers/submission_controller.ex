defmodule OpenSubmissionsWeb.SubmissionController do
  use OpenSubmissionsWeb, :controller

  alias OpenSubmissions.Submissions
  alias OpenSubmissions.Submissions.Submission

  action_fallback OpenSubmissionsWeb.FallbackController

  def submit(conn, %{"id" => problem_id, "submission" => submission_params}) do
    submission_params = Map.merge(submission_params, %{"problem_id" => problem_id, "status" => "pending"})
    with {:ok, %Submission{} = submission} <- Submissions.create_submission(submission_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.submission_path(conn, :show, submission))
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
