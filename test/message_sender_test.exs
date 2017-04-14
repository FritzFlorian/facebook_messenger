
defmodule TestBotOne.MessageSenderTest do
  use ExUnit.Case

  test "creates a correct url" do
    assert FacebookMessenger.Sender.url == "https://graph.facebook.com/v2.6/me/messages?access_token=PAGE_TOKEN"
  end

  test "creates a correct attachment payload" do
    assert FacebookMessenger.Sender.attachment_payload(1055439761215256, "image", "sample.com/some_image.png") ==
      %{
        recipient: %{id: 1055439761215256},
        message: %{
           attachment: %{type: "image", payload: %{url: "sample.com/some_image.png"}}
        }
       }
  end

  test "creates a correct action payload" do
    assert FacebookMessenger.Sender.action_payload(1055439761215256, "mark_seen") ==
    %{sender_action: "mark_seen", recipient: %{id: 1055439761215256}}
  end

  test "creates a correct text payload" do
    assert FacebookMessenger.Sender.text_payload(1055439761215256, "Hello") ==
    %{message: %{text: "Hello"}, recipient: %{id: 1055439761215256}}
  end

  test "converts hash to json"do
    assert FacebookMessenger.Sender.to_json(%{test_key: "test_value"}) ==
    "{\"test_key\":\"test_value\"}"
  end

  test "sends correct text message" do
    FacebookMessenger.Sender.send(1055439761215256, "Hello")
    assert_received %{body: "{\"recipient\":{\"id\":1055439761215256},\"message\":{\"text\":\"Hello\"}}", url: "https://graph.facebook.com/v2.6/me/messages?access_token=PAGE_TOKEN"}
  end

  test "sends correct image message" do
    FacebookMessenger.Sender.send_image(1055439761215256, "sample.com/some_image.png")
    assert_received %{body: "{\"recipient\":{\"id\":1055439761215256},\"message\":{\"attachment\":{\"type\":\"image\",\"payload\":{\"url\":\"sample.com/some_image.png\"}}}}", url: "https://graph.facebook.com/v2.6/me/messages?access_token=PAGE_TOKEN"}
  end

  test "sends correct audio message" do
    FacebookMessenger.Sender.send_audio(1055439761215256, "sample.com/some_audio.mp3")
    assert_received %{body: "{\"recipient\":{\"id\":1055439761215256},\"message\":{\"attachment\":{\"type\":\"audio\",\"payload\":{\"url\":\"sample.com/some_audio.mp3\"}}}}", url: "https://graph.facebook.com/v2.6/me/messages?access_token=PAGE_TOKEN"}
  end

  test "sends correct video message" do
    FacebookMessenger.Sender.send_video(1055439761215256, "sample.com/some_video.mp4")
    assert_received %{body: "{\"recipient\":{\"id\":1055439761215256},\"message\":{\"attachment\":{\"type\":\"video\",\"payload\":{\"url\":\"sample.com/some_video.mp4\"}}}}", url: "https://graph.facebook.com/v2.6/me/messages?access_token=PAGE_TOKEN"}
  end

  test "sends correct file message" do
    FacebookMessenger.Sender.send_file(1055439761215256, "sample.com/some_file.pdf")
    assert_received %{body: "{\"recipient\":{\"id\":1055439761215256},\"message\":{\"attachment\":{\"type\":\"file\",\"payload\":{\"url\":\"sample.com/some_file.pdf\"}}}}", url: "https://graph.facebook.com/v2.6/me/messages?access_token=PAGE_TOKEN"}
  end


  test "sends correct action message" do
    FacebookMessenger.Sender.send_action(1055439761215256, "mark_seen")
    assert_received %{body: "{\"sender_action\":\"mark_seen\",\"recipient\":{\"id\":1055439761215256}}", url: "https://graph.facebook.com/v2.6/me/messages?access_token=PAGE_TOKEN"}
  end
end
