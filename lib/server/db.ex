defmodule TwitterEngine.Server.DB do
  def setup do
  end

  def get do
    GenServer.call(TwitterEngine.Server, :get_state)
  end

  def put(state) do
    GenServer.call(TwitterEngine.Server, :set_state, state)
  end
end
