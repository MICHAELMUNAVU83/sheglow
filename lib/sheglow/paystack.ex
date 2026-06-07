defmodule Sheglow.Paystack do
  @moduledoc """
  The Paystack module is responsible for all the interactions with the Paystack API
  """
  defp api_url, do: "https://api.paystack.co/transaction/initialize"

  defp paystack_headers,
    do: [
      {
        "Content-Type",
        "application/json"
      },
      {
        "Authorization",
        "Bearer #{api_key()}"
      }
    ]

  def initialize(email, amount, transaction_id) do
    api_url = api_url()

    amount = amount * 100

    body =
      %{
        "reference" => transaction_id,
        "email" => email,
        "amount" => amount,
        "callback_url" => callback_url()
      }

    req_options = [
      headers: paystack_headers(),
      json: body,
      retry: :transient,
      max_retries: 5,
      receive_timeout: 60_000
    ]

    case Req.post(api_url, req_options) do
      {:ok, %{status: 200, body: body}} ->
        body
        |> Map.get("data")

      {:ok, %{status: 400, body: body}} ->
        reason =
          body
          |> Map.get("message")

        %{"error" => reason}

      {:error, reason} ->
        %{"error" => reason}
    end
  end

  def verify(reference) do
    url = "https://api.paystack.co/transaction/verify/#{reference}"

    case Req.get(url, headers: paystack_headers()) do
      {:ok, %{status: 200, body: body}} ->
        data = Map.get(body, "data", %{})
        status = Map.get(data, "status")

        if status == "success" do
          {:ok, data}
        else
          {:error, "Payment status: #{status}"}
        end

      {:ok, %{body: body}} ->
        {:error, Map.get(body, "message", "Verification failed")}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp api_key do
    Application.get_env(:sheglow, :paystack_secret_key) ||
      "sk_test_7267bf7b9b38cd9798c6328f7e0b3cc5a264f4aa"
  end

  def callback_url do
    base = Application.get_env(:sheglow, :site_url)
    "#{base}/success"
  end
end
