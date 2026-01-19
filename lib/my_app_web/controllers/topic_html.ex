defmodule MyAppWeb.TopicHTML do
  use MyAppWeb, :html

  embed_templates "topic_html/*"

  @doc """
  Renders a topic form.

  The form is defined in the template at
  topic_html/topic_form.html.heex
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil

  def topic_form(assigns)
end
