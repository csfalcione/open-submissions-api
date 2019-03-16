defmodule OpenSubmissions.Events.PubSub do
    
    def publish(topic, event) do
        get_handlers(topic)
        |> Task.async_stream(fn handler -> handler.handle_event(event) end)
        |> Stream.run
        :ok
    end

    # all handlers implement OpenSubmissions.Events.Handlers.Handler
    def get_handlers(topic) do
        Application.get_env(:open_submissions, :event_handlers)[topic]
    end

end