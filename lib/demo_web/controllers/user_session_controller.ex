defmodule DemoWeb.UserSessionController do
  use DemoWeb, :controller

  alias Demo.Accounts
  alias DemoWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.login_user(conn, user)
    else
      render(conn, "new.html", error_message: "Invalid e-mail or password")
    end
  end

  # On logout we clear all session data for safety.
  # If you want to keep some data in the session, you can
  # explicitly delete the user_id, but do so carefully.
  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> clear_session()
    |> configure_session(renew: true)
    |> redirect(to: "/")
  end
end
