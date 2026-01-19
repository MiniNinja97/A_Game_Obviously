defmodule MyApp.Forum.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field :title, :string
    field :body, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
  end
end
