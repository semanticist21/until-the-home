import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Get a registrar for our custom channel
    let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "KkomiFileResolverPlugin")!
    let channel = FlutterMethodChannel(
      name: "kkomi.file_resolver",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "copyContentUriToCache":
        guard
          let args = call.arguments as? [String: Any],
          let uriString = args["uri"] as? String,
          let url = URL(string: uriString)
        else {
          result(FlutterError(code: "invalid_uri", message: "Missing uri argument", details: nil))
          return
        }
        do {
          let fileName = (args["fileName"] as? String)?.isEmpty == false
            ? args["fileName"] as? String
            : url.lastPathComponent.isEmpty ? "shared_file" : url.lastPathComponent
          let payload = try self.copyFileUrlToCache(url: url, fileName: fileName ?? "shared_file")
          result(payload)
        } catch {
          result(FlutterError(code: "copy_failed", message: error.localizedDescription, details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func copyFileUrlToCache(url: URL, fileName: String) throws -> [String: Any?] {
    guard url.isFileURL else {
      throw NSError(domain: "kkomi.file_resolver", code: 1, userInfo: [
        NSLocalizedDescriptionKey: "Unsupported URL scheme"
      ])
    }

    let safeName = fileName.replacingOccurrences(of: "[\\\\/:*?\"<>|]", with: "_", options: .regularExpression)
    let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    let destination = uniqueCacheUrl(in: cacheDir, fileName: safeName)

    let data = try Data(contentsOf: url)
    try data.write(to: destination, options: .atomic)

    let attrs = try? FileManager.default.attributesOfItem(atPath: destination.path)
    let size = attrs?[.size] as? NSNumber

    return [
      "path": destination.path,
      "displayName": safeName,
      "size": size?.intValue
    ]
  }

  private func uniqueCacheUrl(in directory: URL, fileName: String) -> URL {
    let baseName = (fileName as NSString).deletingPathExtension
    let ext = (fileName as NSString).pathExtension
    var candidate = directory.appendingPathComponent(fileName)
    if !FileManager.default.fileExists(atPath: candidate.path) {
      return candidate
    }
    let timestamp = Int(Date().timeIntervalSince1970 * 1000)
    let nextName = ext.isEmpty ? "\(baseName)_\(timestamp)" : "\(baseName)_\(timestamp).\(ext)"
    candidate = directory.appendingPathComponent(nextName)
    return candidate
  }
}
