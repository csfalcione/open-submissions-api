defmodule OpenSubmissions.Events.Handlers.TestFinishedWebSocket do
    alias OpenSubmissions.Events.Handlers.Handler
    @behaviour Handler

    @impl Handler
    def handle_event(%{submission_id: sub_id} = event) do
        OpenSubmissionsWeb.Endpoint.broadcast!("submission:#{sub_id}", "test_finished", event)
    end
end