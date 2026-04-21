module Notifications
  class Creator
    def self.call(user:, kind:, title:, body: nil, url: nil, metadata: {})
      Notification.create!(
        user: user, kind: kind, title: title, body: body, url: url, metadata: metadata
      )
    end
  end
end
