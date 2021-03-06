defmodule BlockScoutWeb.API.RPC.TokenControllerTest do
  use BlockScoutWeb.ConnCase

  describe "gettoken" do
    test "with missing contract address", %{conn: conn} do
      params = %{
        "module" => "token",
        "action" => "getToken"
      }

      assert response =
               conn
               |> get("/api", params)
               |> json_response(200)

      assert response["message"] =~ "contractaddress is required"
      assert response["status"] == "0"
      assert Map.has_key?(response, "result")
      refute response["result"]
    end

    test "with an invalid contractaddress hash", %{conn: conn} do
      params = %{
        "module" => "token",
        "action" => "getToken",
        "contractaddress" => "badhash"
      }

      assert response =
               conn
               |> get("/api", params)
               |> json_response(200)

      assert response["message"] =~ "Invalid contractaddress hash"
      assert response["status"] == "0"
      assert Map.has_key?(response, "result")
      refute response["result"]
    end

    test "with a contractaddress that doesn't exist", %{conn: conn} do
      params = %{
        "module" => "token",
        "action" => "getToken",
        "contractaddress" => "0x8bf38d4764929064f2d4d3a56520a76ab3df415b"
      }

      assert response =
               conn
               |> get("/api", params)
               |> json_response(200)

      assert response["message"] =~ "contractaddress not found"
      assert response["status"] == "0"
      assert Map.has_key?(response, "result")
      refute response["result"]
    end

    test "response includes all required fields", %{conn: conn} do
      token = insert(:token)

      params = %{
        "module" => "token",
        "action" => "getToken",
        "contractaddress" => to_string(token.contract_address_hash)
      }

      expected_result = %{
        "name" => token.name,
        "symbol" => token.symbol,
        "totalSupply" => to_string(token.total_supply),
        "decimals" => to_string(token.decimals),
        "type" => token.type,
        "cataloged" => token.cataloged,
        "contractAddress" => to_string(token.contract_address_hash)
      }

      assert response =
               conn
               |> get("/api", params)
               |> json_response(200)

      assert response["result"] == expected_result
      assert response["status"] == "1"
      assert response["message"] == "OK"
    end
  end
end
