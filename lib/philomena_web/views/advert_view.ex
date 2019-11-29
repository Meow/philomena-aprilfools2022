defmodule PhilomenaWeb.AdvertView do
  use PhilomenaWeb, :view

  def advert_image_url(%{image: image}) do
    advert_url_root() <> image
  end

  defp advert_url_root do
    Application.get_env(:philomena, :advert_url_root)
  end
end
