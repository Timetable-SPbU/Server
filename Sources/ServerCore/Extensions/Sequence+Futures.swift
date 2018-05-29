//
//  Sequence+Futures.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 20/04/2018.
//

import Async

extension Sequence {

  private func _parallelFutureMap<U>(
    on worker: Worker,
    _ transform: @escaping (Element) -> Future<U>
  ) -> Future<[U]> {
    return map(transform).flatten(on: worker)
  }

  func parallelFutureMap<U>(
    on worker: Worker,
    _ transform: @escaping (Element) -> Future<U>
  ) -> Future<[U]> {
    return parallelFutureMap(on: worker, transform)
  }

  func parallelFutureMap(
    on worker: Worker,
    _ transform: @escaping (Element) -> Future<Void>
  ) -> Future<Void> {
    return _parallelFutureMap(on: worker, transform).transform(to: ())
  }

  private func _serialFutureMap<U>(
    on worker: Worker,
    _ transform: @escaping (Element) -> Future<U>
  ) -> Future<[U]> {

    var future = worker.eventLoop.newSucceededFuture(result: ())

    var transformed = [U]()

    for element in self {

      future = future.then {
        transform(element)
      }.map {
        transformed.append($0)
      }
    }

    return future.map { transformed }
  }

  func serialFutureMap<U>(
    on worker: Worker,
    _ transform: @escaping (Element) -> Future<U>
  ) -> Future<[U]> {
    return _serialFutureMap(on: worker, transform)
  }

  func serialFutureMap(
    on worker: Worker,
    _ transform: @escaping (Element) -> Future<Void>
  ) -> Future<Void> {
    return _serialFutureMap(on: worker, transform).transform(to: ())
  }
}
