import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "form", "status" ]

  connect() {
    this.timeout  = null
    this.duration = this.data.get("duration") || 2000
  }

  save(event) {
    event.preventDefault()
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      this.statusTarget.textContent = "Saving..."
      Rails.fire(this.formTarget, 'submit')
    }, this.duration)
  }

  saveNow(event) {
    event.preventDefault()
    this.statusTarget.textContent = "Saving..."
    Rails.fire(this.formTarget, 'submit')
  }

  success() {
    this.setStatus("Saved!")
  }

  error() {
    this.setStatus("Unable to save!")
  }

  setStatus(message) {
    this.statusTarget.textContent = message

    this.timeout = setTimeout(() => {
      this.statusTarget.textContent = ""
    }, 5000)
  }
}
