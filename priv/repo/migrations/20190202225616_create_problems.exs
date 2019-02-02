defmodule OpenSubmissions.Repo.Migrations.CreateProblems do
  use Ecto.Migration

  def change do
    create table(:problems) do
      add :name, :string
      add :description, :text

      timestamps()
    end

  end
end
