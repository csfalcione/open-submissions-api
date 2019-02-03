defmodule OpenSubmissions.Submissions.Submission do
  use Ecto.Schema
  import Ecto.Changeset


  schema "submissions" do
    field :code, :string
    field :language, :string
    field :status, :string
    field :problem_id, :id

    timestamps()
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:code, :language, :status])
    |> validate_required([:code, :language, :status])
  end
end
