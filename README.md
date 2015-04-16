# Sample React.js app integrated with rails

[React.js](https://facebook.github.io/react) is a library that is used to build brilliant user interfaces. Unfortunately for me, it was tough to find a getting started tutorial that showed that it could fit in to rails perfectly.

Additionally, I wanted to keep my rails goodness including coffeescript in the asset pipeline. This tutorial will take you from a blank rails app and add support for react.js and [flux](https://facebook.github.io/flux/) and also walk you through creating your first components.

# Rails app setup

OK, lets start by making a simple rails app. 

```
rails new SampleReactApp
cd SampleReactApp
```

Let’s add in a few gems to get started. In your gemfile add in these react based gems.

```
# Just for making the views nicer
gem 'haml-rails'

# React.js
gem 'react-rails', '~> 1.0.0.pre', github: 'reactjs/react-rails'
gem 'flux-rails-assets'
gem 'sprockets-coffee-react'
```

Don’t forget to bundle.

Some housekeeping. Convert all .js to .js.coffee. I like having everything in coffee script rather than a mish mash of plain js and coffee script. I think consistency is a very good trait to have. So, to convert application.js to application.js.coffee, I just removed all the comments and replaced the includes from starting with double slashes to starting with hashes, like this ...

```
#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require_tree .
```

Now I will add a controller that will serve as the root to our react app.

```
rails g controller Welcome index
```

Quickly jump in to the routes file and set the root route to go to our Welcome controller

```
root 'welcome#index'
```

Do a quick test by firing up rails s and visiting localhost:3000 and see if your welcome index page is showing.

While we are at it, let’s remove some turbo links cruft. We won’t be getting any benefit from that at all. It won’t be needed.

Take turbolinks out of ...

- the gemfile
- app/assets/javascripts/application.js.coffee
- app/views/layouts/application.html.erb

Heck, while you are in there, convert that application.html.erb file to haml. You will feel better once you do.

All we have now is a raw rails app that basically does nothing. So let’s start to add in react.js.

In react.js apps, we are going to make components and use stores. These are javascript based so we are going to organise them in to folders within assets/javascripts

```
mkdir ./app/assets/javascripts/components
mkdir ./app/assets/javascripts/stores
```

We need a file called assets/javascripts/components.js.coffee for asset compilation to work.

```
#= require_tree ./components
```

## Dispatcher

The dispatcher is the mechanism used to broadcast messages to registered callbacks. We are going to need one for our application so that we can send messages to the dispatcher and listen for them.

Here is the contents of assets/javascripts/dispatcher.js.coffee

```
window.AppDispatcher = new FluxDispatcher()
```


## application.js.coffee

Now, we can add in our react.js libraries to our javascript pipeline.

```
#= require jquery
#= require jquery_ujs
#= require react
#= require react_ujs
#= require components
#= require flux
#= require eventemitter
#= require dispatcher
#= require_tree .
```

Do a quick smoke test and make sure everything is running normally. 

# Diving in to react.js

Our app still doesn’t do anything yet. Let’s make a button and a modal window.

## The button

Out first component that we are going to make is a button. Create the file assets/javascripts/components/button.js.cjsx

The .cjsx extension means we are writing a JSX component, but doing it in coffeescript.

```
@Button = React.createClass

  onClick: ->
    alert "You clicked the onClick handler"

  render: ->
    <button onClick={ this.onClick }>My Button</button>
```

The render method renders our component's html, but you will notice that the onClick handler calls our onClick method in the class.

It's a great way to do things. Also be aware that in react, the attributes are case sensitive and lower camel cased. Just make sure you're consistent with this or you might spend a bit of time debugging.

In out welcome#index view, we are going to use our component.

```
= react_component "Button", { }, { prerender: true }
```

The important thing to realise here is that the component is pre-rendered on the server and the javascript events are attached to the rendered component. Without server side rendering, browsers will need to render the page client side and search engines will get empty content when scanning our pages. 

Fire up rails and check out your magnificent react button. Very cool.

But let’s make it a little more configurable, let’s add the button text ...

```
= react_component "Button", { text: "Super Button" }, { prerender: true }
```

And change the render method to use this new parameter we just passed in.

```
<button onClick={ this.onClick }>{ this.props.text }</button>
```

In react.js land, these parameters are called properties.


## Making an app container

Now let us build up this app a little more. I want a real modal window to appear if I clicked this button so I am going create a component for my simple app.

I am going to just create another component which will be my app and render my button component from in there.

```
@DemoApp = React.createClass

  render: ->
    <Button text="Super Button" />
```

Additionally, I am now going to render my app in welcome#index

```
= react_component "DemoApp", { }, { prerender: true }
```

Woa! I just clicked refresh and I got an error!

Encountered error "ReferenceError: Can't find variable: DemoApp" when prerendering DemoApp with {}

It's just that the react framework hasn't caught up. Sometimes you just need to restart rails for these things to take hold. A quick restart and we're back in business.

We need one more change. I don’t like the onClick handler to be in the button class, it needs to be where I use it. This is easy to do. I am just going to take that onClick handler out from the Button component and move it to the DemoApp component. In the Button component, our onClick handler is going to be passed in as a property.

```
@Button = React.createClass

  render: ->
    <button onClick={ this.props.onClick }>{ this.props.text }</button>
```

My DemoApp component then passes this in like

```
@DemoApp = React.createClass

  onClick: ->
    alert "You clicked the DemoApp.onClick handler"

  render: ->
    <Button onClick={ this.onClick } text="Super Button" />
```

Refresh and check it out.

Now, that we have an App container, we can get rid of the temporary text in welcome#index and just have my react component.

I’ll add the header to my app component instead.

```
@DemoApp = React.createClass

  onClick: ->
    alert "You clicked the DemoApp.onClick handler"

  render: ->
    <div>
      <h1>Sample React.js demo in Rails</h1>
      <Button onClick={ this.onClick } text="Super Button" />
    </div>
```

Super sweet! The important thing I did here was to make sure that the render method always is wrapped in a div so that a single component is always returned. Bad, horrible, unmentionable things happen when you don’t have a single html element being returned from the render method.

## Modal Component

We’re going to really jump in deep here. This is my modal component.

```
@Modal = React.createClass

  _handleKeyDown: (event) ->
    if event.keyCode == 27
      this.close()

  stopPropogation: (event) ->
    event.stopPropagation()

  close: ->
    alert "Close the modal!"

  componentDidMount: ->
    document.addEventListener("keydown", this._handleKeyDown, false)
    
  componentDidUnmount: ->
    document.removeEventListener("keydown", this._handleKeyDown, false)

  render: ->
    <div className="modal-background" onClick={ this.close }>
      <div className="modal-window" onClick={ this.stopPropogation }>

        <p>This is some content</p>

        <Button onClick={ this.close } text="OK" />

      </div>
    </div>
```

We also need a bit of scss to make it look right.

```
.modal-background {

  display: flex;
  align-items: center;
  justify-content: center;
  position: fixed;
  top: 0px;
  left: 0px;
  right: 0px;
  bottom: 0px;
  padding: 1em;

  background: rgba(0, 0, 0, .5);

  .modal-window {

    background-color: #ffffff;
    padding: 1em;
    border-radius: 4px;
    box-shadow: 0px 5px 15px 0px rgba(0,0,0,0.1);

    .close-button {
      color: rgba(0,0,0,0.25);
      cursor: pointer;
      display: inline-block;
      padding: 0.5em 1em;
      position: absolute;
      right: 0;
      transition: color 0.25s ease;
      top: 0;

      &:hover {
        color: rgba(0,0,0,1);    
      }
    }
  }
}
```

And put the modal in our DemoApp component

```
@DemoApp = React.createClass

  onClick: ->
    alert "You clicked the DemoApp.onClick handler"

  render: ->
    <div>
      <h1>Sample React.js demo in Rails</h1>
      <Button onClick={ this.onClick } text="Super Button" />
      <Modal />
    </div>
```

Refresh and look in awe. Unfortunately, it just needs a few missing ingredients to make it work. Events and state.

Let's make it a little more interesting. Let’s make this modal our terms and conditions which must be accepted in order to look at our beautiful site. Until they click OK in our window, that modal is going to be visible.

We are going to do a lot, but once our structure is in place, you will see just how great react.js is at making super dynamic interfaces.

## Stores

The purpose of the store is to be the source of application state and to manage callbacks from actions. Let’s look at the store I created to remember if I accepted my terms and conditions.

```
class TermsStore extends EventEmitter

  _accepted: false

  dispatchToken = AppDispatcher.register (payload) ->

    switch payload.actionType
      when "ACCEPT_TERMS"
        Terms.setAccepted(payload.accepted)

  setAccepted: (data) =>
    @_accepted = data
    @emit('TERMS_CHANGE')

  accepted: =>
    @_accepted == true

window.Terms = new TermsStore()
```

There will only ever one instance of any store we create, in this case, it is Terms.

I have an attribute _accepted just to record if I agree and a getter/setter method. The store also registers with the AppDispatcher to receive application messages. 

Let's follow the message through the system. Some kind of event happens that sends a message to our AppDispatcher. It broadcasts the payload to all registered callbacks, to which TermsStore registered to receive messages. In TermsStore, any payload that has the actionType of "ACCEPT_TERMS", I set the @_accepted variable and then emit the event "TERMS_CHANGE". We now need to listen for the event in components that rely on the Terms state.

# Listening to emitted events

```
@DemoApp = React.createClass

  getInitialState: ->
    { terms_accepted: this.props.terms_accepted }

  onClick: ->
    AppDispatcher.dispatch
      actionType: "ACCEPT_TERMS"
      accepted: false

  onChange: ->
    this.setState
      terms_accepted: Terms.accepted()

  componentDidMount: ->
    Terms.addListener("TERMS_CHANGE", this.onChange)

  componentWillUnmount: ->
    Terms.removeListener("TERMS_CHANGE", this.onChange)

  render: ->
    <div>
      <h1>Sample React.js demo in Rails</h1>
      <Button onClick={ this.onClick } text="Terms and Conditions" />
      {
        if this.state.terms_accepted == false
          <Modal />
      }
    </div>
```

There is a [lifecycle to components](https://facebook.github.io/react/docs/component-specs.html) and we are going to patch in to the componentDidMount/componentWillUnmount callbacks to register our listener for the "TERMS_CHANGE" event.

When that event is fired, our onChange method is called and we can set our component's state which will cause the component to re-render. In our DemoApp, depending on this.state.terms_accepted, the modal either exists or does not.

To complete the example, we will also modify our Modal component to dispatch the message when we click on our "I Accept" button.

```
@Modal = React.createClass

  _handleKeyDown: (event) ->
    if event.keyCode == 27
      this.close()

  stopPropogation: (event) ->
    event.stopPropagation()

  close: ->
    AppDispatcher.dispatch
      actionType: "ACCEPT_TERMS"
      accepted: true

  componentDidMount: ->
    document.addEventListener("keydown", this._handleKeyDown, false)
    
  componentDidUnmount: ->
    document.removeEventListener("keydown", this._handleKeyDown, false)

  render: ->
    <div className="modal-background" onClick={ this.close }>
      <div className="modal-window" onClick={ this.stopPropogation }>

        <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec vel placerat libero. Aliquam sed convallis odio.</p>

        <Button onClick={ this.close } text="I accept the terms and conditions" />

      </div>
    </div>
```

And that is it, our first react.js rails app.

# Making life easier

Going through those steps to setup a rails app with react was a bit long for my liking so I created an application template to get you to a blank rails app with react.js so that you can begin to develop from there.

```
rails new MyApp -m https://raw.githubusercontent.com/craigs/reactjs-rails-template/master/template-react.rb
```

Happy building :)
