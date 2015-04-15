@Button = React.createClass

  render: ->
    <button onClick={ this.props.onClick }>{ this.props.text }</button>
