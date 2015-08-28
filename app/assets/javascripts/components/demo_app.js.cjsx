@DemoApp = React.createClass

  getInitialState: ->
    { terms_accepted: @props.terms_accepted }

  onClick: ->
    AppDispatcher.dispatch
      actionType: "ACCEPT_TERMS"
      accepted: false

  onChange: ->
    @setState
      terms_accepted: Terms.accepted()

  componentDidMount: ->
    Terms.addListener("TERMS_CHANGE", @onChange)

  componentWillUnmount: ->
    Terms.removeListener("TERMS_CHANGE", @onChange)

  render: ->
    <div>
      <h1>Sample React.js demo in Rails</h1>
      <Button onClick={ @onClick } text="Terms and Conditions" />
      {
        if @state.terms_accepted == false
          <Modal />
      }
    </div>
