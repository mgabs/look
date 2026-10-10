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

        var scored: [(result: LauncherResult, score: Int)] = []

        for url in contents {
            let name = url.lastPathComponent
            let nameLower = name.lowercased()
            let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            let kind: LauncherResultKind = isDirectory ? .folder : .file
            let displayPath = url.path

            var score = 0
            if prefixFilter.isEmpty {
                score = isDirectory ? 10_000 : 5_000
            } else if nameLower.hasPrefix(prefixFilter) {
                score = 20_000 + (isDirectory ? 2_000 : 0)
            } else if nameLower.contains(prefixFilter) {
                score = 15_000 + (isDirectory ? 2_000 : 0)
            } else if let fScore = EngineBridge.shared.fuzzyScore(query: prefixFilter, title: nameLower) {
                score = 5_000 + fScore + (isDirectory ? 2_000 : 0)
            } else {
                continue
            }

            var subtitle = displayPath
            if isDirectory {
                subtitle = "\(displayPath)  •  Tab to enter folder"
            }

            let item = LauncherResult(
                id: "path:\(displayPath)",
                kind: kind,
                title: name,
                subtitle: subtitle,
                path: displayPath,
                score: score
            )
            scored.append((item, score))
        }

        // Sort by score descending, then folders first, then title
        return scored.sorted { a, b in
            if a.score != b.score {
                return a.score > b.score
            }
            if a.result.kind != b.result.kind {
                return a.result.kind == .folder
            }
            return a.result.title.localizedCaseInsensitiveCompare(b.result.title) == .orderedAscending
        }.map(\.result)
    }
}
