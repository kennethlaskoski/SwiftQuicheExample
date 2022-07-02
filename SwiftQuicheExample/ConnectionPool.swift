//  Copyright Kenneth Laskoski. All Rights Reserved.
//  SPDX-License-Identifier: Apache-2.0

import SwiftQuiche
import Foundation

struct PartialResponse {
  let body: [UInt8]
  let written: Int
}

struct Client {
  let connection: SQConnection
  let partialResponses: [UInt64: PartialResponse]
}

typealias ClientMap = [SQConnectionID: Client]

func generateConnectionID(with length: Int) throws -> SQConnectionID {
  var bytes = [UInt8](repeating: 0, count: length)
  let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
  guard status == errSecSuccess else {
    throw SQError.cryptoFail
  }
  return SQConnectionID(rawValue: bytes)
}

let localConnectionIDLength = 16
let maxDatagramSize = 1350

var clients: ClientMap = [:]

var config: SQConfig? = {
  let config = SQConfig()
  do {
    try config.loadCertChainFromPEMFile(path: "cert.crt")
    try config.loadPrivKeyFromPEMFile(path: "cert.key")
    try config.setApplicationProtos("\u{0a}hq-interop\u{05}hq-29\u{05}hq-28\u{05}hq-27\u{08}http/0.9")
    config.setMaxIdleTimeout(5000);
    config.setMaxRecvUDPPayloadSize(maxDatagramSize);
    config.setMaxSendUDPPayloadSize(maxDatagramSize);
    config.setInitialMaxData(10000000)
    config.setInitialMaxStreamDataBidiLocal(1000000)
    config.setInitialMaxStreamDataBidiRemote(1000000)
    config.setInitialMaxStreamsBidi(100)
    config.setCCAlgorithm(.reno);
  } catch {
    return nil
  }
  return config
}()
