# Preview all emails at http://localhost:3000/rails/mailers/relationship_mailer
class RelationshipMailerPreview < ActionMailer::Preview
  def follow_notification
    user = User.first
    follower = User.second
    RelationshipMailer.follow_notification(user, follower)
  end

  def unfollow_notification
    user = User.first
    follower = User.second
    RelationshipMailer.unfollow_notification(user, follower)
  end
end
