defmodule OpenSubmissions.Problems.Problem do
  use Ecto.Schema
  import Ecto.Changeset


  schema "problems" do
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(problem, attrs) do
    problem
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
