require 'test_helper'

class PageControllerTest < ActionDispatch::IntegrationTest
  test "should get top" do
    get page_top_url
    assert_response :success
  end

end
