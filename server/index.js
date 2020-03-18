// import libraries
const http = require("http");
const WebSocket = require("ws");
const fs = require("fs");

// set some constants
const HEARTBEAT_INTERVAL = 2000; // 2 seconds
const HTTP_PORT = 8000;
const HEARTBEAT_ENABLED = false; // disable for now because of an issue with FCEUX...

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
  .listen(process.env.PORT || HTTP_PORT, function() {
    console.log(
      `HTTP server listening on port ${process.env.PORT || HTTP_PORT}`
    );
  });

// init websocket server
const wss = new WebSocket.Server({ server: httpServer }, function() {
  console.log(`WebSocket server listening...`);
});

// handle new connections
wss.on("connection", function(socket) {
  // log new connection
  console.log("new connection");

  // heartbeat init
  socket.isAlive = true;
  socket.on("pong", heartbeat);

  // broadcast received messages to every other clients
  socket.on("message", function(msg) {
    // get first element (opcode) from buffer
    let opcode = msg.readUInt8(0);

    // get text and remove accents
    let text = ab2str(msg.slice(1))
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "");

    // handle opcodes
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
        console.log(`Unknown opcode: ${opcode} / message: ${msg.slice(1)}`);
        break;
    }
  });

  // close event...
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
const interval = setInterval(function ping() {
  wss.clients.forEach(function each(socket) {
    if (HEARTBEAT_ENABLED)
      if (socket.isAlive === false) return socket.terminate();
    socket.isAlive = false;
    socket.ping(noop);
  });
}, HEARTBEAT_INTERVAL);

// heartbeat functions
function noop() {}
function heartbeat() {
  this.isAlive = true;
}

// helpers to convert ArrayBuffer <=> String
// source: http://stackoverflow.com/a/11058858
function ab2str(buf) {
  return String.fromCharCode.apply(null, new Uint8Array(buf));
}
function str2ab(str) {
  var buf = new ArrayBuffer(str.length);
  var bufView = new Uint8Array(buf);
  for (var i = 0, strLen = str.length; i < strLen; i++) {
    bufView[i] = str.charCodeAt(i);
  }
  return buf;
}
