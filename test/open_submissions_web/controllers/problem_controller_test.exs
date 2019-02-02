defmodule OpenSubmissionsWeb.ProblemControllerTest do
  use OpenSubmissionsWeb.ConnCase

  alias OpenSubmissions.Problems
  alias OpenSubmissions.Problems.Problem

  @create_attrs %{
    description: "some description",
    name: "some name"
  }
  @update_attrs %{
    description: "some updated description",
    name: "some updated name"
  }
  @invalid_attrs %{description: nil, name: nil}

  def fixture(:problem) do
    {:ok, problem} = Problems.create_problem(@create_attrs)
    problem
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all problems", %{conn: conn} do
      conn = get(conn, Routes.problem_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create problem" do
    test "renders problem when data is valid", %{conn: conn} do
      conn = post(conn, Routes.problem_path(conn, :create), problem: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.problem_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.problem_path(conn, :create), problem: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update problem" do
    setup [:create_problem]

    test "renders problem when data is valid", %{conn: conn, problem: %Problem{id: id} = problem} do
      conn = put(conn, Routes.problem_path(conn, :update, problem), problem: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.problem_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, problem: problem} do
      conn = put(conn, Routes.problem_path(conn, :update, problem), problem: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete problem" do
    setup [:create_problem]

    test "deletes chosen problem", %{conn: conn, problem: problem} do
      conn = delete(conn, Routes.problem_path(conn, :delete, problem))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.problem_path(conn, :show, problem))
      end
    end
  end

  defp create_problem(_) do
    problem = fixture(:problem)
    {:ok, problem: problem}
  end
end
