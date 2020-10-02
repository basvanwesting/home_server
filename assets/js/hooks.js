import flatpickr from "flatpickr"

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

export default Hooks;
