import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { dismissAfter: { type: Number, default: 5000 } }

  connect() {
    if (this.dismissAfterValue > 0) {
      this.timeout = setTimeout(() => this.dismiss(), this.dismissAfterValue)
    }
  }

  dismiss() {
    this.element.classList.add("opacity-0", "transition", "duration-300")
    setTimeout(() => this.element.remove(), 300)
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }
}
