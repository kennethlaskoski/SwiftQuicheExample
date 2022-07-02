//  Copyright Kenneth Laskoski. All Rights Reserved.
//  SPDX-License-Identifier: Apache-2.0

import NIOCore
import NIOPosix
import SwiftQuiche

final class QuicheVersionNegotiationHandler: ChannelOutboundHandler {
  typealias OutboundIn = AddressedEnvelope<ByteBuffer>

  func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
    context.write(data, promise: promise)
  }
}
