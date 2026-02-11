defmodule MyApp.Repo.Migrations.AddStateToGameRounds do
  use Ecto.Migration

  def change do
    alter table(:game_rounds) do
      add :state, :map, default: %{}
    end
  end
end
