Teacup::Stylesheet.new :home do
  import :root

  style :home,
    backgroundColor: :gray.uicolor

  style :conversation_view,
    frame: [[0, 64], ['100%', 300]],
    backgroundColor: :light_gray.uicolor,
    editable: false

  style :message_field,
    frame: [[0, 369], ['100%', 40]],
    backgroundColor: :white.uicolor,
    returnKeyType: :send.uireturnkey
end