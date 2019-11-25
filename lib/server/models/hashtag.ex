defmodule TwitterEngine.Server.Models.Hashtags do
  def get_all() do
  end

  # this will return the user list of a given hashtag
  def get(hashtag) do
    state = TwitterEngine.Server.DB.get()

    hashtags_list =
      Map.get(state, :hashtags)
      |> Map.get(hashtag)

    hashtags_list
  end

  # this will create a new hasthtag with empty list
  def create(hashtag) do
    new_hashtag = []
    state = TwitterEngine.Server.DB.get()
    all_hashtags = Map.get(state, :hashtags)
    all_hashtags = Map.put(all_hashtags, hashtag, new_hashtag)
    state = Map.put(state, :hashtags, all_hashtags)
    TwitterEngine.Server.DB.put(state)
  end

  # this will update hashtag with the hashtag_list
  def update(hashtag, hashtag_list) do
    state = TwitterEngine.Server.Models.DB.get()
    all_hashtags = Map.get(state, :hashtags)
    all_hashtags = Map.put(all_hashtags, hashtag, hashtag_list)
    state = Map.put(state, :hashtags, all_hashtags)
    TwitterEngine.Server.DB.put(state)
  end

  # this will add element to hashtag's list
  def add_toList(hashtag, user_id) do
    hashtag_list = TwitterEngine.Server.Models.Hashtags.get(hashtag)
    hashtag_list = [user_id] ++ hashtag_list
    TwitterEngine.Server.Models.Hashtags.update(hashtag, hashtag_list)
  end

  # this will delete element from hashtag's list
  def delete_fromList(hashtag, user_id) do
    hashtag_list = TwitterEngine.Server.Models.Hashtags.get(hashtag) |> List.delete(user_id)
    TwitterEngine.Server.Models.Hashtags.update(hashtag, hashtag_list)
  end
end
