//  Copyright Kenneth Laskoski. All Rights Reserved.
//  SPDX-License-Identifier: Apache-2.0

import SwiftQuiche

let maxDatagramSize = 1350

final class PacketProcess {
  var clients: ClientMap = [:]

  static var config: SQConfig? = {
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

  func consume(packet: [UInt8]) {
    let header = try! sqHeaderInfo(
      packet: packet,
      localConnectionIDLength: SQConnectionID.maxLength,
      tokenLength: AddressValidationToken.maxLength
    )

    print("Type: \(header.type)")
    print("Version: \(header.version)")
    print("Sender ID: \(header.scid)")
    print("Destination ID: \(header.dcid)")
    print("Token: \(header.token)")
  }
}
