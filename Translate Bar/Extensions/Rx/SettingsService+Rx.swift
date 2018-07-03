//
//  SettingsService+Rx.swift
//  Translate Bar
//
//  Created by abobrov on 02/07/2018.
//  Copyright © 2018 Artem Bobrov. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: SettingsService {
    var isLaunchedAtLogin: Binder<Bool> {
        return Binder(self.base) { service, value in
            service.isLaunchedAtLogin = value
        }
    }

    var isShowIconInDock: Binder<Bool> {
        return Binder(self.base) { service, value in
            service.isShowIconInDock = value
        }
    }

    var isAutomaticallyTranslateClipboard: Binder<Bool> {
        return Binder(self.base) { service, value in
            service.isAutomaticallyTranslateClipboard = value
        }
    }
}
