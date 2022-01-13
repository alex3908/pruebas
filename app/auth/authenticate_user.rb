# frozen_string_literal: true

##
# class for handle the user authentication. Create token for valid user. Throw exception if authentication fails

class AuthenticateUser
  ##
  # AuthenticateUser class receive two params

  def initialize(email, password)
    @email = email
    @password = password
  end

  # Function for generate JWT Token if the user retrieve from user() is valid

  def call
    {
        token: JsonWebToken.encode(
          user_id: user.id,
          first_name: user.first_name,
          last_name: user.last_name,
          phone: user.phone,
          role: user.role.key,
        ),
        user: user
    } if user
  end

  private

    # Attributes that can be read only
    attr_reader :email, :password

    # Returns the user if exist and password is valid
    # Function for get the user using Email, check the password for validate authentication and return the user

    def user
      user = User.find_by_email(email)
      return user if user && user.valid_password?(password)
      # raise Authentication error if credentials are invalid
      raise(ExceptionHandler::AuthenticationError, Message.invalid_credentials)
    end
end
