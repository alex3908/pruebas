# frozen_string_literal: true

class CommentsController < ApplicationController
  include FoldersHelper
  before_action :set_folder

  def create
    @comment = Comment.new(comments_params)
    @comment.folder = @folder
    @comment.user = current_user
    @comment.save

    respond_to do |format|
      format.js { render :create }
    end
  end

  private

    def comments_params
      params.require(:comment).permit(:message, :folder_id)
    end

    def set_folder
      @folder = Folder.find(params[:folder_id])
      @step_role = @folder&.step&.step_roles&.find_by(role: current_user.role)
    end
end
