defmodule MyApp.Game.GameRound do
  use Ecto.Schema
  import Ecto.Changeset

  schema "game_rounds" do
    field :character_name, :string
    field :status, :string, default: "ongoing"
    field :score, :integer, default: 0
    field :started_at, :utc_datetime
    field :ended_at, :utc_datetime
    field :state, :map, default: %{}
    belongs_to :user, MyApp.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(game_round, attrs) do

    game_round
    |> cast(attrs, [
      :character_name,
      :status,
      :score,
      :started_at,
      :ended_at,
      :user_id,
      :state
    ])

    |> validate_required([:character_name, :status, :user_id])
  end
end
