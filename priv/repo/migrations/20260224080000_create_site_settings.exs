defmodule Sheglow.Repo.Migrations.CreateSiteSettings do
  use Ecto.Migration

  def change do
    create table(:site_settings) do
      add :site_name, :string, default: "SheGlow UG"
      add :site_tagline, :string, default: "Healthy Skin. Confident You."
      add :primary_color, :string, default: "#B65C78"
      add :font_heading, :string, default: "Playfair Display"
      add :font_body, :string, default: "Poppins"
      add :font_script, :string, default: "Dancing Script"
      add :logo_url, :string
      add :instagram_url, :string
      add :whatsapp_number, :string
      add :support_email, :string

      timestamps(type: :utc_datetime)
    end
  end
end
