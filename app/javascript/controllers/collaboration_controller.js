import { Controller } from "stimulus"
import CableReady from "cable_ready"
import consumer from '../channels/consumer'

export default class extends Controller {
  static targets = ["form"]

  connect() {
    console.log(this.data.get("id"))
    this.subscription = consumer.subscriptions.create({
      channel: "CollaborationChannel",
      stream: this.data.get("stream")
    }, {
      connected: this._cableConnected.bind(this),
      disconnected: this._cableDisconnected.bind(this),
      received: this._cableReceived.bind(this),
    });
    this.setOccupancy()
  }

  disconnect() {
  }

  occupy(event) {
    this.subscription.perform('occupy_fieldset', {
      fieldset: event.target.dataset.collaborationFieldset
    })
  }

  vacate(event) {
    this.subscription.perform('vacate_fieldset', {
      fieldset: event.target.dataset.collaborationFieldset
    })
  }

  setOccupancy () {
    let occupied_fieldsets = this.formTarget.dataset.collaborationOccupiedFieldsets.split(",").filter(Boolean)
    const focused_fieldset = focusedFieldset()

    // Prevent our focused fieldset form being disabled
    if (focused_fieldset) {
      occupied_fieldsets = occupied_fieldsets.filter(fieldset => fieldset != focused_fieldset)
    }

    // Enable all the currently disabled fields
    enableDisabledFields()

    // Mark all the fields occupied
    occupied_fieldsets.forEach(function (fieldset) {
      var elements = document.querySelectorAll(`[data-collaboration-fieldset=${fieldset}]`)
      elements.forEach(function (element) {
        if (element) {
          element.disabled = true
        }
      })
    })
  }

  _cableConnected() {
    // Called when the subscription is ready for use on the server
  }

  _cableDisconnected() {
    // Called when the subscription has been terminated by the server
  }

  _cableReceived(data) {
    // Called when there's incoming data on the websocket for this channel
    if (data.cableReady) CableReady.perform(data.operations)
    this.setOccupancy()
  }
}

function enableDisabledFields (){
  document.querySelectorAll(':disabled').forEach(function (field) {
    field.disabled = false
  })
}

function focusedFieldset (){
  const focused_field = document.querySelector(":focus")
  if (focused_field) {
    return focused_field.closest("[data-collaboration-fieldset]").dataset.collaborationFieldset
  }
}
