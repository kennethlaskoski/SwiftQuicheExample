//  Copyright Kenneth Laskoski. All Rights Reserved.
//  SPDX-License-Identifier: Apache-2.0

import NIOCore
import NIOPosix

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
var bootstrap = QuicheServerBootstrap(group: group)
  .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
  .channelInitializer { channel in
    channel.pipeline.addHandler(QuicheDatagramHandler()).flatMap {
    channel.pipeline.addHandler(QuicheVersionNegotiationHandler())
    }
  }

defer {
  try! group.syncShutdownGracefully()
}

var arguments = CommandLine.arguments.dropFirst(0) // just to get an ArraySlice<String> from [String]
//if arguments.dropFirst().first == .some("--enable-gathering-reads") {
//    bootstrap = bootstrap.channelOption(ChannelOptions.datagramVectorReadMessageCount, value: 30)
//    bootstrap = bootstrap.channelOption(ChannelOptions.recvAllocator, value: FixedSizeRecvByteBufferAllocator(capacity: 30 * 2048))
//    arguments = arguments.dropFirst()
//}
let arg1 = arguments.dropFirst().first
let arg2 = arguments.dropFirst().dropFirst().first

let defaultHost = "::1"
let defaultPort = 4433

enum BindTo {
    case ip(host: String, port: Int)
    case unixDomainSocket(path: String)
}

let bindTarget: BindTo
switch (arg1, arg1.flatMap(Int.init), arg2.flatMap(Int.init)) {
case (.some(let h), _ , .some(let p)):
    /* we got two arguments, let's interpret that as host and port */
    bindTarget = .ip(host: h, port: p)
case (.some(let portString), .none, _):
    /* couldn't parse as number, expecting unix domain socket path */
    bindTarget = .unixDomainSocket(path: portString)
case (_, .some(let p), _):
    /* only one argument --> port */
    bindTarget = .ip(host: defaultHost, port: p)
default:
    bindTarget = .ip(host: defaultHost, port: defaultPort)
}

let channel = try { () -> Channel in
    switch bindTarget {
    case .ip(let host, let port):
        return try bootstrap.bind(host: host, port: port).wait()
    case .unixDomainSocket(let path):
        return try bootstrap.bind(unixDomainSocketPath: path).wait()
    }
    }()

print("Server started and listening on \(channel.localAddress!)")

// This will never unblock as we don't close the channel
try channel.closeFuture.wait()

print("Server closed")
