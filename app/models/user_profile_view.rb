class UserProfileView < ActiveRecord::Base
  belongs_to :user
  belongs_to :target_user, class_name: 'User', counter_cache: :profile_views
end