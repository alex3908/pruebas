# frozen_string_literal: true

require "openssl"
require "base64"

class AesEncryptDecrypt
  KEY = Rails.application.secrets.api_key_base
  ALGORITHM = "aes-256-cbc"

  def self.encryption(msg)
    cipher = OpenSSL::Cipher.new(ALGORITHM)
    cipher.encrypt()
    cipher.key = KEY
    crypt = cipher.update(msg) + cipher.final()
    crypt_string = (Base64.encode64(crypt))
    crypt_string
  rescue Exception => exc
    puts ("Message for the encryption log file for message #{msg} = #{exc.message}")
  end

  def self.decryption(msg)
    cipher = OpenSSL::Cipher.new(ALGORITHM)
    cipher.decrypt()
    cipher.key = KEY
    tempkey = Base64.decode64(msg)
    tempkey
  rescue Exception => exc
    puts ("Message for the decryption log file for message #{msg} = #{exc.message}")
  end
end
