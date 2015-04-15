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
