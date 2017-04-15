defmodule FacebookMessenger.NormalQuickReply do
  @moduledoc"""
  Facebook quick reply stucture
  (normal quick replies with text and optional image)
  """

  @derive [Poison.Encoder]
  @enforce_keys [:title, :payload]
  defstruct([content_type: "text", title: nil, payload: nil, image_url: nil])

  @type t :: %FacebookMessenger.NormalQuickReply{
    content_type: String.t,
    title: String.t,
    payload: String.t,
    image_url: String.t
  }
end
