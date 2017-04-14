defmodule FacebookMessenger.Sender do
  @moduledoc """
  Module responsible for communicating back to facebook messenger
  """
  require Logger

  @doc """
  sends a message to the the recepient

    * :recepient - the recepient to send the message to
    * :message - the message to send
  """
  @spec send(String.t, String.t) :: HTTPotion.Response.t
  def send(recepient, message) do
    text_payload(recepient, message)
    |> to_json
    |> post_to_messenger_api
  end

  @doc """
  sends an image message to the recipient

    * :recepient - the recepient to send the message to
    * :image_url - the url of the image to be sent
  """
  @spec send_image(String.t, String.t) :: HTTPotion.Response.t
  def send_image(recepient, image_url) do
    attachment_payload(recepient, "image", image_url)
    |> to_json
    |> post_to_messenger_api
  end

  @doc """
  sends an audio message to the recipient

  * :recipient - the recipient to send the message to
  * :audio_url - the url of the audio to be sent
  """
  @spec send_audio(String.t, String.t) :: HTTPotion.Response.t
  def send_audio(recipient, audio_url) do
    attachment_payload(recipient, "audio", audio_url)
    |> to_json
    |> post_to_messenger_api
  end

  @doc """
  sends an video message to the recipient

  * :recipient - the recipient to send the message to
  * :video_url - the url of the video to be sent
  """
  @spec send_video(String.t, String.t) :: HTTPotion.Response.t
  def send_video(recipient, video_url) do
    attachment_payload(recipient, "video", video_url)
    |> to_json
    |> post_to_messenger_api
  end

  @doc """
  sends an file message to the recipient

  * :recipient - the recipient to send the message to
  * :file_url - the url of the file to be sent
  """
  @spec send_file(String.t, String.t) :: HTTPotion.Response.t
  def send_file(recipient, file_url) do
    attachment_payload(recipient, "file", file_url)
    |> to_json
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
    |> to_json
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
  Helper to post a body to the facebook messenger api endpoint.

    * :body - the post body to send to facebook
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
