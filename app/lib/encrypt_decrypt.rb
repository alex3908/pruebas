# frozen_string_literal: true

require "openssl"
require "base64"

class EncryptDecrypt
  ALGORITHM = "aes-256-cfb"

  def self.encrypt(plain_text, key)
    cipher = OpenSSL::Cipher.new(ALGORITHM).encrypt
    cipher.key = key[0..31]
    s = cipher.update(plain_text) + cipher.final

    s.unpack("H*")[0].upcase
  end

  def self.decrypt(cipher_text, key)
    cipher = OpenSSL::Cipher.new(ALGORITHM).decrypt
    cipher.key = key[0..31]
    s = [cipher_text].pack("H*").unpack("C*").pack("c*")

    cipher.update(s) + cipher.final
  end
end
