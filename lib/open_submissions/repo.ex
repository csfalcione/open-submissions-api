defmodule OpenSubmissions.Repo do
  use Ecto.Repo,
    otp_app: :open_submissions,
    adapter: Ecto.Adapters.MySQL
end
