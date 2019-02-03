defmodule OpenSubmissions.Problems.Problem do
  use Ecto.Schema
  import Ecto.Changeset


  schema "problems" do
    field :description, :string
    field :name, :string

    field :function_name, :string
    field :output_type, :string

    field :param1_type, :string
    field :param1_name, :string

    field :param2_type, :string
    field :param2_name, :string

    field :param3_type, :string
    field :param3_name, :string

    field :param4_type, :string
    field :param4_name, :string

    timestamps()
  end

  @doc false
  def changeset(problem, attrs) do
    problem
    |> cast(attrs, [
      :name,
      :description,
      :function_name,
      :output_type,
      :param1_type,
      :param1_name,
      :param2_type,
      :param2_name,
      :param3_type,
      :param3_name,
      :param4_type,
      :param4_name
    ])
    |> validate_required([:name, :description])
  end
end
