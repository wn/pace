//
//  Observable.swift
//  Pace
//
//  Created by Julius Sander on 9/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

class Observable<T> {
    private var _value: T
    var observers: [Observer<T>]

    var value: T {
        get {
            return _value
        }
        set(newValue) {
            _value = newValue
            observers.forEach { $0.handler(_value) }
        }
    }

    func addObserver(_ observer: Observer<T>) {
        observers.append(observer)
    }

    func removeObservers(withIdentifier identifier: String) {
        observers.removeAll { $0.identifier == identifier }
    }

    init(value: T) {
        self._value = value
        observers = []
    }
}

class Observer<T> {
    let identifier: String
    var handler: (T) -> Void
    init(identifier: String, _ handler: @escaping (T) -> Void) {
        self.identifier = identifier
        self.handler = handler
    }
}
