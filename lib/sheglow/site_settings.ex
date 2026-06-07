defmodule Sheglow.SiteSettings do
  @moduledoc """
  Agent-backed cache for the singleton site_settings row.
  Reads from DB once on startup; call `reload/0` after any update.
  """
  use Agent

  alias Sheglow.Repo
  alias Sheglow.SiteSettings.Setting

  @defaults %Setting{
    site_name: "SheGlow UG",
    site_tagline: "Healthy Skin. Confident You.",
    primary_color: "#B65C78",
    font_heading: "Playfair Display",
    font_body: "Poppins",
    font_script: "Dancing Script",
    logo_url: nil,
    instagram_url: nil,
    whatsapp_number: "256742013968",
    support_email: "sheglowug@gmail.com"
  }

  def start_link(_opts) do
    Agent.start_link(fn -> load() end, name: __MODULE__)
  end

  @doc "Returns the current settings struct (from in-memory cache)."
  def get do
    Agent.get(__MODULE__, & &1)
  end

  @doc "Updates settings in the DB, refreshes the cache, returns {:ok, setting} or {:error, changeset}."
  def update(attrs) do
    setting = Repo.one(Setting) || %Setting{}

    case Repo.insert_or_update(Setting.changeset(setting, attrs)) do
      {:ok, updated} ->
        Agent.update(__MODULE__, fn _ -> updated end)
        {:ok, updated}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc "Reloads the cache from DB (e.g. after a manual DB change)."
  def reload do
    Agent.update(__MODULE__, fn _ -> load() end)
  end

  # ── Font helpers ────────────────────────────────────────────────────────────

  @font_map %{
    "Dancing Script" => "Dancing+Script:wght@600;700",
    "Playfair Display" => "Playfair+Display:ital,wght@0,400;0,500;0,700;1,400",
    "Instrument Sans" => "Instrument+Sans:ital,wght@0,300;0,400..700;1,400..700",
    "Inter" => "Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900",
    "Poppins" => "Poppins:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400",
    "Nunito" => "Nunito:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400",
    "Lato" => "Lato:ital,wght@0,300;0,400;0,700;1,400",
    "Cormorant Garamond" => "Cormorant+Garamond:ital,wght@0,400;0,500;0,600;1,400",
    "Josefin Sans" => "Josefin+Sans:ital,wght@0,300;0,400;0,600;1,400",
    "Montserrat" => "Montserrat:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400",
    "DM Serif Display" => "DM+Serif+Display:ital@0;1",
    "Great Vibes" => "Great+Vibes",
    "Pacifico" => "Pacifico",
    "Sacramento" => "Sacramento"
  }

  @doc "Builds a Google Fonts URL for the given list of font names."
  def google_fonts_url(font_names) do
    query =
      font_names
      |> Enum.uniq()
      |> Enum.map(&Map.get(@font_map, &1))
      |> Enum.reject(&is_nil/1)
      |> Enum.map(&"family=#{&1}")
      |> Enum.join("&")

    "https://fonts.googleapis.com/css2?#{query}&display=swap"
  end

  @doc "All available font options grouped by category."
  def font_options do
    %{
      body: [
        "Instrument Sans",
        "Inter",
        "Poppins",
        "Nunito",
        "Lato"
      ],
      heading: [
        "Playfair Display",
        "Cormorant Garamond",
        "DM Serif Display",
        "Josefin Sans",
        "Montserrat"
      ],
      script: [
        "Dancing Script",
        "Great Vibes",
        "Pacifico",
        "Sacramento"
      ]
    }
  end

  # ── Private ─────────────────────────────────────────────────────────────────

  defp load do
    try do
      Repo.one(Setting) || @defaults
    rescue
      _ -> @defaults
    end
  end
end
