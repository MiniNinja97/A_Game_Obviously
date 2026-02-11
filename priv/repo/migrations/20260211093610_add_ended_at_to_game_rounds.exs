defmodule MyApp.Repo.Migrations.AddEndedAtToGameRounds do
  use Ecto.Migration

  def change do
    alter table(:game_rounds) do
      add :ended_at, :utc_datetime

    end

  end
end
