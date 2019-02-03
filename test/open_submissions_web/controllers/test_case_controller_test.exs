defmodule OpenSubmissionsWeb.TestCaseControllerTest do
  use OpenSubmissionsWeb.ConnCase

  alias OpenSubmissions.TestCases
  alias OpenSubmissions.TestCases.TestCase

  @create_attrs %{
    input: "some input",
    output: "some output"
  }
  @update_attrs %{
    input: "some updated input",
    output: "some updated output"
  }
  @invalid_attrs %{input: nil, output: nil}

  def fixture(:test_case) do
    {:ok, test_case} = TestCases.create_test_case(@create_attrs)
    test_case
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all test_cases", %{conn: conn} do
      conn = get(conn, Routes.test_case_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create test_case" do
    test "renders test_case when data is valid", %{conn: conn} do
      conn = post(conn, Routes.test_case_path(conn, :create), test_case: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.test_case_path(conn, :show, id))

      assert %{
               "id" => id,
               "input" => "some input",
               "output" => "some output"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.test_case_path(conn, :create), test_case: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update test_case" do
    setup [:create_test_case]

    test "renders test_case when data is valid", %{conn: conn, test_case: %TestCase{id: id} = test_case} do
      conn = put(conn, Routes.test_case_path(conn, :update, test_case), test_case: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.test_case_path(conn, :show, id))

      assert %{
               "id" => id,
               "input" => "some updated input",
               "output" => "some updated output"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, test_case: test_case} do
      conn = put(conn, Routes.test_case_path(conn, :update, test_case), test_case: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete test_case" do
    setup [:create_test_case]

    test "deletes chosen test_case", %{conn: conn, test_case: test_case} do
      conn = delete(conn, Routes.test_case_path(conn, :delete, test_case))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.test_case_path(conn, :show, test_case))
      end
    end
  end

  defp create_test_case(_) do
    test_case = fixture(:test_case)
    {:ok, test_case: test_case}
  end
end
