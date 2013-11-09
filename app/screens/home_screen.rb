class HomeScreen < PM::Screen
  stylesheet :home
  attr_accessor :peer_id, :session, :browser, :advertiser

  title "Home"

  def on_load
    set_nav_bar_button :left, title: "Browse", action: :browse_tapped
    self.setup_multipeer
  end

  def will_present
    @view_setup ||= self.set_up_view
  end

  def set_up_view
    layout(self.view, :home) do
      # @browser_button = subview(UIButton, :browser_button)
      @conversation_view = subview(UITextView, :conversation_view)
      @message_field = subview(UITextField, :message_field)
    end

    @message_field.delegate = self
    true
  end

  def browse_tapped
    self.presentViewController(browser, animated: true, completion: nil)
  end

  def setup_multipeer
    self.peer_id = MCPeerID.alloc.initWithDisplayName UIDevice.currentDevice.name
    self.session = MCSession.alloc.initWithPeer self.peer_id
    self.browser = MCBrowserViewController.alloc.initWithServiceType("chat", session: self.session)
    self.advertiser = MCAdvertiserAssistant.alloc.initWithServiceType("chat", discoveryInfo: nil, session: self.session)

    self.browser.delegate = self
    self.session.delegate = self
    self.advertiser.start
  end

  def dismissBrowser
    self.browser.dismissViewControllerAnimated true, completion: nil
  end

  def send_text
    message = @message_field.text
    @message_field.text = ''

    data = message.dataUsingEncoding(NSUTF8StringEncoding)

    error = Pointer.new(:object)
    self.session.sendData(data, toPeers: self.session.connectedPeers, withMode:MCSessionSendDataUnreliable, error: error)

    self.receive_message(message, self.peer_id)
  end

  def receive_message(message, peer)
    from = peer == self.peer_id ? "me" : peer.displayName
    final_text = "\n#{from}: #{message}\n"
    @conversation_view.text = @conversation_view.text.stringByAppendingString(final_text)
  end

  # MCBrowserViewControllerDelegate

  def browserViewControllerDidFinish(browserViewController)
    self.dismissBrowser
  end

  def browserViewControllerWasCancelled(browserViewController)
    self.dismissBrowser
  end

  # UITextFieldDelegate
  def textFieldShouldReturn(textField)
    textField.resignFirstResponder
    self.send_text
    true
  end

  # MCSessionDelegate
  def session(session, peer: peer_id, didChangeState: state)

  end

  def session(session, didReceiveData: data, fromPeer: peer_id)
    message = NSString.alloc.initWithData(data, encoding:NSUTF8StringEncoding)

    Dispatch::Queue.main.async do
      self.receive_message(message, peer_id)
    end
  end

  def session(session, didReceiveStream: stream, withName: stream_name, fromPeer: peer_id)

  end

  def session(session, didStartReceivingResourceWithName: resource_name, fromPeer: peer_id, withProgress: progress)

  end

  def session(session, didFinishReceivingResourceWithName:resource_name, fromPeer:peer_id, atURL:local_url, withError: error)

  end
end
