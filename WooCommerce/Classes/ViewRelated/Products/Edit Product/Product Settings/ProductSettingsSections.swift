import UIKit
import Yosemite

// MARK: - Mediators Protocols
//
/// Encapsulates configuration and interaction of a UITableView section header.
protocol ProductSettingsSectionMediator {
    var title: String { get }
    var rows: [ProductSettingsRowMediator] { get }

    init(_ settings: ProductSettings, productType: ProductType, isEditProductsRelease5Enabled: Bool)
}

// MARK: - Sections declaration for Product Settings
//
enum ProductSettingsSections {
    /// Publish Settings section
    struct PublishSettings: ProductSettingsSectionMediator {
        let title = NSLocalizedString("Publish Settings", comment: "Title of the Publish Settings section on Product Settings screen")

        let rows: [ProductSettingsRowMediator]

        init(_ settings: ProductSettings, productType: ProductType, isEditProductsRelease5Enabled: Bool) {
            if productType == .simple {
                let tempRows: [ProductSettingsRowMediator?] = [ProductSettingsRows.Status(settings),
                        ProductSettingsRows.Visibility(settings),
                        ProductSettingsRows.CatalogVisibility(settings),
                        ProductSettingsRows.VirtualProduct(settings),
                        isEditProductsRelease5Enabled ? ProductSettingsRows.DownloadableProduct(settings) : nil
                ]
                rows = tempRows.compactMap { $0 }
            } else {
                rows = [ProductSettingsRows.Status(settings),
                        ProductSettingsRows.Visibility(settings),
                        ProductSettingsRows.CatalogVisibility(settings)]
            }
        }
    }

    /// More Settings section
    struct MoreOptions: ProductSettingsSectionMediator {
        let title = NSLocalizedString("More Options", comment: "Title of the More Options section on Product Settings screen")

        let rows: [ProductSettingsRowMediator]

        init(_ settings: ProductSettings, productType: ProductType, isEditProductsRelease5Enabled: Bool) {
            rows = [ProductSettingsRows.ReviewsAllowed(settings),
            ProductSettingsRows.Slug(settings),
            ProductSettingsRows.PurchaseNote(settings),
            ProductSettingsRows.MenuOrder(settings)]
        }
    }
}
