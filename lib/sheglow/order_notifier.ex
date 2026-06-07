defmodule Sheglow.OrderNotifier do
  alias Sheglow.Gmail
  import SheglowWeb.Format, only: [price: 1]

  @brand_color "#C8001F"

  # ── Customer confirmation ─────────────────────────────────────────────────

  def send_confirmation(
        %{email: email, name: name, reference: reference, items: items, total_amount: total} =
          order
      ) do
    base = Sheglow.AppConfig.site_url()
    track_url = "#{base}/success?reference=#{reference}"

    whatsapp_url =
      "https://wa.me/256742013968?text=Hi%20SheGlow%20UG%2C%20my%20order%20ref%20is%20#{reference}"

    items_html = build_items_html(items)

    delivery_info =
      if order.phone || order.address do
        """
        <tr>
          <td style="padding:24px 40px 0;">
            <p style="margin:0 0 12px;font-size:11px;font-weight:600;letter-spacing:1.5px;text-transform:uppercase;color:#999;">
              Delivery Details
            </p>
            #{Gmail.info_box(delivery_rows(order))}
          </td>
        </tr>
        """
      else
        ""
      end

    body =
      Gmail.branded_email(
        """
        <!-- Greeting -->
        <tr>
          <td style="padding:36px 40px 8px;">
            <h2 style="margin:0 0 10px;font-family:'Playfair Display',Georgia,serif;font-size:24px;color:#111;">
              Order Confirmed! 🎉
            </h2>
            <p style="margin:0;font-size:15px;color:#555;line-height:1.7;">
              Thank you, <strong style="color:#111;">#{name}</strong>! Your payment has been received and your order is being
              packed with love. We'll send you an update once it's on the way.
            </p>
          </td>
        </tr>

        <!-- Reference box -->
        <tr>
          <td style="padding:20px 40px 0;">
            <table width="100%" cellpadding="0" cellspacing="0" role="presentation"
                   style="background:#fff0f0;border:1.5px solid #{@brand_color};border-radius:12px;padding:0;">
              <tr>
                <td style="padding:16px 20px;">
                  <p style="margin:0;font-size:11px;font-weight:600;letter-spacing:1.5px;text-transform:uppercase;color:#{@brand_color};">
                    Your Order Reference
                  </p>
                  <p style="margin:6px 0 0;font-size:22px;font-weight:700;color:#111;letter-spacing:1px;">
                    #{reference}
                  </p>
                </td>
                <td style="padding:16px 20px;text-align:right;vertical-align:middle;">
                  <a href="#{track_url}"
                     style="font-size:12px;font-weight:600;color:#{@brand_color};text-decoration:none;">
                    Track order →
                  </a>
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <!-- Items -->
        <tr>
          <td style="padding:28px 40px 0;">
            <p style="margin:0 0 12px;font-size:11px;font-weight:600;letter-spacing:1.5px;text-transform:uppercase;color:#999;">
              What You Ordered
            </p>
            <table width="100%" cellpadding="0" cellspacing="0" role="presentation"
                   style="border:1px solid #f0ede8;border-radius:12px;overflow:hidden;">
              #{items_html}
              <!-- Total row -->
              <tr>
                <td colspan="2" style="padding:14px 16px;background:#faf9f7;border-top:2px solid #f0ede8;">
                  <table width="100%" cellpadding="0" cellspacing="0" role="presentation">
                    <tr>
                      <td style="font-size:14px;font-weight:700;color:#111;">Total Paid</td>
                      <td style="text-align:right;font-size:16px;font-weight:700;color:#111;">
                        UGX #{price(total)}
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </td>
        </tr>

        #{delivery_info}

        <!-- Track CTA -->
        <tr>
          <td style="padding:32px 40px;text-align:center;">
            #{Gmail.cta_button("Track My Order", track_url)}
            <p style="margin:20px 0 0;font-size:13px;color:#999;">
              Questions? We're just a message away.
            </p>
            <p style="margin:8px 0 0;">
              <a href="#{whatsapp_url}"
                 style="font-size:13px;font-weight:600;color:#25D366;text-decoration:none;">
                💬 Chat on WhatsApp
              </a>
            </p>
          </td>
        </tr>
        """,
        preview: "Your order #{reference} is confirmed — thanks for shopping with SheGlow UG!",
        header_label: "Order Confirmation"
      )

    Gmail.send_email(email, "Order Confirmed — #{reference} 🛍️", body)
  end

  # ── Admin notification ────────────────────────────────────────────────────

  def send_admin_notification(
        %{name: name, reference: reference, items: items, total_amount: total} = order
      ) do
    admin_email = Sheglow.AppConfig.admin_email()
    admin_url = "#{Sheglow.AppConfig.site_url()}/admin/orders"
    items_html = build_items_html(items)

    customer_rows =
      [
        {"Customer", name},
        {"Email", order.email || "—"},
        {"Phone", order.phone || "—"},
        {"Delivery", order.address || "—"},
        {"Total", "UGX #{price(total)}"}
      ]
      |> Enum.reject(fn {_, v} -> v == "—" end)

    body =
      Gmail.branded_email(
        """
        <tr>
          <td style="padding:32px 40px 16px;">
            <h2 style="margin:0 0 6px;font-family:'Playfair Display',Georgia,serif;font-size:22px;color:#111;">
              New Order Received
            </h2>
            <p style="margin:0;font-size:14px;color:#555;">
              Reference: <strong style="color:#111;">#{reference}</strong>
            </p>
          </td>
        </tr>

        <tr>
          <td style="padding:0 40px 24px;">
            #{Gmail.info_box(customer_rows)}
          </td>
        </tr>

        <tr>
          <td style="padding:0 40px 0;">
            <p style="margin:0 0 12px;font-size:11px;font-weight:600;letter-spacing:1.5px;text-transform:uppercase;color:#999;">
              Items
            </p>
            <table width="100%" cellpadding="0" cellspacing="0" role="presentation"
                   style="border:1px solid #f0ede8;border-radius:12px;overflow:hidden;">
              #{items_html}
              <tr>
                <td colspan="2" style="padding:14px 16px;background:#faf9f7;border-top:2px solid #f0ede8;">
                  <table width="100%" cellpadding="0" cellspacing="0" role="presentation">
                    <tr>
                      <td style="font-size:14px;font-weight:700;color:#111;">Total</td>
                      <td style="text-align:right;font-size:16px;font-weight:700;color:#111;">
                        UGX #{price(total)}
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </td>
        </tr>

        <tr>
          <td style="padding:32px 40px;text-align:center;">
            #{Gmail.cta_button("View Order in Admin", admin_url)}
          </td>
        </tr>
        """,
        preview: "New order #{reference} from #{name} — UGX #{price(total)}",
        header_label: "Admin Notification"
      )

    Gmail.send_email(admin_email, "New Order — #{reference} (UGX #{price(total)})", body)
  end

  # ── Helpers ───────────────────────────────────────────────────────────────

  defp build_items_html(items) do
    items
    |> Enum.map(fn item ->
      meta =
        [
          if(item["color"] && item["color"] != "", do: item["color"]),
          if(item["size"] && item["size"] != "", do: item["size"]),
          "×#{item["quantity"] || 1}"
        ]
        |> Enum.reject(&is_nil/1)
        |> Enum.join(" · ")

      line_total = (item["price"] || 0) * (item["quantity"] || 1)

      """
      <tr>
        <td style="padding:14px 16px;border-bottom:1px solid #f8f5f2;">
          <p style="margin:0;font-size:14px;font-weight:600;color:#111;">#{item["name"]}</p>
          <p style="margin:4px 0 0;font-size:12px;color:#888;">#{meta}</p>
        </td>
        <td style="padding:14px 16px;border-bottom:1px solid #f8f5f2;text-align:right;vertical-align:middle;white-space:nowrap;">
          <span style="font-size:14px;font-weight:600;color:#111;">UGX #{price(line_total)}</span>
        </td>
      </tr>
      """
    end)
    |> Enum.join("")
  end

  defp delivery_rows(order) do
    [
      {"Phone", order.phone},
      {"Delivery Address", order.address},
      {"City", Map.get(order, :city)}
    ]
    |> Enum.reject(fn {_, v} -> is_nil(v) || v == "" end)
  end
end
