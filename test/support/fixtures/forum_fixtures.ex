defmodule MyApp.ForumFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MyApp.Forum` context.
  """

  @doc """
  Generate a topic.
  """
  def topic_fixture(attrs \\ %{}) do
    {:ok, topic} =
      attrs
      |> Enum.into(%{
        body: "some body",
        title: "some title"
      })
      |> MyApp.Forum.create_topic()

    topic
  end
end
