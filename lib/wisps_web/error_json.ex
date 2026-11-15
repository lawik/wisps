defmodule WispsWeb.ErrorJSON do
  @moduledoc """
  Renders errors as JSON, using the status message for the template name.
  """

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
