defmodule OpenSubmissions.Repo.Migrations.CreateProblems do
  use Ecto.Migration

  def change do
    create table(:problems) do
      add :name, :string
      add :description, :text

      add :function_name, :string
      add :output_type, :string

      add :param1_type, :string
      add :param1_name, :string

      add :param2_type, :string
      add :param2_name, :string

      add :param3_type, :string
      add :param3_name, :string

      add :param4_type, :string
      add :param4_name, :string


      timestamps()
    end

  end
end
