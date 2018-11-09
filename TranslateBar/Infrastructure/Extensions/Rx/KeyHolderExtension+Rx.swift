//
//  KeyHolderExtension+Rx.swift
//  TranslateBar
//
//  Created by Artem Bobrov on 07.07.2018.
//  Copyright © 2018 Artem Bobrov. All rights reserved.
//

import KeyHolder
import Magnet
import RxCocoa
import RxSwift

private class RxRecordViewDelegateProxy: DelegateProxy<RecordView, RecordViewDelegate>,
    RecordViewDelegate,
    DelegateProxyType {
    fileprivate let keyCombo = PublishSubject<KeyCombo>()
    fileprivate let viewDidEndRecording = PublishSubject<()>()
    fileprivate let viewDidClearShortcut = PublishSubject<()>()

    static func registerKnownImplementations() {
        register { parent -> RxRecordViewDelegateProxy in
            RxRecordViewDelegateProxy(parentObject: parent)
        }
    }

    init(parentObject: RecordView) {
        super.init(parentObject: parentObject, delegateProxy: RxRecordViewDelegateProxy.self)
    }

    static func currentDelegate(for object: RecordView) -> RecordViewDelegate? {
        let recordView = object
        return recordView.delegate
    }

    static func setCurrentDelegate(_ delegate: RecordViewDelegate?, to object: RecordView) {
        let recordView = object
        recordView.delegate = delegate
    }

    func recordViewShouldBeginRecording(_ recordView: RecordView) -> Bool {
        return true
    }

    func recordView(_ recordView: RecordView, canRecordKeyCombo keyCombo: KeyCombo) -> Bool {
        return true
    }

    func recordViewDidClearShortcut(_ recordView: RecordView) {
        viewDidClearShortcut.onNext(())
    }

    func recordView(_ recordView: RecordView, didChangeKeyCombo keyCombo: KeyCombo) {
        self.keyCombo.onNext(keyCombo)
    }

    func recordViewDidEndRecording(_ recordView: RecordView) {
        viewDidEndRecording.onNext(())
    }
}

extension Reactive where Base: RecordView {
    fileprivate var delegateProxy: RxRecordViewDelegateProxy {
        return RxRecordViewDelegateProxy.proxy(for: base)
    }

    var keyCombo: Observable<KeyCombo> {
        return delegateProxy.keyCombo.asObservable()
    }

    var didEndRecording: Observable<()> {
        return delegateProxy.viewDidEndRecording.asObservable()
    }

    var didClearShortcut: Observable<()> {
        return delegateProxy.viewDidClearShortcut.asObservable()
    }
}
