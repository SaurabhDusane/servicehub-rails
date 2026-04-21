Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data, :blob
  policy.object_src  :none
  policy.script_src  :self, :https, "https://js.stripe.com"
  policy.style_src   :self, :https, :unsafe_inline
  policy.frame_src   :self, "https://js.stripe.com", "https://hooks.stripe.com"
  policy.connect_src :self, :https, "https://api.stripe.com"
end

Rails.application.config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
Rails.application.config.content_security_policy_nonce_directives = %w(script-src)
