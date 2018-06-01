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
    _ transform: @escaping (Element) throws -> Future<U>
  ) -> Future<[U]> {

    var future = worker.future(())

    var transformed = [U]()

    for element in self {

      future = future.flatMap {
        try transform(element)
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
    _ transform: @escaping (Element) throws -> Future<Void>
  ) -> Future<Void> {
    return _serialFutureMap(on: worker, transform).transform(to: ())
  }
}
