defmodule OpenSubmissions.Repo.Migrations.CreateSubmissions do
  use Ecto.Migration

  def change do
    create table(:submissions) do
      add :problem_id, references(:problems, on_delete: :delete_all)
      add :status, :string
      add :language, :string
      add :code, :text

      timestamps()
    end

    create index(:submissions, [:problem_id])
  end
end
