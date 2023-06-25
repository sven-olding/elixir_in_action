defmodule Todo.Server do
  use GenServer

  def start(name) do
    GenServer.start(__MODULE__, name)
  end

  @impl GenServer
  def init(name) do
    {:ok, {name, nil}, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, {name, nil}) do
    todo_list = Todo.Database.get(name) || Todo.List.new()
    {:noreply, {name, todo_list}}
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
  def handle_call({:entries, date}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
  end

  @impl GenServer
  def handle_call({:update_entry, entry, updater_func}, _, {name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, entry.id, updater_func)
    Todo.Database.store(name, new_list)
    {:reply, {name, new_list}}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_cast({:remove_entry, entry_to_remove}, {name, todo_list}) do
    new_list = Todo.List.delete_entry(todo_list, entry_to_remove.id)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end
end
