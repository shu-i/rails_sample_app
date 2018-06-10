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
  
  # フォロワー増加、または減少時のメール通信機能のテスト
  test "should send follow/unfollow notification email" do
    log_in_as(@user)
    notify = users(:archer)
    post relationships_path, params: {followed_id: notify.id}
    relationship = @user.active_relationships.find_by(followed_id: notify.id)
    delete relationship_path(relationship)
    assert_equal 2, ActionMailer::Base.deliveries.size
  end

  test "should not send follow/unfollow notification email" do
    log_in_as(@other)
    not_notify = users(:malory)
    post relationships_path, params: {followed_id: not_notify.id}
    relationship = @other.active_relationships.find_by(followed_id: not_notify.id)
    delete relationship_path(relationship)
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

end
