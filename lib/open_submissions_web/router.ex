defmodule OpenSubmissionsWeb.Router do
  use OpenSubmissionsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", OpenSubmissionsWeb do
    pipe_through :api
    resources "/problems", ProblemController
    resources "/test_cases", TestCaseController, except: [:new, :edit]
    get "/submissions/:id", SubmissionController, :show
    post "/problems/:id/submissions", SubmissionController, :submit
  end
end
