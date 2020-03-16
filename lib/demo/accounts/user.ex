defmodule Demo.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :encrypted_password, :string
    field :confirmed_at, :naive_datetime

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both e-mail and password.
  Otherwise databases may truncate them without warnings, which could
  lead to unpredictable or insecure behaviour. Long passwords may also
  be very expensive to encrypt.
  """
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, "@")
    |> validate_length(:email, max: 160)
    |> validate_length(:password, min: 12, max: 80)
    |> unsafe_validate_unique(:email, Demo.Repo)
    |> maybe_encrypt_password()
    |> unique_constraint(:email)
  end

  defp maybe_encrypt_password(changeset) do
    password = get_change(changeset, :password)

    if password && changeset.valid? do
      put_change(changeset, :encrypted_password, Bcrypt.hash_pwd_salt(password))
    else
      changeset
    end
  end

  @doc """
  Verifies the password.

  Returns the given user if valid, 

  If there is no user or the user doesn't have a password,
  we encrypt a blank password to avoid timing attacks.
  """
  def valid_password?(%Demo.Accounts.User{encrypted_password: encrypted_password}, password)
      when is_binary(encrypted_password) do
    Bcrypt.verify_pass(password, encrypted_password)
  end

  def valid_password?(_) do
    Bcrypt.hash_pwd_salt("unused hash to avoid timing attacks")
    false
  end
end
