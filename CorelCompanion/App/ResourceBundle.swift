import Foundation

enum ResourceBundle {
    static let current: Bundle = {
        if let resourcesURL = Bundle.main.resourceURL {
            let nestedURL = resourcesURL.appendingPathComponent("CorelCompanion_CorelCompanion.bundle")
            if let bundle = Bundle(url: nestedURL) { return bundle }
        }
        return .module
    }()
}
