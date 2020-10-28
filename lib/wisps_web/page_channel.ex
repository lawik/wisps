defmodule WispsWeb.PageChannel do
  use Phoenix.Channel
  alias Wisps.WispTracker

  def join("page:" <> path, _message, socket) do
    socket =
      socket
      |> assign(:id, :erlang.unique_integer())
      |> assign(:path, path)

    WispTracker.update_wisp(socket.assigns[:id], path, 1)
    {:ok, socket}
  end

  def terminate(_reason, %{assigns: %{id: id, path: path}} = _socket) do
    # End the wisp
    WispTracker.update_wisp(id, path, 0, 0)
  end

  def handle_in("update", %{"position" => position}, %{assigns: %{id: id, path: path}} = socket) do
    WispTracker.update_wisp(id, path, position)
    {:noreply, socket}
  end
end
