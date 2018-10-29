//
//  NSTextView+Rx.swift
//  TranslateBar
//
//  Created by Artem Bobrov on 13.06.2018.
//  Copyright © 2018 Artem Bobrov. All rights reserved.
//

import Cocoa
import RxCocoa
import RxSwift

class RxTextViewDelegateProxy: DelegateProxy<NSTextView, NSTextViewDelegate>,
    DelegateProxyType,
    NSTextViewDelegate {
    public private(set) weak var textView: NSTextView?
    fileprivate let textSubject = PublishSubject<String?>()

    init(textView: NSTextView) {
        self.textView = textView
        super.init(parentObject: textView, delegateProxy: RxTextViewDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        register { RxTextViewDelegateProxy(textView: $0) }
    }

    static func currentDelegate(for object: NSTextView) -> NSTextViewDelegate? {
        return object.delegate
    }

    static func setCurrentDelegate(_ delegate: NSTextViewDelegate?, to object: NSTextView) {
        object.delegate = delegate
    }

    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }
        let nextValue = textView.string

        textSubject.on(.next(nextValue))
        _forwardToDelegate?.controlTextDidChange?(notification)
    }
}

extension Reactive where Base: NSTextView {
    public var delegate: DelegateProxy<NSTextView, NSTextViewDelegate> {
        return RxTextViewDelegateProxy.proxy(for: base)
    }

    public var text: ControlProperty<String?> {
        let delegate = RxTextViewDelegateProxy.proxy(for: base)

        let source = Observable.deferred { [weak textView = self.base] in
            delegate.textSubject.startWith(textView?.string)
        }.takeUntil(deallocated)

        let observer = Binder(base) { (control, value: String?) in
            control.string = value ?? ""
        }

        return ControlProperty(values: source, valueSink: observer)
    }
}
