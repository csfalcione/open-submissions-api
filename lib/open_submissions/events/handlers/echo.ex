defmodule OpenSubmissions.Events.Handlers.Echo do
    alias OpenSubmissions.Events.Handlers.Handler
    @behaviour Handler

    @impl Handler
    def handle_event(event) do
        IO.inspect(event)
        {:ok, 0}
    end
end