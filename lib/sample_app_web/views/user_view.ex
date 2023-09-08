defmodule SampleAppWeb.UserView do
  use SampleAppWeb, :view
  use Scrivener.HTML

  defp md5_hexdigest(str) do
    :crypto.hash(:md5, str)
    |> Base.encode16(case: :lower)
  end

  # Returns the Gravatar for the given user.
  def gravatar_for(user, options \\ []) do
    gravatar_id = String.downcase(user.email) |> md5_hexdigest()
    size = Keyword.get(options, :size, 80) |> to_string()
    gravatar_url = ["https://secure.gravatar.com/avatar/", gravatar_id, "?s=", size]
    img_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
