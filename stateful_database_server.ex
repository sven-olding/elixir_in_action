defmodule DatabaseServer do
  # server_pid = DatabaseServer.start()
  # DatabaseServer.run_async(server_pid, "query 1")
  # DatabaseServer.get_result()
  # DatabaseServer.run_async(server_pid, "query 2")
  # DatabaseServer.get_result()

  # run concurrently:
  # pool = Enum.map(1..100, fn _ -> DatabaseServer.start() end)
  # Enum.each(
  #   1..5,
  #   fn query_def ->
  #     server_pid = Enum.at(pool, :rand.uniform(100) - 1)
  #     DatabaseServer.run_async(server_pid, query_def)
  #    end)

  # -> collect results:
  # Enum.map(1..5, fn _ -> DatabaseServer.get_result() end)
  def start do
    spawn(fn ->
      connection = :rand.uniform(1000)
      loop(connection)
    end)
  end

  def run_async(server_pid, query_def) do
    send(server_pid, {:run_query, self(), query_def})
  end

  def get_result do
    receive do
      {:query_result, result} -> result
    after
      5000 -> {:error, :timeout}
    end
  end

  defp loop(connection) do
    receive do
      {:run_query, caller, query_def} ->
        query_result = run_query(connection, query_def)
        send(caller, {:query_result, query_result})
    end

    loop(connection)
  end

  defp run_query(connection, query_def) do
    Process.sleep(2000)
    "Connection #{connection}: #{query_def} result"
  end
end
