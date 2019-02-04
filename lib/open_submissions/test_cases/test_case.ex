defmodule OpenSubmissions.TestCases.TestCase do
  use Ecto.Schema
  import Ecto.Changeset

  @derive{Jason.Encoder, only: [:input, :output, :id]}
  schema "test_cases" do
    field :input, :string
    field :output, :string
    field :problem_id, :id

    timestamps()
  end

  @doc false
  def changeset(test_case, attrs) do
    test_case
    |> cast(attrs, [:input, :output, :problem_id])
    |> validate_required([:input, :output, :problem_id])
  end
end
