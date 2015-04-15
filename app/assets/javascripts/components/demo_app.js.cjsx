@DemoApp = React.createClass

  getInitialState: ->
    { terms_accepted: this.props.terms_accepted }

  onClick: ->
    AppDispatcher.dispatch
      actionType: "ACCEPT_TERMS"
      accepted: false

  _onChange: ->
    this.setState
      terms_accepted: Terms.accepted()

  componentDidMount: ->
    Terms.addListener("TERMS_CHANGE", this._onChange)

  componentWillUnmount: ->
    Terms.removeListener("TERMS_CHANGE", this._onChange)

  render: ->
    <div>
      <h1>Sample React.js demo in Rails</h1>
      <Button onClick={ this.onClick } text="Terms and Conditions" />
      {
        if this.state.terms_accepted == false
          <Modal />
      }
    </div>
