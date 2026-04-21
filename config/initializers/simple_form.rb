SimpleForm.setup do |config|
  config.wrappers :default, class: :input,
    hint_class: :field_with_hint, error_class: :field_with_errors, valid_class: :field_without_errors do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label,  class: "block text-sm font-medium text-gray-700 mb-1"
    b.use :input,  class: "block w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 px-3 py-2"
    b.use :full_error, wrap_with: { tag: :p, class: "mt-1 text-sm text-red-600" }
    b.use :hint,  wrap_with: { tag: :p, class: "mt-1 text-sm text-gray-500" }
  end

  config.default_wrapper = :default
  config.boolean_style = :nested
  config.button_class = "inline-flex items-center justify-center rounded-lg bg-indigo-600 px-4 py-2 text-white font-medium hover:bg-indigo-700"
  config.error_notification_class = "rounded-md bg-red-50 p-4 text-red-700 mb-4"
  config.browser_validations = false
end
