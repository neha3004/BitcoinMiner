Distributed Operating Systems Project 1

==========================================================


Team members:
Neha Komuravelly –  6172-2613 (komuravelly.neha@ufl.edu)
Sripriya Simhadri – 3067-1426 (simhadrisripriya@ufl.edu)


Project guidebook:
1. DOSPProject.zip
   1. Server
I. mineServer.erl
   2. Worker
II. mineWorker.erl
   2. ReadMe.md
Brief Description:
The idea of this project is to implement distributed systems to optimize monolithic tasks. In this instance we are trying to find bitcoins with a particular number of leading zeroes. Actor model concept which is inherent in erlang language has been leveraged to use workers spawns across multiple systems and cores to implement distributed computing.
Execution Steps:
   1. In server machine, navigate to Server directory and set the server IP as follows:
  		erl -name server@<IPv4 address>

   2. Repeat the same on the worker node as follows:
  		erl -name worker@<IPv4 address>

   3. Set cookies on both machines to establish connection:
  		erlang:set_cookie(‘<cookie name>’).

   4. Start the server and give the required number of leading zeroes:
		mineServer:start_server().
  
   5. Start the worker on the other node as follows:
		mineWorker:start_worker(‘server@<IPv4 address of the server>’, <number of spawns to be generated initially>).

  
Design:
      1. Server receives the required number of leading zeroes from the client as a command line input. 
      2. Server waits for the worker(s) to ping that it is available and ready to start computation.
      3. The worker communicates that it is ready and gets a request from the server to mine bitcoins.
      4. The worker then creates multiple spawns that concurrently create random strings and prepend the author’s credentials.
      5. The worker then creates a hash out of the generated strings using sha256 key based encryption.
      6. Worker then filters the hashes that have the required number of leading zeroes provided as the input.
      7. The filtered hashes and corresponding bitcoins are sent back to the server which then prints the output as they come.

Systems uses:
      1. Apple M1 - 8 cores
      2. Surface Pro 4 - 8 cores
