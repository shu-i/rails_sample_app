class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  scope :including_replies, ->(user){where("in_reply_to = ? OR in_reply_to = ? OR user_id = ?", "", "@#{user.id}\-#{user.name.sub(/\s/,'-')}", user.id)}
  mount_uploader :picture, PictureUploader
  before_save { self.in_reply_to = reply_user.to_s }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :in_reply_to, presence: false
  validate :picture_size
  

  def reply_user
    if user_unique_name = content.match(/(@[^\s]+)\s.*/)
      user_unique_name[1]
    end
  end
  
  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", 
          user_id: user.id)
  end

  private

    # アップロードされた画像のサイズをバリデーションする
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
