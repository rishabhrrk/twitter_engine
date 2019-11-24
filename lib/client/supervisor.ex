defmodule TwitterEngine.Client.Supervisor do
  def create_nodes(num_nodes) do
    nodes =
      Enum.map(1..num_nodes, fn i ->
        Supervisor.child_spec(TwitterEngine.Client.User, id: i)
      end)

    opts = [strategy: :one_for_one, name: TwitterEngine.Client.Supervisor]
    Supervisor.start_link(nodes, opts)

    :ok
  end
end
