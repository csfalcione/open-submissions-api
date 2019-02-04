defmodule OpenSubmissions.TestCases do
  @moduledoc """
  The TestCases context.
  """

  import Ecto.Query, warn: false
  alias OpenSubmissions.Repo

  alias OpenSubmissions.TestCases.TestCase

  @doc """
  Returns the list of test_cases.

  ## Examples

      iex> list_test_cases()
      [%TestCase{}, ...]

  """
  def list_test_cases do
    Repo.all(TestCase)
  end

  def list_by_problem(problem_id) do
    query = from case in "test_cases",
          where: case.problem_id == ^problem_id,
          select: %TestCase{id: case.id, input: case.input, output: case.output}
    Repo.all(query)
  end

  @doc """
  Gets a single test_case.

  Raises `Ecto.NoResultsError` if the Test case does not exist.

  ## Examples

      iex> get_test_case!(123)
      %TestCase{}

      iex> get_test_case!(456)
      ** (Ecto.NoResultsError)

  """
  def get_test_case!(id), do: Repo.get!(TestCase, id)

  @doc """
  Creates a test_case.

  ## Examples

      iex> create_test_case(%{field: value})
      {:ok, %TestCase{}}

      iex> create_test_case(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_test_case(attrs \\ %{}) do
    %TestCase{}
    |> TestCase.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a test_case.

  ## Examples

      iex> update_test_case(test_case, %{field: new_value})
      {:ok, %TestCase{}}

      iex> update_test_case(test_case, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_test_case(%TestCase{} = test_case, attrs) do
    test_case
    |> TestCase.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TestCase.

  ## Examples

      iex> delete_test_case(test_case)
      {:ok, %TestCase{}}

      iex> delete_test_case(test_case)
      {:error, %Ecto.Changeset{}}

  """
  def delete_test_case(%TestCase{} = test_case) do
    Repo.delete(test_case)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking test_case changes.

  ## Examples

      iex> change_test_case(test_case)
      %Ecto.Changeset{source: %TestCase{}}

  """
  def change_test_case(%TestCase{} = test_case) do
    TestCase.changeset(test_case, %{})
  end
end
