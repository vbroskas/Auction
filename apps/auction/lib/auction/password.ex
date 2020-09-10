defmodule Auction.Password do
  import Pbkdf2

  def hash(password) do
    hash_pwd_salt(password)
  end

  def verify_with_hash(password, hashed_password) do
    verify_pass(password, hashed_password)
  end

  def dummy_verify() do
    no_user_verify()
  end
end
