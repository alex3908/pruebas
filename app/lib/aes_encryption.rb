# frozen_string_literal: true

class AesEncryption
  attr_accessor :key_iterations, :base64

  def initialize(mode = "CBC", size = 128)
    @modes = { "CBC" => "AES-%d-CBC", "CFB" => "AES-%d-CFB8" }
    @sizes = [128, 192, 256]
    @iv_len = 16
    @key_len = 16

    raise ArgumentError, mode + " is not supported!" unless @modes.has_key?(mode.upcase)
    raise ArgumentError, "Invalid key size!" unless @sizes.include? size

    @mode = mode.upcase
    @base64 = true
  end

  def encrypt(data, password = nil)
    aes_key = [password].pack("H*")
    iv = random_bytes(@iv_len)
    aes = cipher(aes_key, iv, true)
    ciphertext = aes.update(data) + aes.final
    Base64.encode64(iv + ciphertext)
  rescue TypeError, ArgumentError => e
    error_handler e
  end

  def decrypt(data, password = nil)
    aes_key = [password].pack("H*")
    data = Base64.decode64(data) if @base64
    iv = data[0..@iv_len - 1]
    ciphertext = data[@iv_len..-1]
    aes = cipher(aes_key, iv, false)
    aes.update(ciphertext) + aes.final
  rescue TypeError, ArgumentError, NoMethodError => e
    error_handler e
  rescue OpenSSL::OpenSSLError => e
    error_handler e
  end

  protected

    def error_handler(exception)
      puts exception
    end

  private

    def cipher(key, iv, encrypt = true)
      mode = @modes[@mode] % (@key_len * 8)
      cipher = OpenSSL::Cipher.new(mode)
      encrypt ? cipher.encrypt : cipher.decrypt
      cipher.key = key
      cipher.iv = iv
      cipher
    end

    def random_bytes(size)
      OpenSSL::Random.random_bytes size
    end
end
