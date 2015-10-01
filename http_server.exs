defmodule HttpServer do
  def start(port) do
    {:ok, socket} = :gen_tcp.listen(
      port,
      [:binary, packet: :line, active: false, reuseaddr: true]
    )
    IO.puts "serving on port #{port}"
    loop_server(socket)
  end

  defp loop_server(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    spawn_link fn -> serve(client) end
    loop_server(socket)
  end

  defp serve(socket) do
    parse_request(socket)
    |> select_response
    |> send_response(socket)
  end

  defp send_response(response, socket) do
    :gen_tcp.send socket, response
    :gen_tcp.close socket
  end

  defp parse_request(socket) do
    { :ok, request } = :gen_tcp.recv socket, 0
    [method, path, protocol] = String.split(request, " ")
    {method, path, protocol}
  end

  defp select_response({ _method, path, _procol }) do
    IO.puts "serving content for path: #{ path }"
    path(path)
  end

  defp path("/") do
    """
    HTTP/1.0 200 OK

    Hello, world!
    """
  end

  defp path("/foo") do
    """
    HTTP/1.0 200 OK

    Foo page says hello.
    """
  end

  defp path("/bar") do
    """
    HTTP/1.0 200 OK

    Bar page says hello!
    """
  end

  defp path(_) do
    """
    HTTP/1.0 404 NOT FOUND

    Page not found.
    """
  end
end
