@Button = React.createClass

  render: ->
    <button onClick={ @props.onClick }>{ @props.text }</button>
