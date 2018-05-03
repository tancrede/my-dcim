require File.expand_path("../../test_helper", __FILE__)

class FramesControllerTest < ActionController::TestCase

  setup do
    sign_in users(:one)
    @frame = frames(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:frames)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create frame" do
    assert_difference('Frame.count') do
      post :create, params: {frame: { name: @frame.name, bay_id: 1 }}
    end

    assert_redirected_to frames_path
  end

  test "should get edit" do
    get :edit, params: {id: @frame}
    assert_response :success
  end

  test "should update frame" do
    patch :update, params: {id: @frame, frame: { name: @frame.name }}
    assert_redirected_to room_path(@frame.room)
  end

  test "should destroy frame" do
    assert_difference('Frame.count', -1) do
      delete :destroy, params: {id: @frame}
    end

    assert_redirected_to frames_path
  end
end
