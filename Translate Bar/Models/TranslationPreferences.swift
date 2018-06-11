//
//  SupportedLanguages.swift
//  Translate Bar
//
//  Created by Artem Bobrov on 10.06.2018.
//  Copyright © 2018 Artem Bobrov. All rights reserved.
//

import Foundation
import EVReflection

struct Language: Hashable {
	let shortName: String
	let fullName: String

	static func == (lhs: Language, rhs: Language) -> Bool {
		return lhs.fullName == rhs.fullName && lhs.shortName == rhs.shortName
	}
}

class TranslationPreferences: EVObject {
	private var _directions: [(String, String)]?

	var directions: [Language: [Language]] = [:]
	var languages: [Language] = []

	override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
		return [
			(keyInObject: "_directions", keyInResource: nil),
			(keyInObject: "directions", keyInResource: nil),
			(keyInObject: "languages", keyInResource: nil)
		]
	}

	override func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
		return [
			(
				key: "langs",
				decodeConverter: { value in
					guard let langs = value as? [String: String] else {
						Log.error("Unexpected langs response \(String(describing: value))")
						return
					}
					langs.forEach { self.languages.append(Language(shortName: $0.key, fullName: $0.value)) }
					Log.verbose("Decoding languages END")
					if let dirs = self._directions {
						for pair in dirs {
							let from = self.languages.first(where: { $0.shortName == pair.0 })!
							let to = self.languages.first(where: { $0.shortName == pair.1 })!

							var value = self.directions[from] ?? []
							value.append(to)
							self.directions[from] = value
						}
					}
					self._directions = nil
					Log.verbose("Decoding directions from languaged END")
				},
				encodeConverter: {
					var dict: [String: String] = [:]
					self.languages.forEach({dict.updateValue($0.fullName, forKey: $0.shortName)})
					return dict
				}
			),
			(
				key: "dirs",
				decodeConverter: { value in
					guard let dirs = value as? [String] else {
						Log.error("Unexpected dirs response \(String(describing: value))")
						return
					}
					self._directions = dirs.map { $0.split(separator: "-")}
										   .map { (String($0.first!), String($0.last!)) }

					Log.verbose("Decoding raw translation directions END")
					
			},
				encodeConverter: {
					Array(self.directions.map({ pair -> [String] in
						pair.value.map ({ lang -> String in
							pair.key.shortName + "-" + lang.shortName
						})
					}).joined())
				}
			)

		]
	}
}
