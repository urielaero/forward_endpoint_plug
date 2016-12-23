defmodule ForwardEndpointPlugTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest ForwardEndpointPlug


  @path :another_endpoint 
  @opts ForwardEndpointPlug.init(path: @path, endpoint: ForwardEndpointPlugTest)
  @route "/#{@path}"

  def call(conn, _opts) do
    send self, {:call_route, conn.assigns[:mount_path], conn.path_info}
    conn
  end

  setup do
    conn_route = conn(:get, "#{@route}/hello")
    conn = conn(:get, "/hello")
    {:ok, conn_route: conn_route, conn: conn}
  end

  test "halted current conn if path match", %{conn_route: conn} do
    conn = ForwardEndpointPlug.call(conn, @opts)
    assert conn.halted
  end

  test "ignore conn if not path match", %{conn: conn} do
    conn = ForwardEndpointPlug.call(conn, @opts)
    refute conn.halted
  end

  test "invoke the endpoint.call if path match", %{conn_route: conn} do
    ForwardEndpointPlug.call(conn, @opts)
    assert_receive {:call_route, @route, ["another_endpoint", "hello"]}
  end

  test "do not call endpoint.call if not path match", %{conn: conn} do
    ForwardEndpointPlug.call(conn, @opts)
    refute_receive {:call_route, @route}
  end
end
