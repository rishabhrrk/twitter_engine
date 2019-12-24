# Spwan the server process
spawn fn -> TwitterEngine.Server.CLI.main() end

# Wait for the server to start and start the client handler process
:timer.sleep(1000)
TwitterEngine.Client.CLI.main()
