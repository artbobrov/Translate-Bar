// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
    import AppKit.NSImage
    internal typealias AssetColorTypeAlias = NSColor
    internal typealias AssetImageTypeAlias = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
    import UIKit.UIImage
    internal typealias AssetColorTypeAlias = UIColor
    internal typealias AssetImageTypeAlias = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
    internal static let af = ImageAsset(name: "af")
    internal static let auto = ImageAsset(name: "auto")
    internal static let az = ImageAsset(name: "az")
    internal static let be = ImageAsset(name: "be")
    internal static let bg = ImageAsset(name: "bg")
    internal static let bn = ImageAsset(name: "bn")
    internal static let bs = ImageAsset(name: "bs")
    internal static let cs = ImageAsset(name: "cs")
    internal static let cy = ImageAsset(name: "cy")
    internal static let da = ImageAsset(name: "da")
    internal static let de = ImageAsset(name: "de")
    internal static let el = ImageAsset(name: "el")
    internal static let en = ImageAsset(name: "en")
    internal static let es = ImageAsset(name: "es")
    internal static let et = ImageAsset(name: "et")
    internal static let eu = ImageAsset(name: "eu")
    internal static let fi = ImageAsset(name: "fi")
    internal static let fr = ImageAsset(name: "fr")
    internal static let ga = ImageAsset(name: "ga")
    internal static let gd = ImageAsset(name: "gd")
    internal static let gu = ImageAsset(name: "gu")
    internal static let he = ImageAsset(name: "he")
    internal static let hi = ImageAsset(name: "hi")
    internal static let hr = ImageAsset(name: "hr")
    internal static let ht = ImageAsset(name: "ht")
    internal static let hu = ImageAsset(name: "hu")
    internal static let hy = ImageAsset(name: "hy")
    internal static let id = ImageAsset(name: "id")
    internal static let `is` = ImageAsset(name: "is")
    internal static let it = ImageAsset(name: "it")
    internal static let ja = ImageAsset(name: "ja")
    internal static let jv = ImageAsset(name: "jv")
    internal static let ka = ImageAsset(name: "ka")
    internal static let kk = ImageAsset(name: "kk")
    internal static let kn = ImageAsset(name: "kn")
    internal static let ko = ImageAsset(name: "ko")
    internal static let ky = ImageAsset(name: "ky")
    internal static let lb = ImageAsset(name: "lb")
    internal static let lo = ImageAsset(name: "lo")
    internal static let lt = ImageAsset(name: "lt")
    internal static let lv = ImageAsset(name: "lv")
    internal static let mk = ImageAsset(name: "mk")
    internal static let ml = ImageAsset(name: "ml")
    internal static let mn = ImageAsset(name: "mn")
    internal static let mr = ImageAsset(name: "mr")
    internal static let ms = ImageAsset(name: "ms")
    internal static let mt = ImageAsset(name: "mt")
    internal static let my = ImageAsset(name: "my")
    internal static let ne = ImageAsset(name: "ne")
    internal static let nl = ImageAsset(name: "nl")
    internal static let no = ImageAsset(name: "no")
    internal static let pa = ImageAsset(name: "pa")
    internal static let pl = ImageAsset(name: "pl")
    internal static let pt = ImageAsset(name: "pt")
    internal static let ro = ImageAsset(name: "ro")
    internal static let ru = ImageAsset(name: "ru")
    internal static let sk = ImageAsset(name: "sk")
    internal static let sl = ImageAsset(name: "sl")
    internal static let sq = ImageAsset(name: "sq")
    internal static let sr = ImageAsset(name: "sr")
    internal static let su = ImageAsset(name: "su")
    internal static let sv = ImageAsset(name: "sv")
    internal static let te = ImageAsset(name: "te")
    internal static let tg = ImageAsset(name: "tg")
    internal static let th = ImageAsset(name: "th")
    internal static let tr = ImageAsset(name: "tr")
    internal static let uk = ImageAsset(name: "uk")
    internal static let ur = ImageAsset(name: "ur")
    internal static let uz = ImageAsset(name: "uz")
    internal static let vi = ImageAsset(name: "vi")
    internal static let xh = ImageAsset(name: "xh")
    internal static let yi = ImageAsset(name: "yi")
    internal static let zh = ImageAsset(name: "zh")
    internal static let pinOff = ImageAsset(name: "pin-off")
    internal static let pinOn = ImageAsset(name: "pin-on")
    internal static let swap = ImageAsset(name: "swap")
    internal static let language = ImageAsset(name: "language")
    internal static let languageFilled = ImageAsset(name: "language_filled")
}

// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ColorAsset {
    internal fileprivate(set) var name: String

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
    internal var color: AssetColorTypeAlias {
        return AssetColorTypeAlias(asset: self)
    }
}

internal extension AssetColorTypeAlias {
    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
    convenience init!(asset: ColorAsset) {
        let bundle = Bundle(for: BundleToken.self)
        #if os(iOS) || os(tvOS)
            self.init(named: asset.name, in: bundle, compatibleWith: nil)
        #elseif os(OSX)
            self.init(named: NSColor.Name(asset.name), bundle: bundle)
        #elseif os(watchOS)
            self.init(named: asset.name)
        #endif
    }
}

internal struct DataAsset {
    internal fileprivate(set) var name: String

    #if os(iOS) || os(tvOS) || os(OSX)
        @available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
        internal var data: NSDataAsset {
            return NSDataAsset(asset: self)
        }
    #endif
}

#if os(iOS) || os(tvOS) || os(OSX)
    @available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
    internal extension NSDataAsset {
        convenience init!(asset: DataAsset) {
            let bundle = Bundle(for: BundleToken.self)
            #if os(iOS) || os(tvOS)
                self.init(name: asset.name, bundle: bundle)
            #elseif os(OSX)
                self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
            #endif
        }
    }
#endif

internal struct ImageAsset {
    internal fileprivate(set) var name: String

    internal var image: AssetImageTypeAlias {
        let bundle = Bundle(for: BundleToken.self)
        #if os(iOS) || os(tvOS)
            let image = AssetImageTypeAlias(named: name, in: bundle, compatibleWith: nil)
        #elseif os(OSX)
            let image = bundle.image(forResource: NSImage.Name(name))
        #elseif os(watchOS)
            let image = AssetImageTypeAlias(named: name)
        #endif
        guard let result = image else { fatalError("Unable to load image named \(name).") }
        return result
    }
}

internal extension AssetImageTypeAlias {
    @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
    @available(OSX, deprecated,
               message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
    convenience init!(asset: ImageAsset) {
        #if os(iOS) || os(tvOS)
            let bundle = Bundle(for: BundleToken.self)
            self.init(named: asset.name, in: bundle, compatibleWith: nil)
        #elseif os(OSX)
            self.init(named: NSImage.Name(asset.name))
        #elseif os(watchOS)
            self.init(named: asset.name)
        #endif
    }
}

private final class BundleToken {}
