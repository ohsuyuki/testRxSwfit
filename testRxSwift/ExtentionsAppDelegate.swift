//
//  ExtentionsAppDelegate.swift
//  testRxSwift
//
//  Created by yuuki oosu on 2019/04/03.
//  Copyright © 2019 yuuki oosu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// to test RxSwift
extension AppDelegate {

    func testDsposing() {
        let scheduler = SerialDispatchQueueScheduler(qos: .default)
        let subscription = Observable<Int>.interval(0.3, scheduler: scheduler)
            .subscribe { event in
                print(event)
            }
        Thread.sleep(forTimeInterval: 2.0)
        subscription.dispose()
    }

    fileprivate func myJust<E>(_ element: E) -> Observable<E> {
        return Observable.create { observer in
            observer.on(.next(element))
            observer.on(.completed)
            return Disposables.create()
        }
    }

    func testMyJust() {
        myJust(0)
            .subscribe(onNext: { (n) in
                print(n)
            })
    }

    fileprivate func myForm<E>(_ sequence: [E]) -> Observable<E> {
        return Observable.create { observer in
            for element in sequence {
                observer.on(.next(element))
            }

            observer.on(.completed)

            return Disposables.create()
        }
    }

    func testMyForm() {
        let stringCounter = myForm(["first", "second"])

        print("started ----")

        // first time
        stringCounter
            .subscribe(onNext: { (n) in
                print(n)
            })
        
        print("----")

        // again
        stringCounter
            .subscribe(onNext: { (n) in
                print(n)
            })

        print("Ended ----")
    }

    fileprivate func testMyInterval(_ interval: TimeInterval) -> Observable<Int> {
        return Observable.create { observer in
            print("Subscribed")
            let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            timer.schedule(deadline: DispatchTime.now() + interval, repeating: interval)

            let cancel = Disposables.create {
                print("Disposed")
                timer.cancel()
            }

            var next = 0
            timer.setEventHandler {
                if cancel.isDisposed {
                    return
                }
                observer.on(.next(next))
                next += 1
            }
            timer.resume()

            return cancel
        }
    }

    func testMyInterval() {
        let counter = testMyInterval(0.1)

        print("Started ----")

        let subscription1 = counter
            .subscribe(onNext: { (n) in
                print("First \(n)")
            })
        let subscription2 = counter
            .subscribe(onNext: { (n) in
                print("Second \(n)")
            })

        Thread.sleep(forTimeInterval: 0.5)
        subscription1.dispose()

        Thread.sleep(forTimeInterval: 0.5)
        subscription2.dispose()

        print("Ended ----")
    }

    func testShareWithMyInterval() {
        let counter = testMyInterval(0.1)
            .debug()
            .share(replay: 1)

        print("Started ----")

        let subscription1 = counter
            .subscribe(onNext: { (n) in
                print("First \(n)")
            })
        let subscription2 = counter
            .subscribe(onNext: { (n) in
                print("Second \(n)")
            })

        Thread.sleep(forTimeInterval: 0.5)
        subscription1.dispose()

        Thread.sleep(forTimeInterval: 0.5)
        subscription2.dispose()

        print("Ended ----")
    }

    func testURLSessionExtension() {
        let req = URLRequest(url: URL(string: "https://en.wikipedia.org/w/api.php?action=parse&page=Pizza&format=json")!)
        let responseJSON = URLSession.shared.rx.json(request: req)
        .debug("my debug")

        let cancelRequest = responseJSON
            .subscribe(onNext: { (json) in
                print(json)
            })

        Thread.sleep(forTimeInterval: 3.0)

        cancelRequest.dispose()
    }

}
