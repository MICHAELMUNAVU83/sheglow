defmodule Sheglow.Accounts.UserNotifier do
  alias Sheglow.Gmail

  @brand_color "#C8001F"

  # ── Password Reset ────────────────────────────────────────────────────────

  @spec deliver_reset_password_instructions(
          atom() | %{:email => any(), :name => any(), optional(any()) => any()},
          any()
        ) :: {:ok, :sent}
  def deliver_reset_password_instructions(user, url) do
    name = user.name || user.email

    body =
      Gmail.branded_email(
        """
        <tr>
          <td style="padding:36px 40px 8px;">
            <h2 style="margin:0 0 10px;font-family:'Playfair Display',Georgia,serif;font-size:22px;color:#111;">
              Reset Your Password
            </h2>
            <p style="margin:0;font-size:15px;color:#555;line-height:1.7;">
              Hi <strong style="color:#111;">#{name}</strong>,
              we received a request to reset your password for your SheGlow UG admin account.
            </p>
          </td>
        </tr>

        <tr>
          <td style="padding:20px 40px 0;">
            <table width="100%" cellpadding="0" cellspacing="0" role="presentation"
                   style="background:#faf9f7;border-radius:12px;padding:20px 24px;">
              <tr>
                <td style="font-size:13px;color:#555;line-height:1.6;">
                  Click the button below to set a new password. This link expires in
                  <strong style="color:#111;">24 hours</strong>.
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <tr>
          <td style="padding:28px 40px;text-align:center;">
            #{Gmail.cta_button("Reset My Password", url)}
          </td>
        </tr>

        <tr>
          <td style="padding:0 40px 32px;text-align:center;">
            <p style="margin:0;font-size:12px;color:#bbb;line-height:1.6;">
              If you didn't request a password reset, you can safely ignore this email.
              Your account remains secure.
            </p>
            <p style="margin:12px 0 0;font-size:12px;color:#ccc;">
              Or copy this link: <br />
              <span style="color:#aaa;word-break:break-all;">#{url}</span>
            </p>
          </td>
        </tr>
        """,
        preview: "Reset your SheGlow UG password — link valid for 24 hours.",
        header_label: "Account Security"
      )

    Gmail.send_email(user.email, "Reset your password — SheGlow UG", body)
    {:ok, :sent}
  end

  # ── Team Member Welcome ───────────────────────────────────────────────────

  def deliver_welcome_with_credentials(user, temp_password) do
    name = user.name || user.email
    base = Sheglow.AppConfig.site_url()
    login_url = "#{base}/users/log_in"
    reset_url = "#{base}/users/reset_password"

    role_label =
      case user.role do
        "super_admin" -> "Super Admin"
        "admin" -> "Admin"
        _ -> "Team Member"
      end

    body =
      Gmail.branded_email(
        """
        <tr>
          <td style="padding:36px 40px 8px;">
            <h2 style="margin:0 0 10px;font-family:'Playfair Display',Georgia,serif;font-size:24px;color:#111;">
              Welcome to the Team! 👋
            </h2>
            <p style="margin:0;font-size:15px;color:#555;line-height:1.7;">
              Hi <strong style="color:#111;">#{name}</strong>, you've been added as
              <strong style="color:#{@brand_color};">#{role_label}</strong> at SheGlow UG.
              Here are your login credentials:
            </p>
          </td>
        </tr>

        <tr>
          <td style="padding:20px 40px 0;">
            #{Gmail.info_box([{"Email", user.email}, {"Temporary Password", temp_password}, {"Your Role", role_label}])}
          </td>
        </tr>

        <tr>
          <td style="padding:8px 40px 0;">
            <table width="100%" cellpadding="0" cellspacing="0" role="presentation"
                   style="background:#fff8f8;border-left:3px solid #{@brand_color};border-radius:0 8px 8px 0;padding:14px 18px;">
              <tr>
                <td style="font-size:13px;color:#555;line-height:1.6;">
                  ⚠️ <strong style="color:#111;">Important:</strong> Please change your password immediately after your first login.
                  Never share your credentials with anyone.
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <tr>
          <td style="padding:28px 40px;text-align:center;">
            #{Gmail.cta_button("Log In to Admin Panel", login_url)}
          </td>
        </tr>

        <tr>
          <td style="padding:0 40px 32px;text-align:center;">
            <p style="margin:0;font-size:13px;color:#999;">
              Want to set your own password right away?
            </p>
            <p style="margin:8px 0 0;">
              <a href="#{reset_url}"
                 style="font-size:13px;font-weight:600;color:#{@brand_color};text-decoration:none;">
                Reset password →
              </a>
            </p>
          </td>
        </tr>
        """,
        preview: "You've been added to SheGlow UG admin — here are your login details.",
        header_label: "Team Invitation"
      )

    Gmail.send_email(user.email, "You've been added to SheGlow UG admin team", body)
    {:ok, :sent}
  end

  # ── Email Change (kept for Phoenix auth compatibility) ────────────────────

  def deliver_update_email_instructions(user, url) do
    name = user.name || user.email

    body =
      Gmail.branded_email(
        """
        <tr>
          <td style="padding:36px 40px 8px;">
            <h2 style="margin:0 0 10px;font-family:'Playfair Display',Georgia,serif;font-size:22px;color:#111;">
              Confirm Email Change
            </h2>
            <p style="margin:0;font-size:15px;color:#555;line-height:1.7;">
              Hi <strong style="color:#111;">#{name}</strong>,
              click below to confirm your new email address.
            </p>
          </td>
        </tr>
        <tr>
          <td style="padding:24px 40px 32px;text-align:center;">
            #{Gmail.cta_button("Confirm New Email", url)}
            <p style="margin:16px 0 0;font-size:12px;color:#bbb;">
              If you didn't request this, you can safely ignore this email.
            </p>
          </td>
        </tr>
        """,
        preview: "Confirm your new email address for SheGlow UG.",
        header_label: "Account Settings"
      )

    Gmail.send_email(user.email, "Confirm your new email — SheGlow UG", body)
    {:ok, :sent}
  end

  # ── Account Confirmation (kept for compatibility) ─────────────────────────

  def deliver_confirmation_instructions(user, url) do
    deliver_reset_password_instructions(user, url)
  end
end
