# frozen_string_literal: true

class API::V1::SalesmenController < API::V1::BaseController
  before_action :load_resource

  # GET
  def index
    json_response(@salesmen, :ok)
  end

  # GET
  def show
    role = Role.where(key: "salesman").first
    User.where(role_id: role.id).find(params[:id])
    json_response(@salesman, :ok)
  end

  # POST
  def create
  end

  # PATCH/PUT
  def update
    if @salesman.update(update_params)
      json_response(@salesman, :ok)
    else
      json_error_response(@salesman.errors, :unprocessable_entity)
    end
  end

  # DELETE
  def destroy
  end


    private

      # Function for load the requested resources
      def load_resource
        case params[:action].to_sym
        when :index
          @salesmen = User.can_reserve
        when :show, :update
          @salesman = User.find(params[:id])
        end
      end

      # Return the User params from Request body
      def create_params
        params.require(:salesman).permit(:email, :first_name, :last_name, :phone, :role)
      end

      # Function for get Request params
      def update_params
        params.require(:salesman).permit(:rid)
      end

      # Function for get filter params
      def filter_params
        params.slice(*User.search_scopes)
      end
end
