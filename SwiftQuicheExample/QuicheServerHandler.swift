//  Copyright Kenneth Laskoski. All Rights Reserved.
//  SPDX-License-Identifier: Apache-2.0

import NIOCore
import NIOPosix
import SwiftQuiche

public final class QuicheServerHandler: ChannelInboundHandler {
  public typealias InboundIn = AddressedEnvelope<ByteBuffer>
  public typealias OutboundOut = AddressedEnvelope<ByteBuffer>

  public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    let envelope = unwrapInboundIn(data)
    var buffer = envelope.data

    let bytes = buffer.readBytes(length: buffer.readableBytes)!

    var type: SQType?
    var version: SQVersion
    var scid: SQConnectionID
    var dcid: SQConnectionID
    var token: SQToken

    (type, version, scid, dcid, token) = try! sqHeaderInfo(buffer: bytes)

    print(type!)
    print(version)
    print(scid)
    print(dcid)
    print(token)

    // As we are not really interested getting notified on success or failure we just pass nil as promise to
    // reduce allocations.
//    context.write(data, promise: nil)
  }

  public func channelReadComplete(context: ChannelHandlerContext) {
    // As we are not really interested getting notified on success or failure we just pass nil as promise to
    // reduce allocations.
    context.flush()
  }

  public func errorCaught(context: ChannelHandlerContext, error: Error) {
    print("error: ", error)

    // As we are not really interested getting notified on success or failure we just pass nil as promise to
    // reduce allocations.
    context.close(promise: nil)
  }
}