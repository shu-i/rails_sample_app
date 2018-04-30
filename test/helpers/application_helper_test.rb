require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  
  base_title = "Ruby on Rails Tutorial Sample App" 
  
  test "full title helper" do
    assert_equal full_title,         base_title
    assert_equal full_title("Help"), "Help | " + base_title
  end
end