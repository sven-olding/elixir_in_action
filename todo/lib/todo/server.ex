defmodule Todo.Server do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  @impl GenServer
  def init(_) do
    {:ok, Todo.List.new()}
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def remove_entry(pid, entry_to_remove) do
    GenServer.cast(pid, {:remove_entry, entry_to_remove})
  end

  def update_entry(pid, entry, updater_func) do
    GenServer.call(pid, {:update_entry, entry, updater_func})
  end

  @impl GenServer
  def handle_call({:entries, date}, _, state) do
    {:reply, Todo.List.entries(state, date), state}
  end

  @impl GenServer
  def handle_call({:update_entry, entry, updater_func}, _, state) do
    {:reply, Todo.List.update_entry(state, entry.id, updater_func)}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, state) do
    {:noreply, Todo.List.add_entry(state, new_entry)}
  end

  @impl GenServer
  def handle_cast({:remove_entry, entry_to_remove}, state) do
    {:noreply, Todo.List.delete_entry(state, entry_to_remove.id)}
  end
end
