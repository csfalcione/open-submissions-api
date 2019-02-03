defmodule OpenSubmissions.Repo.Migrations.CreateTestCases do
  use Ecto.Migration

  def change do
    create table(:test_cases) do
      add :input, :text
      add :output, :text
      add :problem_id, references(:problems, on_delete: :nothing)

      timestamps()
    end

    create index(:test_cases, [:problem_id])
  end
end
