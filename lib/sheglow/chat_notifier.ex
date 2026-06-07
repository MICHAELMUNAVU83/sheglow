defmodule Sheglow.ChatNotifier do
  @moduledoc "Sends email alerts when a new chat session starts."

  alias Sheglow.Gmail

  def notify_admin_new_chat(session, message) do
    admin_email = Sheglow.AppConfig.admin_email()
    admin_url = "#{Sheglow.AppConfig.site_url()}/admin/chat/#{session.id}"

    product_row =
      if session.product_name do
        """
        <tr>
          <td style="padding:10px 0;border-bottom:1px solid #f0ede8;">
            <span style="font-size:12px;color:#999;text-transform:uppercase;letter-spacing:0.8px;">Viewing Product</span>
          </td>
          <td style="padding:10px 0;border-bottom:1px solid #f0ede8;text-align:right;">
            <span style="font-size:14px;font-weight:700;color:#111;">#{session.product_name}</span>
          </td>
        </tr>
        """
      else
        ""
      end

    body =
      Gmail.branded_email(
        """
        <tr>
          <td style="padding:32px 40px 16px;">
            <h2 style="margin:0 0 6px;font-family:'Playfair Display',Georgia,serif;font-size:22px;color:#111;">
              💬 New Customer Chat
            </h2>
            <p style="margin:0;font-size:14px;color:#555;">
              A visitor just started a conversation and is waiting for your reply.
            </p>
          </td>
        </tr>

        <tr>
          <td style="padding:0 40px 24px;">
            <table width="100%" cellpadding="0" cellspacing="0" role="presentation"
                   style="background:#faf9f7;border-radius:12px;padding:4px 20px;margin:0 0 24px;">
              #{product_row}
              <tr>
                <td style="padding:10px 0;">
                  <span style="font-size:12px;color:#999;text-transform:uppercase;letter-spacing:0.8px;">First Message</span>
                </td>
                <td style="padding:10px 0;text-align:right;">
                  <span style="font-size:14px;font-weight:700;color:#111;">#{message.content}</span>
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <tr>
          <td style="padding:0 40px 32px;text-align:center;">
            #{Gmail.cta_button("Reply in Admin →", admin_url)}
          </td>
        </tr>
        """,
        preview: "New chat from a visitor — #{message.content}",
        header_label: "Live Chat"
      )

    Gmail.send_email(admin_email, "💬 New Chat — #{session.product_name || "Store"}", body)
  end
end
