defmodule MyApp.Repo.Migrations.CreateGameRounds do
  use Ecto.Migration

  def change do

    create table(:game_rounds) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :character_name, :string, null: false

      add :score, :integer, default: 0
      add :time_seconds, :integer, default: 0
      add :moves, :integer, default: 0

      add :status, :string, default: "ongoing", null: false

      add :started_at, :utc_datetime
      add :finished_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
