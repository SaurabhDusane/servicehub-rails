class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :provider_profile

  validates :user_id, uniqueness: { scope: :provider_profile_id }
end
