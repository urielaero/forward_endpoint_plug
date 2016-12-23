defmodule ForwardEndpointPlug do
  import Plug.Conn
  
  def init(opts), do: opts

  def call(conn, path: path, endpoint: endpoint) do
    path = "/#{path}"
    if String.starts_with? conn.request_path, path do
      conn
        |> assign(:mount_path, path)
        |> forward([], endpoint, [])
        |> halt
    else
      conn
    end
  end

  def call(conn, _opts) do
    conn
  end

  # extract from https://github.com/phoenixframework/phoenix/blob/master/lib/phoenix/router/route.ex#L151
  defp forward(%Plug.Conn{path_info: path, script_name: script} = conn, fwd_segments, target, opts) do
    new_path = path -- fwd_segments
    {base, ^new_path} = Enum.split(path, length(path) - length(new_path))
    conn = %{conn | path_info: new_path, script_name: script ++ base} |> target.call(opts)
    %{conn | path_info: path, script_name: script}
  end
end
