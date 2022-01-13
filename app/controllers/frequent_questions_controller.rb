# frozen_string_literal: true

class FrequentQuestionsController < ApplicationController
  load_and_authorize_resource
  def index
    @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
    @frequent_questions = FrequentQuestion.all.order(created_at: :asc).paginate(page: params[:page], per_page: @per_page)
  end

  def show
  end

  def new
    @frequent_question = FrequentQuestion.new
  end

  def edit
  end

  def create
    @frequent_question = FrequentQuestion.new(frequent_question_params)
    @frequent_question.user = current_user
    respond_to do |format|
      if @frequent_question.save
        format.html { redirect_to @frequent_question, notice: "Pregunta frecuente creada correctamente." }
        format.json { render :show, status: :created, location: @frequent_question }
      else
        format.html { render :new }
        format.json { render json: @frequent_question.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @frequent_question.user = current_user
    respond_to do |format|
      if @frequent_question.update(frequent_question_params)
        format.html { redirect_to @frequent_question, notice: "Pregunta frecuente editada correctamente." }
        format.json { render :show, status: :ok, location: @frequent_question }
      else
        format.html { render :edit }
        format.json { render json: @frequent_question.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @frequent_question.destroy
    respond_to do |format|
      format.html { redirect_to frequent_questions_url, notice: "Pregunta frecuente eliminada correctamente." }
      format.json { head :no_content }
    end
  end

  def change_status
    if @frequent_question.released?
      @frequent_question.update(status: :hold)
    else
      @frequent_question.update(status: :released)
    end
    redirect_to frequent_questions_path, notice: "Pregunta frecuente actualizada correctamente"
  end

  private
    def set_frequent_question
      @frequent_question = FrequentQuestion.find(params[:id])
    end

    def frequent_question_params
      params.require(:frequent_question).permit(:title, :content, :link)
    end
end
