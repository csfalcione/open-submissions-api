use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :open_submissions, OpenSubmissionsWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :open_submissions, OpenSubmissions.Repo,
  username: "root",
  password: "",
  database: "open_submissions_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
