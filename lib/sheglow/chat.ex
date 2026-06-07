defmodule Sheglow.Chat do
  @moduledoc """
  Live chat context — sessions, messages, and PubSub broadcasting.
  """

  import Ecto.Query
  alias Sheglow.Repo
  alias Sheglow.Chat.{Session, Message}

  # ── PubSub helpers ────────────────────────────────────────────────────────

  def topic_visitor(visitor_id), do: "chat:visitor:#{visitor_id}"
  def topic_admin(), do: "chat:admin"
  def topic_admin_session(session_id), do: "chat:admin:session:#{session_id}"

  def subscribe_visitor(visitor_id),
    do: Phoenix.PubSub.subscribe(Sheglow.PubSub, topic_visitor(visitor_id))

  def unsubscribe_visitor(visitor_id),
    do: Phoenix.PubSub.unsubscribe(Sheglow.PubSub, topic_visitor(visitor_id))

  def subscribe_admin(),
    do: Phoenix.PubSub.subscribe(Sheglow.PubSub, topic_admin())

  def subscribe_admin_session(session_id),
    do: Phoenix.PubSub.subscribe(Sheglow.PubSub, topic_admin_session(session_id))

  defp broadcast_visitor(visitor_id, event, payload),
    do: Phoenix.PubSub.broadcast(Sheglow.PubSub, topic_visitor(visitor_id), {event, payload})

  defp broadcast_admin(event, payload),
    do: Phoenix.PubSub.broadcast(Sheglow.PubSub, topic_admin(), {event, payload})

  defp broadcast_admin_session(session_id, event, payload),
    do: Phoenix.PubSub.broadcast(Sheglow.PubSub, topic_admin_session(session_id), {event, payload})

  # ── Sessions ──────────────────────────────────────────────────────────────

  def get_or_create_session(visitor_id, attrs \\ %{}) do
    case Repo.get_by(Session, visitor_id: visitor_id, status: "open") ||
           Repo.get_by(Session, visitor_id: visitor_id, status: "active") do
      nil ->
        %Session{}
        |> Session.changeset(Map.merge(attrs, %{visitor_id: visitor_id}))
        |> Repo.insert()

      session ->
        {:ok, session}
    end
  end

  def get_session(id), do: Repo.get(Session, id)
  def get_session!(id), do: Repo.get!(Session, id)

  def list_sessions() do
    from(s in Session,
      order_by: [
        asc: fragment("CASE WHEN ? IN ('open','active') THEN 0 ELSE 1 END", s.status),
        desc: coalesce(s.last_message_at, s.inserted_at)
      ]
    )
    |> Repo.all()
  end

  def count_open_sessions() do
    from(s in Session, where: s.status in ["open", "active"])
    |> Repo.aggregate(:count)
  end

  def update_session(session, attrs) do
    session
    |> Session.changeset(attrs)
    |> Repo.update()
  end

  # ── Messages ──────────────────────────────────────────────────────────────

  def list_messages(session_id) do
    from(m in Message,
      where: m.chat_session_id == ^session_id,
      order_by: [asc: m.inserted_at]
    )
    |> Repo.all()
  end

  def create_message(attrs) do
    result =
      %Message{}
      |> Message.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, message} ->
        session = get_session!(message.chat_session_id)
        is_first = length(list_messages(session.id)) == 1

        update_session(session, %{
          last_message_at: DateTime.utc_now(:second),
          status: "active"
        })

        if message.sender == "visitor" do
          broadcast_admin(:new_message, %{session: session, message: message})
          broadcast_admin_session(session.id, :new_message, message)

          if is_first do
            Task.start(fn ->
              Sheglow.ChatNotifier.notify_admin_new_chat(session, message)
            end)
          end
        else
          visitor_id = Repo.get!(Session, message.chat_session_id).visitor_id
          broadcast_visitor(visitor_id, :new_message, message)
          broadcast_admin_session(session.id, :new_message, message)
        end

        {:ok, message}

      error ->
        error
    end
  end

  def mark_read_by_admin(session_id) do
    from(m in Message,
      where: m.chat_session_id == ^session_id and m.sender == "visitor"
    )
    |> Repo.update_all(set: [read_by_admin: true])
  end

  # ── Product search (for admin suggestions) ────────────────────────────────

  def search_products(query) when is_binary(query) and byte_size(query) > 0 do
    term = "%#{query}%"

    from(p in Sheglow.Products.Product,
      where: ilike(p.name, ^term) and p.status == "active",
      order_by: [asc: p.name],
      limit: 6,
      select: %{
        id: p.id,
        name: p.name,
        slug: p.slug,
        image: p.image,
        base_price: p.base_price
      }
    )
    |> Repo.all()
  end

  def search_products(_), do: []
end
