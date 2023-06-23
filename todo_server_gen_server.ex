defmodule TodoServer do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    {:ok, TodoList.new()}
  end

  def entries(date) do
    GenServer.call(__MODULE__, {:entries, date})
  end

  def add_entry(new_entry) do
    GenServer.cast(__MODULE__, {:add_entry, new_entry})
  end

  def remove_entry(entry_to_remove) do
    GenServer.cast(__MODULE__, {:remove_entry, entry_to_remove})
  end

  def update_entry(entry, updater_func) do
    GenServer.call(__MODULE__, {:update_entry, entry, updater_func})
  end

  @impl GenServer
  def handle_call({:entries, date}, _, state) do
    {:reply, TodoList.entries(state, date), state}
  end

  @impl GenServer
  def handle_call({:update_entry, entry, updater_func}, _, state) do
    {:reply, TodoList.update_entry(state, entry.id, updater_func)}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, state) do
    {:noreply, TodoList.add_entry(state, new_entry)}
  end

  @impl GenServer
  def handle_cast({:remove_entry, entry_to_remove}, state) do
    {:noreply, TodoList.delete_entry(state, entry_to_remove.id)}
  end
end

defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %TodoList{}, fn entry, todo_list_acc ->
      add_entry(todo_list_acc, entry)
    end)
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)

    new_entries = Map.put(todo_list.entries, todo_list.next_id, entry)

    %TodoList{
      todo_list
      | entries: new_entries,
        next_id: todo_list.next_id + 1
    }
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(&(&1.date == date))
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)

    %TodoList{
      todo_list
      | entries: new_entries
    }
  end
end
