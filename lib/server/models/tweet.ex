defmodule TwitterEngine.Server.Models.Tweet do
  def get_all() do
  end

  # fetch tweet map by tweet_id
  def get(id) do
    state = TwitterEngine.Server.DB.get()

    tweet_map =
      Map.get(state, :tweets)
      |> Map.get(tweet_map, id)

    tweet_map
  end

  # create a new tweet
  def create(user_id, tweet) do
    hashtags = String.split(tweet, " ")
    |> Enum.filter(fn n -> String.at(n,0)=="#" end)
    tagged_users = String.split(tweet, " ")
    |> Enum.filter(fn n -> String.at(n,0)=="@" end)
    |> Enum.map(fn g -> String.trim(g,"@") end)

    # add hashtags to the hashtag map unless it is already present
    Enum.each(hashtags, fn hashtag ->
      if(length(TwitterEngine.Server.Models.Hashtags.get(hashtag))==0) do
        TwitterEngine.Server.Models.Hashtags.create(hashtag)
      end
    end)

    # add new tweet
    new_tweet = %{
      user_id: user_id
      content: tweet,
      is_archived: false,
      hashtags: hashtags,
      tagged_users: tagged_users
    }
    state = TwitterEngine.Server.DB.get()
    all_tweets = Map.get(state, :tweets)
    tweet_id = :crypto.hash(:md5, tweet) |> Base.encode16()
    all_tweets = Map.put(all_tweets, tweet_id, new_tweet)
    state = Map.put(state, :tweets, all_tweets)
    TwitterEngine.Server.DB.put(state)
    tweet_id
  end

  # delete a tweet by tweet id
  def delete(id) do
    state = TwitterEngine.Server.DB.get()
    all_tweets = Map.get(state, :tweets)
    tweet = Map.get(all_tweets, id)
    tweet = Map.put(tweet, :is_archived, false)
    all_tweets = Map.put(all_tweets, id, tweet)
    state = Map.put(state, :tweets, all_tweets)
    TwitterEngine.Server.DB.put(state)
  end

  # can fetch lists - hashtags, tagged_users
  def query(tweet_id, list_name) do
    tweet_map = TwitterEngine.Server.Models.Tweet.get(tweet_id)
    list_struct = Map.get(tweet_map, String.to_atom(list_name))
    list_struct
  end

  # this will add element to tweet's list - hashtags, tagged_users
  def add_toList(tweet_id, list_name, element) do
    tweet_map = TwitterEngine.Server.Models.Tweet.get(tweet_id)
    list_struct = Map.get(user_map, String.to_atom(list_name))
    list_struct = [element] ++ list_struct
    tweet_map = Map.put(tweet_map, String.to_atom(list_name), list_struct)
    TwitterEngine.Server.Models.Tweet.update(tweet_id, tweet_map)
  end

  # this will delete element from tweet's list - hashtags, tagged_users
  def delete_fromList(tweet_id, list_name, element) do
    tweet_map = TwitterEngine.Server.Models.Tweet.get(tweet_id)
    list_struct = Map.get(tweet_map, String.to_atom(list_name)) |> List.delete(element)
    tweet_map = Map.put(tweet_map, String.to_atom(list_name), list_struct)
    TwitterEngine.Server.Models.Tweet.update(tweet_id, tweet_map)
  end
end
