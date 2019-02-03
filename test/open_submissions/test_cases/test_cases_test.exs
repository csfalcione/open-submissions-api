defmodule OpenSubmissions.TestCasesTest do
  use OpenSubmissions.DataCase

  alias OpenSubmissions.TestCases

  describe "test_cases" do
    alias OpenSubmissions.TestCases.TestCase

    @valid_attrs %{input: "some input", output: "some output"}
    @update_attrs %{input: "some updated input", output: "some updated output"}
    @invalid_attrs %{input: nil, output: nil}

    def test_case_fixture(attrs \\ %{}) do
      {:ok, test_case} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TestCases.create_test_case()

      test_case
    end

    test "list_test_cases/0 returns all test_cases" do
      test_case = test_case_fixture()
      assert TestCases.list_test_cases() == [test_case]
    end

    test "get_test_case!/1 returns the test_case with given id" do
      test_case = test_case_fixture()
      assert TestCases.get_test_case!(test_case.id) == test_case
    end

    test "create_test_case/1 with valid data creates a test_case" do
      assert {:ok, %TestCase{} = test_case} = TestCases.create_test_case(@valid_attrs)
      assert test_case.input == "some input"
      assert test_case.output == "some output"
    end

    test "create_test_case/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TestCases.create_test_case(@invalid_attrs)
    end

    test "update_test_case/2 with valid data updates the test_case" do
      test_case = test_case_fixture()
      assert {:ok, %TestCase{} = test_case} = TestCases.update_test_case(test_case, @update_attrs)
      assert test_case.input == "some updated input"
      assert test_case.output == "some updated output"
    end

    test "update_test_case/2 with invalid data returns error changeset" do
      test_case = test_case_fixture()
      assert {:error, %Ecto.Changeset{}} = TestCases.update_test_case(test_case, @invalid_attrs)
      assert test_case == TestCases.get_test_case!(test_case.id)
    end

    test "delete_test_case/1 deletes the test_case" do
      test_case = test_case_fixture()
      assert {:ok, %TestCase{}} = TestCases.delete_test_case(test_case)
      assert_raise Ecto.NoResultsError, fn -> TestCases.get_test_case!(test_case.id) end
    end

    test "change_test_case/1 returns a test_case changeset" do
      test_case = test_case_fixture()
      assert %Ecto.Changeset{} = TestCases.change_test_case(test_case)
    end
  end
end
