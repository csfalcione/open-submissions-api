defmodule OpenSubmissionsWeb.SubmissionChannel do
    use Phoenix.Channel

    def join("submission:" <> _submission_id, _params, socket) do
        {:ok, socket}
    end
end