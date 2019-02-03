defmodule OpenSubmissionsWeb.SubmissionView do
  use OpenSubmissionsWeb, :view
  alias OpenSubmissionsWeb.SubmissionView

  def render("index.json", %{submissions: submissions}) do
    %{data: render_many(submissions, SubmissionView, "submission.json")}
  end

  def render("show.json", %{submission: submission}) do
    %{data: render_one(submission, SubmissionView, "submission.json")}
  end

  def render("submission.json", %{submission: submission}) do
    %{id: submission.id,
      status: submission.status,
      language: submission.language,
      code: submission.code}
  end
end
