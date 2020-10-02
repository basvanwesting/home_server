import flatpickr from "flatpickr"
import { Netherlands } from "flatpickr/dist/l10n/nl.js"

let Hooks = {};

Hooks.DatePickerInput = {
  mounted() {
    flatpickr(this.el, {
      enableTime: false,
      dateFormat: "F d, Y",
      onChange: this.handleDatePicked.bind(this)
    })
  },

  handleDatePicked(selectedDates, dateStr, instance) {
    this.pushEvent("date-picked", { dateStr: dateStr })
  }
}

Hooks.DateTimePickerInput = {
  mounted() {
    flatpickr(this.el, {
      enableTime: true,
      enableSeconds: true,
      //locale: Netherlands,
      dateFormat: "Y-m-d H:i:S",
    })
  },
}

export default Hooks;
