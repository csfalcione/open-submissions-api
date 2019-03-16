defmodule OpenSubmissions.Events.Handlers.Handler do
    
    @callback handle_event(event:: term) :: {:ok, term} | {:error, term}

end