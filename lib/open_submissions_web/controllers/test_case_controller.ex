defmodule OpenSubmissionsWeb.TestCaseController do
  use OpenSubmissionsWeb, :controller

  alias OpenSubmissions.TestCases
  alias OpenSubmissions.TestCases.TestCase

  action_fallback OpenSubmissionsWeb.FallbackController

  def index(conn, _params) do
    test_cases = TestCases.list_test_cases()
    render(conn, "index.json", test_cases: test_cases)
  end

  def create(conn, %{"test_case" => test_case_params}) do
    with {:ok, %TestCase{} = test_case} <- TestCases.create_test_case(test_case_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.test_case_path(conn, :show, test_case))
      |> render("show.json", test_case: test_case)
    end
  end

  def show(conn, %{"id" => id}) do
    test_case = TestCases.get_test_case!(id)
    render(conn, "show.json", test_case: test_case)
  end

  def update(conn, %{"id" => id, "test_case" => test_case_params}) do
    test_case = TestCases.get_test_case!(id)

    with {:ok, %TestCase{} = test_case} <- TestCases.update_test_case(test_case, test_case_params) do
      render(conn, "show.json", test_case: test_case)
    end
  end

  def delete(conn, %{"id" => id}) do
    test_case = TestCases.get_test_case!(id)

    with {:ok, %TestCase{}} <- TestCases.delete_test_case(test_case) do
      send_resp(conn, :no_content, "")
    end
  end
end
