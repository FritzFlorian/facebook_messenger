defmodule FacebookMessenger.LocationQuickReply do
  @modulecdoc"""
  Facebook quick reply structure to request the users location
  (quick reply that allows the user to send his location)
  """

  @derive [Poison.Encoder]
  defstruct([content_type: "location"])

  @type t :: %FacebookMessenger.LocationQuickReply{
    content_type: String.t
  }
end
