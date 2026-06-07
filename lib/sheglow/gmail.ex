defmodule Sheglow.Gmail do
  @moduledoc """
  Sends transactional emails via the Nexus email API.
  All outgoing emails use the shared branded HTML wrapper.
  """

  require Logger

  @api_url "https://app.nexuscale.ai/api/v1/email/send"
  @from_email "notifications@callwisely.ai"
  @brand_color "#B65C78"
  @brand_name "SheGlow UG"
  @support_whatsapp "https://wa.me/256742013968"
  @support_instagram "https://www.instagram.com/sheglowug/"

  # ── Public API ────────────────────────────────────────────────────────────

  def send_email(to_email, subject, html_body) do
    payload = %{
      from_email: @from_email,
      to: to_email,
      subject: subject,
      body: html_body,
      html_body: html_body
    }

    Logger.info("[Gmail] Sending \"#{subject}\" → #{to_email}")

    case Req.post(@api_url,
           headers: [{"Content-Type", "application/json"}],
           json: payload,
           receive_timeout: 60_000
         ) do
      {:ok, %{status: status}} when status in 200..299 ->
        Logger.info("[Gmail] Delivered \"#{subject}\" → #{to_email} (HTTP #{status})")
        {:ok, status}

      {:ok, %{status: status, body: body}} ->
        Logger.error(
          "[Gmail] API error #{status} for \"#{subject}\" → #{to_email}: #{inspect(body)}"
        )

        {:error, {status, body}}

      {:error, reason} ->
        Logger.error(
          "[Gmail] HTTP error sending \"#{subject}\" → #{to_email}: #{inspect(reason)}"
        )

        {:error, reason}
    end
  end

  # ── Branded template helpers (public so notifiers can use them) ───────────

  @doc "Wraps any inner HTML in the full branded email shell."
  def branded_email(inner_html, opts \\ []) do
    preview_text = Keyword.get(opts, :preview, "")
    header_label = Keyword.get(opts, :header_label, "")
    year = Date.utc_today().year

    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width,initial-scale=1" />
      <meta http-equiv="X-UA-Compatible" content="IE=edge" />
      <!--[if !mso]><!-->
      <style>
        @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=Inter:wght@400;500;600;700&display=swap');
      </style>
      <!--<![endif]-->
      <title>#{@brand_name}</title>
      #{if preview_text != "", do: "<div style=\"display:none;max-height:0;overflow:hidden;\">#{preview_text}</div>", else: ""}
    </head>
    <body style="margin:0;padding:0;background-color:#fff7f8;font-family:'Inter',Arial,sans-serif;-webkit-font-smoothing:antialiased;">

    <table width="100%" cellpadding="0" cellspacing="0" role="presentation" style="background:#fff7f8;padding:40px 16px;">
      <tr>
        <td align="center">
          <table width="600" cellpadding="0" cellspacing="0" role="presentation"
                 style="max-width:600px;width:100%;background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.07);">

            <!-- ── HEADER ── -->
            <tr>
              <td style="background:#{@brand_color};padding:32px 40px;text-align:center;">
                <p style="margin:0 0 6px;font-size:11px;font-weight:600;letter-spacing:3px;text-transform:uppercase;color:rgba(255,255,255,0.6);">
                  #{if header_label != "", do: header_label, else: ""}
                </p>
                <h1 style="margin:0;font-family:'Playfair Display',Georgia,serif;font-size:26px;font-weight:700;color:#ffffff;letter-spacing:1px;">
                  #{@brand_name}
                </h1>
              </td>
            </tr>

            <!-- ── BODY ── -->
            #{inner_html}

            <!-- ── FOOTER ── -->
            <tr>
              <td style="background:#1a1a1a;padding:32px 40px;">
                <table width="100%" cellpadding="0" cellspacing="0" role="presentation">
                  <tr>
                    <td align="center" style="padding-bottom:20px;">
                      <p style="margin:0;font-family:'Playfair Display',Georgia,serif;font-size:18px;color:#ffffff;">
                        #{@brand_name}
                      </p>
                      <p style="margin:4px 0 0;font-size:11px;letter-spacing:2px;text-transform:uppercase;color:rgba(255,255,255,0.4);">
                        Healthy Skin. Confident You.
                      </p>
                    </td>
                  </tr>
                  <tr>
                    <td align="center" style="padding-bottom:20px;">
                      <a href="#{@support_whatsapp}" style="display:inline-block;margin:0 8px;color:rgba(255,255,255,0.5);font-size:12px;text-decoration:none;">WhatsApp</a>
                      <span style="color:rgba(255,255,255,0.2);">·</span>
                      <a href="#{@support_instagram}" style="display:inline-block;margin:0 8px;color:rgba(255,255,255,0.5);font-size:12px;text-decoration:none;">Instagram</a>
                      <span style="color:rgba(255,255,255,0.2);">·</span>
                      <a href="#{Sheglow.AppConfig.site_url()}" style="display:inline-block;margin:0 8px;color:rgba(255,255,255,0.5);font-size:12px;text-decoration:none;">Shop Online</a>
                    </td>
                  </tr>
                  <tr>
                    <td align="center">
                      <p style="margin:0;font-size:11px;color:rgba(255,255,255,0.25);">
                        © #{year} #{@brand_name}. All rights reserved.
                      </p>
                      <p style="margin:6px 0 0;font-size:11px;color:rgba(255,255,255,0.2);">
                        Kampala, Uganda
                      </p>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

          </table>
        </td>
      </tr>
    </table>

    </body>
    </html>
    """
  end

  @doc "Renders a prominent red CTA button."
  def cta_button(label, url) do
    """
    <table cellpadding="0" cellspacing="0" role="presentation" style="margin:0 auto;">
      <tr>
        <td style="border-radius:50px;background:#{@brand_color};">
          <a href="#{url}"
             style="display:inline-block;padding:14px 36px;font-size:14px;font-weight:700;color:#ffffff;text-decoration:none;letter-spacing:0.5px;border-radius:50px;">
            #{label}
          </a>
        </td>
      </tr>
    </table>
    """
  end

  @doc "Renders a ghost (outlined) CTA button."
  def ghost_button(label, url) do
    """
    <table cellpadding="0" cellspacing="0" role="presentation" style="margin:0 auto;">
      <tr>
        <td style="border-radius:50px;border:2px solid #{@brand_color};">
          <a href="#{url}"
             style="display:inline-block;padding:12px 34px;font-size:14px;font-weight:600;color:#{@brand_color};text-decoration:none;letter-spacing:0.5px;border-radius:50px;">
            #{label}
          </a>
        </td>
      </tr>
    </table>
    """
  end

  @doc "Renders a key-value info box (e.g. order reference, credentials)."
  def info_box(rows) do
    rows_html =
      rows
      |> Enum.map(fn {label, value} ->
        """
        <tr>
          <td style="padding:10px 0;border-bottom:1px solid #f0ede8;">
            <span style="font-size:12px;color:#999;text-transform:uppercase;letter-spacing:0.8px;">#{label}</span>
          </td>
          <td style="padding:10px 0;border-bottom:1px solid #f0ede8;text-align:right;">
            <span style="font-size:14px;font-weight:700;color:#111;">#{value}</span>
          </td>
        </tr>
        """
      end)
      |> Enum.join("")

    """
    <table width="100%" cellpadding="0" cellspacing="0" role="presentation"
           style="background:#faf9f7;border-radius:12px;padding:4px 20px;margin:0 0 24px;">
      #{rows_html}
    </table>
    """
  end

  @doc "Renders a divider rule."
  def divider do
    """
    <tr>
      <td style="padding:0 40px;">
        <div style="height:1px;background:#f0ede8;"></div>
      </td>
    </tr>
    """
  end
end
