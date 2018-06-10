class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  scope :including_replies, ->(id){where("in_reply_to = ?", id)}
  mount_uploader :picture, PictureUploader
  before_validation :set_in_reply_to
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :in_reply_to, presence: false
  validate :picture_size, :reply_to_user
  

  def set_in_reply_to
    if @reply_dest = content.match(/@([0-9]+)(\S+)/)
      self.in_reply_to = @reply_dest[1]
    else
      self.in_reply_to = 0
    end

  end
  
  def reply_to_user
    return if self.in_reply_to == 0
    unless user = User.find_by(id: self.in_reply_to)
      errors.add(:base, "User ID you specified doesn't exist.")
    else
      if user_id == self.in_reply_to
        errors.add(:base, "You can't reply to yourself.")
      else
        unless reply_to_user_name_correct?(user)
          errors.add(:base, "User ID doesn't match its name.")
        end
      end
    end
  end
  
  def reply_to_user_name_correct?(user)
    user_name = user.name.gsub(" ", "-")
    @reply_dest[1] + @reply_dest[2] == self.in_reply_to.to_s + "-" + user_name
  end

  private

    # アップロードされた画像のサイズをバリデーションする
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
