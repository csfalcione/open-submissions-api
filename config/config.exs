# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :open_submissions,
  ecto_repos: [OpenSubmissions.Repo]

# Configures the endpoint
config :open_submissions, OpenSubmissionsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "I5fNvyTqYIkLGyqRnGEzak0iqrl5syffFixY5Ee04/5MvzhknRUphihvkz0xD7QA",
  render_errors: [view: OpenSubmissionsWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: OpenSubmissions.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :open_submissions,
  event_handlers: [
    test_executed: [
      OpenSubmissions.Events.Handlers.Echo,
      OpenSubmissions.Events.Handlers.TestFinishedWebSocket,
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
