//
//  TranslateViewModel.swift
//  Translate Bar
//
//  Created by Artem Bobrov on 13.06.2018.
//  Copyright © 2018 Artem Bobrov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

class TranslateViewModel {
	private let disposeBag = DisposeBag()

	private let translateProvider = MoyaProvider<YandexTranslate>()
	private var inputText = BehaviorRelay<String>(value: "")
	private var outputText = BehaviorRelay<String>(value: "")

	let maxCharactersCount = 5000

    public var rawInput = BehaviorRelay<String?>(value: nil)
    public var rawOutput = BehaviorRelay<String?>(value: nil)
    public var sourceLanguageIndex = BehaviorRelay<Int>(value: 0)
    public var targetLanguageIndex = BehaviorRelay<Int>(value: 0)
    public var sourceLanguagesQueue = BehaviorRelay<FixedQueue<Language>>(value: FixedQueue<Language>(.english, .russian, .german))
    public var targetLanguagesQueue = BehaviorRelay<FixedQueue<Language>>(value: FixedQueue<Language>(.russian, .english, .german))
	public var searchQueryString = BehaviorRelay<String?>(value: nil)
	public var isSourceLanguagePickerActive = BehaviorRelay<Bool>(value: false)
	public var isTargetLanguagePickerActive = BehaviorRelay<Bool>(value: false)
	public var inputWords = BehaviorRelay<[String]>(value: [])
    public var isPopoverPinned = BehaviorRelay<Bool>(value: false)

    lazy var traslatePreferences = BehaviorRelay<TranslationPreferences>(value: TranslationPreferences())

	init() {
        setupTranslation()
		setupPickersActivity()
		updateTranslationPreferences()
		setupPopoverBehaviour()
	}

	func swap() {
		rx_swap(rawInput, rawOutput)

		swapLanguages()
	}

	public func translateFromClipboard() {
		guard SettingsService.shared.isAutomaticallyTranslateClipboard else { return }
		Log.verbose("Translation from clipboard needed")
		let clipboard = NSPasteboard.clipboard
		rawInput.accept(clipboard)
	}

	public func pick(language: Language) {
		if isSourceLanguagePickerActive.value {
			sourceLanguagesPush(language: language)
		} else if isTargetLanguagePickerActive.value {
			targetLanguagesPush(language: language)
		}
	}

	private func targetLanguagesPush(language: Language) {
		var queue = targetLanguagesQueue.value
		let (index, _) = queue.push(language)
		targetLanguageIndex.accept(index)
		targetLanguagesQueue.accept(queue)
		isTargetLanguagePickerActive.accept(false)
	}

	private func sourceLanguagesPush(language: Language) {
		var queue = sourceLanguagesQueue.value
		let (index, _) = queue.push(language)
		sourceLanguageIndex.accept(index)
		sourceLanguagesQueue.accept(queue)
		isSourceLanguagePickerActive.accept(false)
	}

    public var isSuggestHidden: Observable<Bool> {
        return inputWords
			.map { words in
				guard words.count == 1, let word = words.first else {
					return true
				}
				return word.letterCount == 0
			}
    }

	public var isLanguagePickerNeeded: Observable<Bool> {
		return Observable.combineLatest(isTargetLanguagePickerActive, isSourceLanguagePickerActive)
			.map { $0 || $1 }
			.distinctUntilChanged()
	}

    public var text: Observable<String?> {
        return Observable
                .of(rawInput, rawOutput)
                .merge()
    }

    public var limitationText: Observable<String> {
        return rawInput
            .map { $0?.count ?? 0 }
            .map { "\($0)/\(self.maxCharactersCount)" }
            .asObservable()
    }

    public var clearButtonHidden: Observable<Bool> {
        return rawInput
            .map { $0?.isEmpty ?? true }
            .asObservable()
    }

    public var sourceLanguage: Observable<Language?> {
        return sourceLanguageIndex
            .map { self.sourceLanguagesQueue.value[$0] }
            .asObservable()
    }
    public var targetLanguage: Observable<Language?> {
        return targetLanguageIndex
            .map { self.targetLanguagesQueue.value[$0] }
            .asObservable()
    }

	public var allLanguages: Observable<[Language]> {
		return Observable.combineLatest(traslatePreferences, searchQueryString, isLanguagePickerNeeded)
			.map { (traslatePreferences, searchQueryString, isLanguagePickerNeeded) -> [Language] in
				guard isLanguagePickerNeeded, let query = searchQueryString?.lowercased(), !query.isEmpty else {
					return traslatePreferences.languages
				}
				return traslatePreferences.languages.filter { $0.fullName?.contains(query) ?? false }
			}
	}

	private func setupPopoverBehaviour() {
		let appDelegate = NSApplication.shared.delegate as! AppDelegate // swiftlint:disable:this force_cast
		isPopoverPinned
			.subscribe(onNext: { isPinned in
				appDelegate.popover.behavior = isPinned ? .applicationDefined : .transient
			})
			.disposed(by: disposeBag)
	}

	private func setupTranslation() {
		rawInput
			.filter { $0?.isEmpty ?? true }
			.map { _ in "" }
			.bind(to: outputText)
			.disposed(by: disposeBag)
		rawInput
			.filter { $0?.isEmpty ?? true }
			.map { _ in "" }
			.bind(to: inputText)
			.disposed(by: disposeBag)
		rawInput
			.distinctUntilChanged()
			.debounce(1, scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
			.filter { $0 != nil && $0!.count > 0 }
			.map { $0! }
			.bind(to: inputText)
			.disposed(by: disposeBag)
		outputText
			.bind(to: rawOutput)
			.disposed(by: disposeBag)
		Observable.combineLatest(inputText, sourceLanguage, targetLanguage)
			.filter { !$0.0.isEmpty && $0.1 != nil && $0.2 != nil }
			.subscribe(onNext: { (text, source, target) in
				self.translate(text: text, source: source!, target: target!)
					.map { $0.text ?? "" }
					.bind(to: self.outputText)
					.disposed(by: self.disposeBag)
			})
			.disposed(by: disposeBag)
	}

	private func setupPickersActivity() {
		isSourceLanguagePickerActive
			.subscribe { value in
				if value.element! && self.isTargetLanguagePickerActive.value {
					self.isTargetLanguagePickerActive.accept(false)
				}
			}
			.disposed(by: disposeBag)
		isTargetLanguagePickerActive
			.subscribe { value in
				if value.element! && self.isSourceLanguagePickerActive.value {
					self.isSourceLanguagePickerActive.accept(false)
				}
			}
			.disposed(by: disposeBag)
	}

	private func swapLanguages() {
		let sourceLanguage = sourceLanguagesQueue.value[sourceLanguageIndex.value]
		let targetLanguage = targetLanguagesQueue.value[targetLanguageIndex.value]

		if !targetLanguagesQueue.value.contains(sourceLanguage) && !sourceLanguagesQueue.value.contains(targetLanguage) {
			naiveSwapLanguages()
			return
		}

		if let index = sourceLanguagesQueue.value.index(of: targetLanguage) {
			sourceLanguageIndex.accept(index)
		} else {
			var queue = sourceLanguagesQueue.value
			let (index, _) = queue.push(targetLanguage)
			sourceLanguagesQueue.accept(queue)
			sourceLanguageIndex.accept(index)
		}

		if let index = targetLanguagesQueue.value.index(of: sourceLanguage) {
			targetLanguageIndex.accept(index)
		} else {
			var queue = targetLanguagesQueue.value
			let (index, _) = queue.push(sourceLanguage)
			targetLanguagesQueue.accept(queue)
			targetLanguageIndex.accept(index)
		}
	}

	private func naiveSwapLanguages() {
		var lhs = sourceLanguagesQueue.value
		var rhs = targetLanguagesQueue.value

		let tmp = lhs[sourceLanguageIndex.value]
		lhs[sourceLanguageIndex.value] = rhs[targetLanguageIndex.value]
		rhs[targetLanguageIndex.value] = tmp

		sourceLanguagesQueue.accept(lhs)
		targetLanguagesQueue.accept(rhs)
	}

    private func updateTranslationPreferences() {
        translateProvider.rx
            .request(.getSupportedLanguages, callbackQueue: .global(qos: .userInteractive))
            .Rmap(to: TranslationPreferences.self)
            .asObservable()
            .bind(to: traslatePreferences)
            .disposed(by: disposeBag)
    }

    private func translate(text: String, source: Language, target: Language) -> Observable<Translation> {
        return translateProvider
                .rx
                .request(.translate(from: source, to: target, text: text), callbackQueue: .global(qos: .userInteractive))
                .Rmap(to: Translation.self)
                .filter { $0.text != nil }
                .asObservable()
    }
}
