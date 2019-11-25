defmodule TwitterEngine.Server.Models.UserTest do
  alias TwitterEngine.Server.Models.User

  test "get_all returns all users" do
    assert User.get_all() == []
    pid = User.create({name: "my-username"})
    assert User.get_all() == [pid]
  end

  test "create_user creates a user" do

  end

  test "get notifications for a user" do
    Notification.query({user: username})
  end
end
