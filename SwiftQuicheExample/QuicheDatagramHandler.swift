//  Copyright Kenneth Laskoski. All Rights Reserved.
//  SPDX-License-Identifier: Apache-2.0

import NIOCore
import NIOPosix
import SwiftQuiche

final class QuicheDatagramHandler: ChannelInboundHandler {
  public typealias InboundIn = AddressedEnvelope<ByteBuffer>
  public typealias OutboundOut = AddressedEnvelope<ByteBuffer>

  public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    let envelope = unwrapInboundIn(data)
    var buffer = envelope.data
    let packet = buffer.readBytes(length: buffer.readableBytes)!
    let header = try! sqHeaderInfo(
      packet: packet,
      localConnectionIDLength: localConnectionIDLength,
      tokenLength: AddressValidationToken.maxLength
    )

    print("Type: \(header.type)")
    print("Version: \(header.version)")
    print("Sender ID: \(header.scid)")
    print("Destination ID: \(header.dcid)")
    print("Token: \(String(describing: header.token))")

    if let client = clients[header.dcid] {
      print(client)
    } else {
      if !isSupported(version: header.version) {
        print("TODO: Version negotiation")
      } else {
        print("TODO: Create connection")
      }
    }

    // As we are not really interested getting notified on success or failure we just pass nil as promise to
    // reduce allocations.
//    context.write(data, promise: nil)
  }

  public func channelReadComplete(context: ChannelHandlerContext) {
    context.flush()
  }

  public func errorCaught(context: ChannelHandlerContext, error: Error) {
    print("error: ", error)

    // As we are not really interested getting notified on success or failure we just pass nil as promise to
    // reduce allocations.
    context.close(promise: nil)
  }
}
