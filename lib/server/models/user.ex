defmodule TwitterEngine.Server.Models.User do
  def get_all() do
  end

  # this will fetch a user_id's map
  def get(user_id) do
    state = TwitterEngine.Server.DB.get()

    user =
      Map.get(state, :users)
      |> Map.get(user_id)
  end

  # this will create a new user with user_id
  def create(user_id) do
    new_user = %{
      subscribers: [],
      subscriptions: [],
      notifications: [],
      tweets: [],
      active: true
    }

    state = TwitterEngine.Server.DB.get()
    user_map = Map.get(state, :users)
    user_map = Map.put(user_map, user_id, new_user)
    state = Map.put(state, :users, user_map)
    TwitterEngine.Server.DB.put(state)
  end

  # this will replace user_id's map with an updated_user map
  def update(user_id, updated_user) do
    state = TwitterEngine.Server.DB.get()
    user_map = Map.get(state, :users)
    user_map = Map.put(user_map, user_id, updated_user)
    state = Map.put(state, :users, user_map)
    TwitterEngine.Server.DB.put(state)
  end

  # make account as inactive
  def delete(user_id) do
    state = TwitterEngine.Server.DB.get()
    users_map = Map.get(state, :users)
    user = Map.get(users_map, user_id)
    user = Map.put(user, :active, false)
    users_map = Map.put(users_map, user_id, user)
    state = Map.put(state, :users, users_map)
    TwitterEngine.Server.DB.put(state)
  end

  # can fetch lists - notifications, tweets, subscribers, subscriptions
  def query(user_id, list_name) do
    user_map = TwitterEngine.Server.Models.User.get(user_id)
    list_struct = Map.get(user_map, String.to_atom(list_name))
    list_struct
  end

  # this will add element to user's list - notifications, tweets, subscribers, subscriptions
  def add_toList(user_id, list_name, element) do
    user_map = TwitterEngine.Server.Models.User.get(user_id)
    list_struct = Map.get(user_map, String.to_atom(list_name))
    list_struct = [element] ++ list_struct
    user_map = Map.put(user_map, String.to_atom(list_name), list_struct)
    TwitterEngine.Server.Models.User.update(user_id, user_map)
  end

  # this will delete element from user's list - notifications, tweets, subscribers, subscriptions
  def delete_fromList(user_id, list_name, element) do
    user_map = TwitterEngine.Server.Models.User.get(user_id)
    list_struct = Map.get(user_map, String.to_atom(list_name)) |> List.delete(element)
    user_map = Map.put(user_map, String.to_atom(list_name), list_struct)
    TwitterEngine.Server.Models.User.update(user_id, user_map)
  end
end
