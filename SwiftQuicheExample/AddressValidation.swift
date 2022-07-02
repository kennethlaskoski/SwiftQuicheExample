//  Copyright Kenneth Laskoski. All Rights Reserved.
//  SPDX-License-Identifier: Apache-2.0

import NIOCore
import SwiftQuiche

fileprivate let salt = "SwiftQuicheExample".utf8CString

struct AddressValidationToken {
  let data: [UInt8]

  init<T: Sequence>(bytes: T) where T.Element == UInt8 {
    data = [UInt8](bytes)
  }
}

extension AddressValidationToken {
  static var maxLength: Int {
    var result = salt.count
    result += MemoryLayout<SocketAddress>.size
    result += SQConnectionID.maxLength
    return result
  }
}

extension AddressValidationToken {
  /// Note that this function is only an example and doesn't do any cryptographic
  /// authentication of the token. *It should not be used in production system*.
  static func mint(for address: SocketAddress, with id: SQConnectionID) -> AddressValidationToken {
    var result: [UInt8] = []

    salt.withUnsafeBytes {
      result.append(contentsOf: $0)
    }

    withUnsafeBytes(of: address) {
      result.append(contentsOf: $0)
    }

    withUnsafeBytes(of: id) {
      result.append(contentsOf: $0)
    }

    return AddressValidationToken(bytes: result)
  }
}

extension AddressValidationToken {
  /// Note that this function is only an example and doesn't do any cryptographic
  /// authentication of the token. *It should not be used in production system*.
  func validate(for address: SocketAddress) -> SQConnectionID? {
    guard data.count >= salt.count else {
      return nil
    }
    guard String(cString: data).utf8CString == salt else {
      return nil
    }

    return data.withUnsafeBytes { p -> SQConnectionID? in
      var offset = salt.count
      let tokenAddress = p.baseAddress?.advanced(by: offset).load(as: SocketAddress.self)
      guard tokenAddress == address else {
        return nil
      }

      offset += MemoryLayout<SocketAddress>.size
      return p.baseAddress?.advanced(by: offset).load(as: SQConnectionID.self)
    }
  }
}
