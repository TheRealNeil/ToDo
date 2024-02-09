import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ 'results', 'textField', 'valueField' ]
  static values = {
    minlength: Number,
    url: String
  }

  connect() {
    // console.log(this.minlengthValue)
    // console.log(this.urlValue)
    // console.log(this.resultsTarget)
  }

  search(event) {
    let minQueryLength = this.minlengthValue || 3
    if (event.target.value.length >= minQueryLength) {
      let params = `q=${event.target.value}`
      Rails.ajax({
        url: this.urlValue,
        type: "get",
        dataType: 'script',
        data: params,
        success: (data) => {
          this.resultsTarget.classList.remove('d-none')
          this.resultsTarget.innerHTML = data.html
        },
        error: (data) => {console.log(data)}
      })
    } else {
      this.resultsTarget.classList.add('d-none')
    }
  }

  select(event) {
    this.valueFieldTarget.value = event.target.dataset.value
    this.textFieldTarget.value = event.target.textContent
    this.resultsTarget.classList.add('d-none')
  }
}
