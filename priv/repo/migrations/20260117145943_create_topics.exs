defmodule MyApp.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :title, :string
      add :body, :text

      timestamps(type: :utc_datetime)
    end
  end
end
