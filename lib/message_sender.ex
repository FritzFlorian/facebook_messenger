defmodule FacebookMessenger.Sender do
  @moduledoc """
  Module responsible for communicating back to facebook messenger
  """
  require Logger

  @doc """
  sends a message to the the recepient

    * :recepient - the recepient to send the message to
    * :message - the message to send
    * :quick_replies - an optional array of quick replies
  """
  @spec send(String.t, String.t, [FacebookMessenger.LocationQuickReply | FacebookMessenger.NormalQuickReply]) :: HTTPotion.Response.t
  def send(recepient, message, quick_replies \\ []) do
    text_payload(recepient, message)
    |> add_quick_replies(quick_replies)
    |> post_to_messenger_api
  end

  @doc """
  sends an image message to the recipient

    * :recepient - the recepient to send the message to
    * :image_url - the url of the image to be sent
    * :quick_replies - an optional array of quick replies
  """
  @spec send_image(String.t, String.t, [FacebookMessenger.LocationQuickReply | FacebookMessenger.NormalQuickReply]) :: HTTPotion.Response.t
  def send_image(recepient, image_url, quick_replies \\ []) do
    attachment_payload(recepient, "image", image_url)
    |> add_quick_replies(quick_replies)
    |> post_to_messenger_api
  end

  @doc """
  sends an audio message to the recipient

    * :recipient - the recipient to send the message to
    * :audio_url - the url of the audio to be sent
    * :quick_replies - an optional array of quick replies
  """
  @spec send_audio(String.t, String.t, [FacebookMessenger.LocationQuickReply | FacebookMessenger.NormalQuickReply]) :: HTTPotion.Response.t
  def send_audio(recipient, audio_url, quick_replies \\ []) do
    attachment_payload(recipient, "audio", audio_url)
    |> add_quick_replies(quick_replies)
    |> post_to_messenger_api
  end

  @doc """
  sends an video message to the recipient

    * :recipient - the recipient to send the message to
    * :video_url - the url of the video to be sent
    * :quick_replies - an optional array of quick replies
  """
  @spec send_video(String.t, String.t, [FacebookMessenger.LocationQuickReply | FacebookMessenger.NormalQuickReply]) :: HTTPotion.Response.t
  def send_video(recipient, video_url, quick_replies \\ []) do
    attachment_payload(recipient, "video", video_url)
    |> add_quick_replies(quick_replies)
    |> post_to_messenger_api
  end

  @doc """
  sends an file message to the recipient

    * :recipient - the recipient to send the message to
    * :file_url - the url of the file to be sent
    * :quick_replies - an optional array of quick replies
  """
  @spec send_file(String.t, String.t, [FacebookMessenger.LocationQuickReply | FacebookMessenger.NormalQuickReply]) :: HTTPotion.Response.t
  def send_file(recipient, file_url, quick_replies \\ []) do
    attachment_payload(recipient, "file", file_url)
    |> add_quick_replies(quick_replies)
    |> post_to_messenger_api
  end

  @doc """
  Sends a sender_action to the recipient.
  Possible action_names are: mark_seen, typing_on, typing_off

    * :recipient - the recipient to send the message to
    * :action_name - one of mark_seen, typing_on or typing_off
  """
  @spec send_action(String.t, String.t) :: HTTPotion.Response.t
  def send_action(recipient, action_name) when action_name in ~w(mark_seen typing_on typing_off) do
    action_payload(recipient, action_name)
    |> post_to_messenger_api
  end

  @doc """
  creates a payload to send to facebook

    * :recipient - the recipient to send the message to
    * :message - the message to send
  """
  def text_payload(recipient, message) do
    %{
      recipient: %{id: recipient},
      message: %{text: message}
    }
  end

  @doc """
  creates a payload for an attachment to send to facebook

    * :recipient - the recipient to send the message to
    * :type - the attachment type to send
    * :url - the url of the attachment to send
  """
  def attachment_payload(recipient, type, url) when type in ~w(image video file audio) do
    %{
      recipient: %{id: recipient},
      message: %{
        attachment: %{
          type: type,
          payload: %{
            url: url
          }
        }
      }
    }
  end

  def action_payload(recepient, action_name) do
    %{
      recipient: %{id: recepient},
      sender_action: action_name
    }
  end

  @doc """
  adds the given quick replies to the response map.
  Leaves the current_response unchanged if the quick_replies array is empty

    * :current_response - the current response given as a map
    * :quick_replies - an array of quick replies to add to the response
  """
  def add_quick_replies(current_response, quick_replies = []) do
    current_response
  end

  def add_quick_replies(current_response, quick_replies) do
    Map.update(current_response, :message, %{quick_replies: quick_replies}, fn message_part ->
      Map.put(message_part, :quick_replies, quick_replies)
    end)
  end

  @doc """
  converts a map to json using poison

    * :map - the map to be converted to json
  """
  def to_json(map) do
    map
    |> Poison.encode
    |> elem(1)
  end

  @doc """
  return the url to hit to send the message
  """
  def url do
    query = "access_token=#{page_token}"
    "https://graph.facebook.com/v2.6/me/messages?#{query}"
  end

  @doc """
  Helper to post a map as body to the facebook messenger api endpoint.

  * :body - the json map to post as body to facebook
  """
  def post_to_messenger_api(body) when is_map(body) do
    body
    |> to_json
    |> post_to_messenger_api
  end

  @doc """
  Helper to post a binary body to the facebook messenger api endpoint.

    * :body - the binary encoded post body to send to facebook
  """
  def post_to_messenger_api(body) do
    res = manager.post(
      url: url,
      body: body
    )
    Logger.info("response from FB #{inspect(res)}")
    res
  end

  defp page_token do
    Application.get_env(:facebook_messenger, :facebook_page_token)
  end

  defp manager do
    Application.get_env(:facebook_messenger, :request_manager) || FacebookMessenger.RequestManager
  end
end
