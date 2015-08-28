@Modal = React.createClass

  handleKeyDown: (event) ->
    if event.keyCode == 27
      @close()

  stopPropogation: (event) ->
    event.stopPropagation()

  close: ->
    AppDispatcher.dispatch
      actionType: "ACCEPT_TERMS"
      accepted: true

  componentDidMount: ->
    document.addEventListener("keydown", @handleKeyDown, false)

  componentDidUnmount: ->
    document.removeEventListener("keydown", @handleKeyDown, false)

  render: ->
    <div className="modal-background" onClick={ @close }>
      <div className="modal-window" onClick={ @stopPropogation }>

        <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec vel placerat libero. Aliquam sed convallis odio.</p>

        <Button onClick={ @close } text="I accept the terms and conditions" />

      </div>
    </div>