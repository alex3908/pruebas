# frozen_string_literal: true

class BranchesController < ApplicationController
  load_and_authorize_resource

  # GET /branches
  def index
    @branches = @branches.order(created_at: :desc).paginate(page: params[:page], per_page: @per_page)
  end

  # GET /branches/1
  def show
  end

  # GET /branches/new
  def new
  end

  # GET /branches/1/edit
  def edit
  end

  # POST /branches
  def create
    if @branch.save
      redirect_to @branch, flash: { success: "Sucursal creada correctamente." }
    else
      render :new
    end
  end

  # PATCH/PUT /branches/1
  def update
    if @branch.update(branch_params)
      redirect_to @branch, flash: { success: "Sucursal editada correctamente." }
    else
      render :edit
    end
  end

  # DELETE /branches/1
  def destroy
    @branch.destroy
    redirect_to branches_path, flash: { success: "Sucursal eliminada correctamente." }
  end

  def change_status
    if @branch.active
      @branch.toggle!(:active)
      status = { success: "La sucursal #{@branch.name} está oculta en los PDFs." }
    else
      @branches = Branch.where(active: true).count
      if @branches < 9
        @branch.toggle!(:active)
        status = { success: "La sucursal #{@branch.name} aparecerá en los PDFs." }
      else
        status = { error: "Has alcanzado el máximo de sucursales activas en los PDFs." }
      end
    end

    redirect_to branches_path, flash: status
  end

  private

    def branch_params
      params.require(:branch).permit(:rid, :name, :address, :phone)
    end
end
