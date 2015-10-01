defmodule EchoServer do
  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(
      port,
      [:binary, packet: :line, active: false, reuseaddr: true]
    )
    IO.puts "Accepting connections on port #{port}"
    loop_acceptor(socket, 0)
  end

  defp loop_acceptor(socket, num_cons) do
    {:ok, client} = :gen_tcp.accept(socket)
    IO.puts "client connected. number of connections #{num_cons + 1}"
    spawn_link fn -> serve(client) end
    loop_acceptor(socket, num_cons + 1)
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
