# Redmine - project management software
# Copyright (C) 2006-2009  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require File.dirname(__FILE__) + '/../test_helper'
require 'boards_controller'

# Re-raise errors caught by the controller.
class BoardsController; def rescue_action(e) raise e end; end

class BoardsControllerTest < Test::Unit::TestCase
  fixtures :projects, :users, :members, :roles, :boards, :messages, :enabled_modules
  
  def setup
    @controller = BoardsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end
  
  def test_index_routing
    assert_routing(
      {:method => :get, :path => '/projects/world_domination/boards'},
      :controller => 'boards', :action => 'index', :project_id => 'world_domination'
    )
  end
  
  def test_index
    get :index, :project_id => 1
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:boards)
    assert_not_nil assigns(:project)
  end
  
  def test_index_not_found
    get :index, :project_id => 97
    assert_response 404
  end
  
  def test_index_should_show_messages_if_only_one_board
    Project.find(1).boards.slice(1..-1).each(&:destroy)
    
    get :index, :project_id => 1
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:topics)
  end
  
  def test_new_routing
    assert_routing(
      {:method => :get, :path => '/projects/world_domination/boards/new'},
      :controller => 'boards', :action => 'new', :project_id => 'world_domination'
    )
    assert_recognizes(
      {:controller => 'boards', :action => 'new', :project_id => 'world_domination'},
      {:method => :post, :path => '/projects/world_domination/boards'}
    )
  end
  
  def test_post_new
    @request.session[:user_id] = 2
    assert_difference 'Board.count' do
      post :new, :project_id => 1, :board => { :name => 'Testing', :description => 'Testing board creation'}
    end
    assert_redirected_to '/projects/ecookbook/settings/boards'
  end
  
  def test_show_routing
    assert_routing(
      {:method => :get, :path => '/projects/world_domination/boards/44'},
      :controller => 'boards', :action => 'show', :id => '44', :project_id => 'world_domination'
    )
    assert_routing(
      {:method => :get, :path => '/projects/world_domination/boards/44.atom'},
      :controller => 'boards', :action => 'show', :id => '44', :project_id => 'world_domination', :format => 'atom'
    )
  end
  
  def test_show
    get :show, :project_id => 1, :id => 1
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:board)
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:topics)
  end
  
  def test_show_atom
    get :show, :project_id => 1, :id => 1, :format => 'atom'
    assert_response :success
    assert_template 'common/feed.atom'
    assert_not_nil assigns(:board)
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:messages)
  end
  
  def test_edit_routing
    assert_routing(
      {:method => :get, :path => '/projects/world_domination/boards/44/edit'},
      :controller => 'boards', :action => 'edit', :id => '44', :project_id => 'world_domination'
    )
    assert_recognizes(#TODO: use PUT method to board_path, modify form accordingly
      {:controller => 'boards', :action => 'edit', :id => '44', :project_id => 'world_domination'},
      {:method => :post, :path => '/projects/world_domination/boards/44/edit'}
    )
  end
  
  def test_post_edit
    @request.session[:user_id] = 2
    assert_no_difference 'Board.count' do
      post :edit, :project_id => 1, :id => 2, :board => { :name => 'Testing', :description => 'Testing board update'}
    end
    assert_redirected_to '/projects/ecookbook/settings/boards'
    assert_equal 'Testing', Board.find(2).name
  end
  
  def test_destroy_routing
    assert_routing(#TODO: use DELETE method to board_path, modify form accoringly
      {:method => :post, :path => '/projects/world_domination/boards/44/destroy'},
      :controller => 'boards', :action => 'destroy', :id => '44', :project_id => 'world_domination'
    )
  end
  
  def test_post_destroy
    @request.session[:user_id] = 2
    assert_difference 'Board.count', -1 do
      post :destroy, :project_id => 1, :id => 2
    end
    assert_redirected_to '/projects/ecookbook/settings/boards'
    assert_nil Board.find_by_id(2)
  end
end
