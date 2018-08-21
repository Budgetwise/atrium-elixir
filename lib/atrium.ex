defmodule Atrium do
  def api_key, do: Application.get_env(:atrium, :api_key, "")

  def client_id, do: Application.get_env(:atrium, :client_id, "")

  def base_url, do: Application.get_env(:atrium, :base_url, "https://vestibule.mx.com")

  # Required Parameters: None
  # Optional Parameters: identifier, is_disabled, metadata
  def create_user(options \\ []) do
    body = Poison.encode!(%{user: Enum.into(options, %{})})

    response = make_request("POST", "/users", body)
    get_field(response, "user")
  end

  # Required Parameters: user_guid
  # Optional Parameters: None
  def read_user(user_guid) do
    response = make_request("GET", "/users/" <> user_guid, "")
    get_field(response, "user")
  end

  # Required Parameters: None
  # Optional Parameters: user_guid, identifier, is_disabled, metadata
  def update_user(user_guid, options \\ []) do
    body = Poison.encode!(%{user: Enum.into(options, %{})})

    response = make_request("PUT", "/users/" <> user_guid, body)
    get_field(response, "user")
  end

  # Required Parameters: None
  # Optional Parameters: page, records_per_page
  def list_users(options \\ []) do
    params = optional_parameters(options)

    response = make_request("GET", "/users" <> params, "")
    get_field(response, "users")
  end

  def delete_user(user_guid) do
    make_request("DELETE", "/users/" <> user_guid, "")
  end

  # INSTITUTION

  # Required Parameters: None
  # Optional Parameters: name, page, records_per_page
  def list_institutions(options \\ []) do
    params = optional_parameters(options)

    response = make_request("GET", "/institutions" <> params, "")
    get_field(response, "institutions")
  end

  # Required Parameters: institution_code
  # Optional Parameters: None
  def read_institution(institution_code) do
    response = make_request("GET", "/institutions/" <> institution_code, "")
    get_field(response, "institution")
  end

  # Required Parameters: institution_code
  # Optional Parameters: page, records_per_page
  def read_institution_credentials(institution_code, options \\ []) do
    params = optional_parameters(options)

    response =
      make_request("GET", "/institutions/" <> institution_code <> "/credentials" <> params, "")

    get_field(response, "credentials")
  end

  # MEMBER

  # Required Parameters: user_guid, credentials, institution_code
  # Optional Parameters: identifier, metadata
  def create_member(user_guid, credentials, institution_code, options \\ []) do
    data =
      options
      |> Enum.filter(fn {_k, v} -> not is_nil(v) end)
      |> Enum.into(%{})
      |> Map.put(:insitution_code, institution_code)
      |> Map.put(:credentials, credentials)

    body = Poison.encode!(%{member: data})

    response = make_request("POST", "/users/" <> user_guid <> "/members", body)
    get_field(response, "member")
  end

  # Required Parameters: user_guid, member_guid
  # Optional Parameters: None
  def read_member(user_guid, member_guid) do
    response = make_request("GET", "/users/" <> user_guid <> "/members/" <> member_guid, "")
    get_field(response, "member")
  end

  # Required Parameters: user_guid, member_guid
  # Optional Parameters: credentials, identifier, metadata
  def update_member(user_guid, member_guid, options \\ []) do
    data =
      options
      |> Enum.filter(fn {_k, v} -> not is_nil(v) end)
      |> Enum.into(%{})

    body = Poison.encode!(%{member: data})

    response = make_request("PUT", "/users/" <> user_guid <> "/members/" <> member_guid, body)
    get_field(response, "member")
  end

  # Required Parameters: user_guid, member_guid
  # Optional Parameters: None
  def delete_member(user_guid, member_guid) do
    make_request("DELETE", "/users/" <> user_guid <> "/members/" <> member_guid, "")
  end

  # Required Parameters: user_guid
  # Optional Parameters: page, records_per_page
  def list_members(user_guid, options \\ []) do
    params = optional_parameters(options)

    response = make_request("GET", "/users/" <> user_guid <> "/members" <> params, "")
    get_field(response, "members")
  end

  # Required Parameters: user_guid, member_guid
  # Optional Parameters: None
  def aggregate_member(user_guid, member_guid) do
    response =
      make_request(
        "POST",
        "/users/" <> user_guid <> "/members/" <> member_guid <> "/aggregate",
        ""
      )

    get_field(response, "member")
  end

  # Required Parameters:  user_guid, member_guid
  # Optional Parameters: None
  def read_member_aggregation_status(user_guid, member_guid) do
    response =
      make_request("GET", "/users/" <> user_guid <> "/members/" <> member_guid <> "/status", "")

    get_field(response, "member")
  end

  # Required Parameters: user_guid, member_guid
  # Optional Parameters: page, records_per_page
  def list_member_mfa_challenges(user_guid, member_guid, options \\ []) do
    params = optional_parameters(options)

    response =
      make_request(
        "GET",
        "/users/" <> user_guid <> "/members/" <> member_guid <> "/challenges" <> params,
        ""
      )

    get_field(response, "challenges")
  end

  # Required Parameters: user_guid, member_guid, answersMFA
  # Optional Parameters: None
  def resume_member_aggregate(user_guid, member_guid, answers) do
    data = %{member: %{challenges: answers}}
    body = Poison.encode!(data)

    response =
      make_request("PUT", "/users/" <> user_guid <> "/members/" <> member_guid <> "/resume", body)

    get_field(response, "member")
  end

  # Required Parameters: user_guid, member_guid
  # Optional Parameters: page, records_per_page
  def list_member_credentials(user_guid, member_guid, options \\ []) do
    params = optional_parameters(options)

    response =
      make_request(
        "GET",
        "/users/" <> user_guid <> "/members/" <> member_guid <> "/credentials" <> params,
        ""
      )

    get_field(response, "credentials")
  end

  # Required Parameters: user_guid, member_guid
  # Optional Parameters: page, records_per_page
  def list_member_accounts(user_guid, member_guid, options \\ []) do
    params = optional_parameters(options)

    response =
      make_request(
        "GET",
        "/users/" <> user_guid <> "/members/" <> member_guid <> "/accounts" <> params,
        ""
      )

    get_field(response, "accounts")
  end

  # Required Parameters: user_guid, member_guid
  # Optional Parameters: from_date, to_date, page, records_per_page
  def list_member_transactions(user_guid, member_guid, options \\ []) do
    params = optional_parameters(options)

    response =
      make_request(
        "GET",
        "/users/" <> user_guid <> "/members/" <> member_guid <> "/transactions" <> params,
        ""
      )

    get_field(response, "transactions")
  end

  # Required Parameters: user_guid, member_guid
  # Optional Parameters: None
  def verify_member(user_guid, member_guid) do
    response =
      make_request(
        "POST",
        "/users/" <> user_guid <> "/members/" <> member_guid <> "/verify",
        ""
      )

    get_field(response, "member")
  end

  # Required Parameters: user_guid, member_guid
  # Optional Parameters: None
  def identify_member(user_guid, member_guid) do
    response =
      make_request(
        "POST",
        "/users/" <> user_guid <> "/members/" <> member_guid <> "/identify",
        ""
      )

    get_field(response, "member")
  end

  # ACCOUNT

  # Required Parameters: user_guid, account_guid
  # Optional Parameters: None
  def read_account(user_guid, account_guid) do
    response = make_request("GET", "/users/" <> user_guid <> "/accounts/" <> account_guid, "")
    get_field(response, "account")
  end

  # Required Parameters: user_guid
  # Optional Parameters: page, records_per_page
  def list_accounts(user_guid, options \\ []) do
    params = optional_parameters(options)

    response = make_request("GET", "/users/" <> user_guid <> "/accounts" <> params, "")
    get_field(response, "accounts")
  end

  # Required Parameters: user_guid, account_guid
  # Optional Parameters: from_date, to_date, page, records_per_page
  def list_account_transactions(user_guid, account_guid, options \\ []) do
    params = optional_parameters(options)

    response =
      make_request(
        "GET",
        "/users/" <> user_guid <> "/accounts/" <> account_guid <> "/transactions" <> params,
        ""
      )

    get_field(response, "transactions")
  end

  # ACCOUNT NUMBER

  # Required Parameters: user_guid, account_guid
  # Optional Parameters: None
  def list_account_account_numbers(user_guid, account_guid) do
    response =
      make_request(
        "GET",
        "/users/" <> user_guid <> "/accounts/" <> account_guid <> "/account_numbers",
        ""
      )

    get_field(response, "account_numbers")
  end

  # Required Parameters: user_guid, member_guid
  # Optional Parameters: None
  def list_member_account_numbers(user_guid, member_guid) do
    response =
      make_request(
        "GET",
        "/users/" <> user_guid <> "/members/" <> member_guid <> "/account_numbers",
        ""
      )

    get_field(response, "account_numbers")
  end

  # ACCOUNT OWNER

  # Required Parameters: user_guid, member_guid
  # Optional Parameters: None
  def list_member_account_owners(user_guid, member_guid) do
    response =
      make_request(
        "GET",
        "/users/" <> user_guid <> "/members/" <> member_guid <> "/account_owners",
        ""
      )

    get_field(response, "account_owners")
  end

  # TRANSACTION

  # Required Parameters: user_guid, transaction_guid
  # Optional Parameters: None
  def read_transaction(user_guid, transaction_guid) do
    response =
      make_request("GET", "/users/" <> user_guid <> "/transactions/" <> transaction_guid, "")

    get_field(response, "transaction")
  end

  # Required Parameters: user_guid
  # Optional Parameters: from_date, to_date, page, records_per_page
  def list_transactions(user_guid, options \\ []) do
    params = optional_parameters(options)

    response = make_request("GET", "/users/" <> user_guid <> "/transactions" <> params, "")
    get_field(response, "transactions")
  end

  # CONNECT WIDGET

  # Required Parameters: user_guid
  # Optional Parameters: None
  def create_widget(user_guid) do
    response = make_request("POST", "/users/" <> user_guid <> "/connect_widget_url", "")
    get_field(response, "user")
  end

  # CLIENT

  defp get_field({:ok, response}, field) do
    {:ok, parsed_json} = Poison.decode(to_string(response))
    {:ok, parsed_json[field]}
  end
  defp get_field(error, _), do: error

  # Required Parameters: mode, endpoint, body
  # Optional Parameters: None
  defp make_request(mode, endpoint, body) do
    Application.get_env(:atrium_ex, :api_key)
    url = base_url() <> endpoint

    headers = [
      {"Accept", "application/vnd.mx.atrium.v1<>json"},
      {"Content-Type", "application/json"},
      {"MX-API-Key", api_key()},
      {"MX-Client-ID", client_id()}
    ]

    make_request(mode, url, body, headers)
  end

  defp make_request("GET", url, _body, headers) do
    case HTTPoison.get(url, headers, timeout: 50_000, recv_timeout: 50_000) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} -> http_error(code, body)
      other -> other
    end
  end

  defp make_request("POST", url, body, headers) do
    case HTTPoison.post(url, body, headers, timeout: 50_000, recv_timeout: 50_000) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} -> http_error(code, body)
      other -> other
    end
  end

  defp make_request("PUT", url, body, headers) do
    case HTTPoison.put(url, body, headers, timeout: 50_000, recv_timeout: 50_000) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} -> http_error(code, body)
      other -> other
    end
  end

  defp make_request("DELETE", url, _body, headers) do
    case HTTPoison.delete(url, headers, timeout: 50_000, recv_timeout: 50_000) do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} -> http_error(code, body)
      other -> other
    end
  end

  defp http_error(status_code, body) do
    case print_error(status_code) do
      nil -> {:ok, body}
      error -> {:error, error}
    end
  end

  # Print on http error
  defp print_error(400), do: "400 error: Required parameter is missing."
  defp print_error(401), do: "401 error: Invalid MX-API-Key, MX-Client-ID, or being used in wrong environment."
  defp print_error(403), do: "403 error: Requests must be HTTPS."
  defp print_error(404), do: "404 error: GUID / URL path not recognized."
  defp print_error(405), do: "405 error: Endpoint constraint not met."
  defp print_error(406), do: "406 error: Specifiy valid API version."
  defp print_error(409), do: "409 error: Object already exists."
  defp print_error(422), do: "422 error: Data provided cannot be processed."
  defp print_error(status_code) when status_code in [500, 502, 504], do: "#{status_code} error: An unexpected error occurred on MX's systems."
  defp print_error(503), do: "503 error: Please try again later. The MX Platform is currently being updated."
  defp print_error(_status_code), do: nil

  defp optional_parameters(opts) do
    opts
    |> Enum.filter(fn {k, v} ->
      not is_nil(v) and v != "" and k in [:name, :from_date, :to_date, :page, :records_per_page]
    end)
    |> Enum.reduce("?", fn {k, v}, acc -> "#{acc}#{k}=#{v}&" end)
    |> String.slice(0..-2)
  end
end
