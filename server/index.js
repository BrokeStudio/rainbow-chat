"use strict";

// import libraries
const { performance } = require("perf_hooks");
const dgram = require("dgram");

// set some constants
const HEARTBEAT_INTERVAL = 10000; // 10 seconds
const HTTP_PORT = 1234;

const server = dgram.createSocket("udp4");
const client = dgram.createSocket("udp4");

let users = [];

server.on("listening", function () {
  let address = server.address();
  console.log(
    "UDP Server listening on " + address.address + ":" + address.port
  );
});

server.on("message", (data, remote) => {
  let msg, user;

  // get first element (opcode) from buffer
  let opcode = data.readUInt8(0);

  // get text and remove accents
  let text = ab2str(data.slice(1))
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");

  // handle opcodes
  switch (opcode) {
    // new user
    case 0:
      let welcome = `${text} joined the chat!`;
      console.log(welcome);
      users.push({
        username: text,
        address: remote.address,
        port: remote.port,
      });
      users.forEach((user) => {
        msg = "\x00" + welcome;
        client.send(msg, user.port, user.address);
      });
      break;

    // message
    case 1:
      user = getUser(remote.port, remote.address);
      if (Object.keys(user).length !== 0) {
        console.log(`${user.username}: ${text}`);
        user.lastSeen = performance.now();
        users.forEach((user) => {
          msg = "\x01" + user.username + "\x00" + text;
          client.send(msg, user.port, user.address);
        });
      } else {
        console.log(`${opcode} - Client not found in clients list.`);
      }
      break;

    // ping / keep alive from client
    case 2:
      user = getUser(remote.port, remote.address);
      if (Object.keys(user).length !== 0) {
        user.lastSeen = performance.now();
      } else {
        console.log(`${opcode} - Client not found in clients list.`);
      }
      break;
    default:
      console.log(`Unknown opcode: ${opcode} / message: ${msg.slice(1)}`);
      break;
  }
});

// start listening
server.bind(HTTP_PORT);

// heartbeat handler
const interval = setInterval(function ping() {
  users.forEach((user) => {
    // check when we saw the user for the last time
    if (performance.now() - user.lastSeen > HEARTBEAT_INTERVAL) {
      users.splice(users.indexOf(user), 1);
      console.log(
        `${user.username} has been disconnected (${
          (performance.now() - user.lastSeen) / 1000
        }).`
      );
    }
  });
}, HEARTBEAT_INTERVAL);

// search for user in clients list
function getUser(port, address) {
  for (let i = 0; i < users.length; i++) {
    const user = users[i];
    if (user.port == port && user.address == address) return user;
  }
  return {};
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
