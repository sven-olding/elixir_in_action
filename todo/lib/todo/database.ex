defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"
  @max_workers 3

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  @impl GenServer
  def init(_) do
    IO.puts("Starting database server")
    File.mkdir_p!(@db_folder)
    {:ok, start_workers()}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _, workers) do
    worker_key = :erlang.phash2(key, @max_workers)
    {:reply, Map.get(workers, worker_key), workers}
  end

  defp start_workers() do
    for i <- 1..@max_workers, into: %{} do
      {:ok, pid} = Todo.DatabaseWorker.start(@db_folder)
      {i - 1, pid}
    end
  end

  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end
end
