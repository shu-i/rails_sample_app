require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    # 無効な送信
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    # 有効な送信
    content = "This micropost really ties the room together"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # 投稿を削除する
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # 違うユーザーのプロフィールにアクセス (削除リンクがないことを確認)
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end
  
  test "reply to other user" do
    log_in_as(@user)
    get root_path

    # 無効な返信ポスト（ID違い）
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {micropost: {content: "@9999-"}}
    end
    assert_select 'div#error_explanation'
    # 無効な返信ポスト（自分に返信は拒否）
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {micropost: {content: "@#{@user.id}-Michael-Example"}}
    end
    assert_select 'div#error_explanation'
    # 無効な返信ポスト（IDとネームはマッチしない）
    other_user = users(:archer)
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {micropost: {content: "@#{other_user.id}-Sterling-Archerxx"}}
    end
    assert_select 'div#error_explanation'

    # 有効な返信ポスト
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: {micropost: {content: "@#{other_user.id}-Sterling-Archer"}}
    end
  end
  
  test "reply post visibility" do
    log_in_as(@user)
    get root_path
    reply_to_user = users(:archer)
    content = "@#{reply_to_user.id}-Sterling-Archer"
    post microposts_path, params: {micropost: {content: content}}
    # 自分のフィールドに表示
    follow_redirect!
    assert_match content, response.body

    # 返信先のフィールドに表示
    log_in_as(reply_to_user)
    get root_path
    assert_match content, response.body

    # 返信先以外のフィールドに表示しない
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_no_match content, response.body
  end
end
