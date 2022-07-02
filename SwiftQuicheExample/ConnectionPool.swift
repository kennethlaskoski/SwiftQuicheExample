//  Copyright Kenneth Laskoski. All Rights Reserved.
//  SPDX-License-Identifier: Apache-2.0

import SwiftQuiche

struct PartialResponse {
  let body: [UInt8]
  let written: Int
}

struct Client {
  let connection: SQConnection
  let partialResponses: [UInt64: PartialResponse]
}

typealias ClientMap = [SQConnectionID: Client]
