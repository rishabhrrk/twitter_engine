defmodule TwitterEngine.Server.Models.Notification do
  def get_all() do
  end

  return notification map by notification id
  def get(notification_id) do
    state = TwitterEngine.Server.DB.get()
    notification = Map.get(state, :notifications) |> Map.get(notification_id)
    notification
  end

  def create(type, tweet_id, user_id) do
    # add new notification
    new_notification = %{
      type: type
      tweet: tweet_id
      owner: user_id
    }
    state = TwitterEngine.Server.DB.get()
    all_notifications = Map.get(state, :notifications)
    notification_id = :crypto.hash(:md5, type<>tweet_id) |> Base.encode16()
    all_notifications = Map.put(all_notifications, notification_id, new_notification)
    state = Map.put(state, :tweets, all_notifications)
    TwitterEngine.Server.DB.put(state)
    notification_id
  end

  def delete(id) do
  end
end
