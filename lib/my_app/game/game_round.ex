defmodule MyApp.Game.GameRound do
  use Ecto.Schema
  import Ecto.Changeset

  @doc """
  Represents a single playthrough of the game, tracking the player's progress, score, and state.
  """

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


  @doc """
  Changeset for creating/updating game rounds.
   Validates presence of character_name, status, and user_id.
  """
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
