import Foundation

enum PathNavigationService {
    static func isPathQuery(_ query: String) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.hasPrefix("/") || trimmed.hasPrefix("~")
    }

    static func resolvePath(_ input: String) -> String {
        var path = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if path.hasPrefix("~") {
            let home = FileManager.default.homeDirectoryForCurrentUser.path
            path = home + path.dropFirst()
        }
        return path
    }

    static func results(for query: String) -> [LauncherResult] {
        let resolved = resolvePath(query)
        let fileManager = FileManager.default

        var isDir: ObjCBool = false
        let exactExists = fileManager.fileExists(atPath: resolved, isDirectory: &isDir)

        let directoryToScan: String
        let prefixFilter: String
        let queryHasTrailingSlash = query.hasSuffix("/")

        if exactExists && isDir.boolValue && queryHasTrailingSlash {
            directoryToScan = resolved
            prefixFilter = ""
        } else {
            let url = URL(fileURLWithPath: resolved)
            directoryToScan = url.deletingLastPathComponent().path
            prefixFilter = url.lastPathComponent.lowercased()
        }

        guard fileManager.fileExists(atPath: directoryToScan, isDirectory: &isDir), isDir.boolValue else {
            return []
        }

        guard let contents = try? fileManager.contentsOfDirectory(
            at: URL(fileURLWithPath: directoryToScan),
            includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var results: [LauncherResult] = []

        let filtered = contents.filter { url in
            if prefixFilter.isEmpty { return true }
            return url.lastPathComponent.lowercased().hasPrefix(prefixFilter)
        }

        for (index, url) in filtered.enumerated() {
            let name = url.lastPathComponent
            let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            let kind: LauncherResultKind = isDirectory ? .folder : .file
            let displayPath = url.path

            var subtitle = displayPath
            if isDirectory {
                subtitle = "\(displayPath)  •  Tab to enter folder"
            }

            results.append(
                LauncherResult(
                    id: "path:\(displayPath)",
                    kind: kind,
                    title: name,
                    subtitle: subtitle,
                    path: displayPath,
                    score: 100_000 - index
                )
            )
        }

        // Sort folders first, then files alphabetically
        return results.sorted { a, b in
            if a.kind == b.kind {
                return a.title.localizedCaseInsensitiveCompare(b.title) == .orderedAscending
            }
            return a.kind == .folder
        }
    }
}
