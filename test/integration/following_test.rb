require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other = users(:archer)
    log_in_as(@user)
  end

  test "following page" do
    get following_user_path(@user)
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end
  
  test "should follow a user the standard way" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { followed_id: @other.id }
    end
  end

  test "should follow a user with Ajax" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, xhr: true, params: { followed_id: @other.id }
    end
  end

  test "should unfollow a user the standard way" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "should unfollow a user with Ajax" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship), xhr: true
    end
  end
  
  test "should send follow notification email" do
    notify = users(:michael)
    post relationships_path, params: {followed_id: notify.id}
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test "should not send follow notification email" do
    not_notify = users(:malory)
    post relationships_path, params: {followed_id: not_notify.id}
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test "should send unfollow notification email" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    delete relationship_path(relationship)
    assert_equal 2, ActionMailer::Base.deliveries.size # follow email and unfollow email
  end

  test "should not send unfollow notification email" do
    not_notify = users(:malory)
    # @user.follow(not_notify)
    relationship = @user.active_relationships.find_by(followed_id: not_notify.id)
    delete relationship_path(relationship)
    assert_equal 0, ActionMailer::Base.deliveries.size
  end
end
