defmodule Wisps.WispTracker do
  use GenServer

  require Logger

  def start_link(initial_value) do
    GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end

  def update_wisp(id, page, position) do
    GenServer.cast(__MODULE__, {:update, id, page, position, 100})
  end

  def update_wisp(id, page, position, intensity) do
    GenServer.cast(__MODULE__, {:update, id, page, position, intensity})
  end

  @impl true
  def init(state) do
    schedule_refresh()
    {:ok, state}
  end

  @impl true
  def handle_cast({:update, id, page, position, intensity}, state) do
    # Get or create
    wisp =
      Map.get(state, id, %{
        id: id,
        page: page,
        intensity: intensity,
        position: position
      })

    wisp =
      if wisp.position != position do
        # If position changes, intensity is right back to full
        %{wisp | position: position, intensity: intensity}
      else
        # Otherwise, no change
        wisp
      end

    # Store it
    state =
      state
      |> Map.put(id, wisp)
      |> trim_dead()

    broadcast(page, state)

    {:noreply, state}
  end

  @impl true
  def handle_info(:refresh, state) do
    state = freshen(state)

    # Broadcast per page
    Enum.reduce(state, %{}, fn {_id, wisp}, pages ->
      Map.put_new(pages, wisp.page, nil)
    end)
    |> Map.keys()
    |> Enum.each(fn page ->
      broadcast(page, state)
    end)

    schedule_refresh()

    {:noreply, state}
  end

  defp freshen(state) do
    state
    |> update_intensities()
    |> trim_dead()
  end

  defp update_intensities(state) do
    Enum.map(state, fn {id, %{intensity: i} = wisp} ->
      {id, %{wisp | intensity: i - 5}}
    end)
    |> Enum.into(%{})
  end

  defp trim_dead(state) do
    Enum.filter(state, fn {_id, %{intensity: i} = _wisp} ->
      i > 0
    end)
    |> Enum.into(%{})
  end

  def broadcast(page, state) do
    total_count = Enum.count(state)

    wisps =
      state
      |> Enum.filter(fn {_id, %{page: wisp_page} = _wisp} ->
        page == wisp_page
      end)
      |> Enum.map(fn {_, wisp} ->
        wisp
      end)

    page_counts =
      state
      |> Enum.reduce(%{}, fn {_id, %{page: wisp_page}}, page_counts ->
        count = Map.get(page_counts, wisp_page, 0) + 1
        Map.put(page_counts, wisp_page, count)
      end)

    Logger.info("Current wisps: #{inspect(Enum.count(wisps))} Total: #{total_count}")

    WispsWeb.Endpoint.broadcast!("page:" <> page, "update", %{
      wisps: wisps,
      page_counts: page_counts,
      total_count: total_count
    })
  end

  defp schedule_refresh() do
    Process.send_after(self(), :refresh, 5000)
  end
end
