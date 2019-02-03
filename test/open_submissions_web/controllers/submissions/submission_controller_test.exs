defmodule OpenSubmissionsWeb.Submissions.SubmissionControllerTest do
  use OpenSubmissionsWeb.ConnCase

  alias OpenSubmissions.Submissions
  alias OpenSubmissions.Submissions.Submission

  @create_attrs %{
    code: "some code"
  }
  @update_attrs %{
    code: "some updated code"
  }
  @invalid_attrs %{code: nil}

  def fixture(:submission) do
    {:ok, submission} = Submissions.create_submission(@create_attrs)
    submission
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all submissions", %{conn: conn} do
      conn = get(conn, Routes.submissions_submission_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create submission" do
    test "renders submission when data is valid", %{conn: conn} do
      conn = post(conn, Routes.submissions_submission_path(conn, :create), submission: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.submissions_submission_path(conn, :show, id))

      assert %{
               "id" => id,
               "code" => "some code"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.submissions_submission_path(conn, :create), submission: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update submission" do
    setup [:create_submission]

    test "renders submission when data is valid", %{conn: conn, submission: %Submission{id: id} = submission} do
      conn = put(conn, Routes.submissions_submission_path(conn, :update, submission), submission: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.submissions_submission_path(conn, :show, id))

      assert %{
               "id" => id,
               "code" => "some updated code"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, submission: submission} do
      conn = put(conn, Routes.submissions_submission_path(conn, :update, submission), submission: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete submission" do
    setup [:create_submission]

    test "deletes chosen submission", %{conn: conn, submission: submission} do
      conn = delete(conn, Routes.submissions_submission_path(conn, :delete, submission))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.submissions_submission_path(conn, :show, submission))
      end
    end
  end

  defp create_submission(_) do
    submission = fixture(:submission)
    {:ok, submission: submission}
  end
end
