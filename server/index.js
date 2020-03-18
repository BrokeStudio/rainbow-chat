// import libraries
const http = require("http");
const WebSocket = require("ws");
const fs = require("fs");

// set some constants
const HEARTBEAT_INTERVAL = 2000; // 2 seconds
const WS_PORT = 3000;
const HTTP_PORT = 8000;
const HTTP_ADDRESS = "127.0.0.1";
const HEARTBEAT_ENABLED = false;

// init http server
let httpServer = http
  .createServer((request, response) => {
    // whatever the request is, we always serve index.html content
    response.writeHead(200, { "Content-type": "text/html" });
    // get index.html file content
    const indexHTML = fs.readFileSync("index.html", "utf-8");
    response.write(indexHTML);
    response.end();
  })
  // specify ip address to force ipv4, no address for ipv6
  .listen(HTTP_PORT, HTTP_ADDRESS, function() {
    console.log(
      `HTTP server listening, open your browser at http://${HTTP_ADDRESS}:${HTTP_PORT}`
    );
  });

// init websocket server
const wss = new WebSocket.Server(
  { server: httpServer, port: WS_PORT },
  function() {
    console.log(`WebSocket server listening on port ${this.address().port}`);
  }
);

// handle new connections
wss.on("connection", function(socket) {
  // log new connection
  console.log("new connection");

  // heartbeat init
  socket.isAlive = true;
  socket.on("pong", heartbeat);

  // broadcast received messages to every other clients
  socket.on("message", function(msg) {
    //console.log(msg);
    // convert buffer to array
    //data = msg.slice(0, 1); //[...msg];
    //console.log(data);

    // get first element in buffer
    let opcode = msg.readUInt8(0);
    let data = msg.slice(1);
    let text = ab2str(msg.slice(1))
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "");

    switch (opcode) {
      case 0:
        let welcome = `${text} joined the chat!`;
        console.log(welcome);
        socket.username = text;
        wss.clients.forEach(function(client) {
          if (client.readyState === WebSocket.OPEN) {
            client.send(str2ab("\0" + welcome));
          }
        });
        break;
      case 1:
        console.log(`${socket.username}: ${text}`);
        wss.clients.forEach(function(client) {
          if (client.readyState === WebSocket.OPEN) {
            let m = "\1" + socket.username + "\0" + text;
            client.send(str2ab(m));
          }
        });
        break;
      default:
        console.log(data);
        break;
    }
  });

  socket.on("close", function() {
    console.log("socket close event...");
  });

  // disconnect event...
  socket.on("disconnect", function() {
    console.log("socket disconnect event...");
  });

  // timeout event...
  socket.on("timeout", function(had_error) {
    console.log("socket timeout event...", had_error);
  });

  // error event...
  socket.on("error", function(had_error) {
    console.log("socket error event...", had_error);
  });
});

// heartbeat handler
if (HEARTBEAT_ENABLED) {
  const interval = setInterval(function ping() {
    wss.clients.forEach(function each(socket) {
      if (socket.isAlive === false) return socket.terminate();

      socket.isAlive = false;
      socket.ping(noop);
    });
  }, HEARTBEAT_INTERVAL);
}

// heartbeat functions
function noop() {}
function heartbeat() {
  this.isAlive = true;
}

// source: http://stackoverflow.com/a/11058858
function ab2str(buf) {
  return String.fromCharCode.apply(null, new Uint8Array(buf));
}

function str2ab(str) {
  var buf = new ArrayBuffer(str.length); // 2 bytes for each char
  var bufView = new Uint8Array(buf);
  for (var i = 0, strLen = str.length; i < strLen; i++) {
    bufView[i] = str.charCodeAt(i);
  }
  return buf;
}
