defmodule MyApp.ForumTest do
  use MyApp.DataCase

  alias MyApp.Forum

  describe "topics" do
    alias MyApp.Forum.Topic

    import MyApp.ForumFixtures

    @invalid_attrs %{title: nil, body: nil}

    test "list_topics/0 returns all topics" do
      topic = topic_fixture()
      assert Forum.list_topics() == [topic]
    end

    test "get_topic!/1 returns the topic with given id" do
      topic = topic_fixture()
      assert Forum.get_topic!(topic.id) == topic
    end

    test "create_topic/1 with valid data creates a topic" do
      valid_attrs = %{title: "some title", body: "some body"}

      assert {:ok, %Topic{} = topic} = Forum.create_topic(valid_attrs)
      assert topic.title == "some title"
      assert topic.body == "some body"
    end

    test "create_topic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Forum.create_topic(@invalid_attrs)
    end

    test "update_topic/2 with valid data updates the topic" do
      topic = topic_fixture()
      update_attrs = %{title: "some updated title", body: "some updated body"}

      assert {:ok, %Topic{} = topic} = Forum.update_topic(topic, update_attrs)
      assert topic.title == "some updated title"
      assert topic.body == "some updated body"
    end

    test "update_topic/2 with invalid data returns error changeset" do
      topic = topic_fixture()
      assert {:error, %Ecto.Changeset{}} = Forum.update_topic(topic, @invalid_attrs)
      assert topic == Forum.get_topic!(topic.id)
    end

    test "delete_topic/1 deletes the topic" do
      topic = topic_fixture()
      assert {:ok, %Topic{}} = Forum.delete_topic(topic)
      assert_raise Ecto.NoResultsError, fn -> Forum.get_topic!(topic.id) end
    end

    test "change_topic/1 returns a topic changeset" do
      topic = topic_fixture()
      assert %Ecto.Changeset{} = Forum.change_topic(topic)
    end
  end
end
