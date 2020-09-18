import Yosemite
import class AutomatticTracks.CrashLogging
import protocol Storage.StorageManagerType

/// ViewModel for `OrderListViewController`. This will make `OrdersViewModel` obsolete when
/// iOS 13.0 is set as the minimum version.
///
/// This is an incremental WIP. Eventually, we should move all the data loading in here.
///
/// Important: The `OrdersViewController` **owned** by `OrdersMasterViewController` currently
/// does not get deallocated when switching sites. This `ViewModel` should consider that and not
/// keep site-specific information as much as possible. For example, we shouldn't keep `siteID`
/// in here but grab it from the `SessionManager` when we need it. Hopefully, we will be able to
/// fix this in the future.
///
/// ## Work In Progress
///
/// This does not do anything at the moment. We will integrate `FetchResultsSnapshotsProvider`
/// in here next.
///
@available(iOS 13.0, *)
final class OrderListViewModel {
    private let storageManager: StorageManagerType
    private let pushNotificationsManager: PushNotesManager
    private let notificationCenter: NotificationCenter

    /// Used for cancelling the observer for Remote Notifications when `self` is deallocated.
    ///
    private var cancellable: ObservationToken?

    /// The block called if self requests a resynchronization of the first page. The
    /// resynchronization should only be done if the view is visible.
    ///
    var onShouldResynchronizeIfViewIsVisible: (() -> ())?

    /// OrderStatus that must be matched by retrieved orders.
    ///
    let statusFilter: OrderStatus?

    /// If true, orders created after today's day will be included in the result.
    ///
    /// This will generally only be false for the All Orders tab. All other screens should show orders in the future.
    ///
    /// Defaults to `true`.
    ///
    private let includesFutureOrders: Bool

    /// Used for tracking whether the app was _previously_ in the background.
    ///
    private var isAppActive: Bool = true

    init(storageManager: StorageManagerType = ServiceLocator.storageManager,
         pushNotificationsManager: PushNotesManager = ServiceLocator.pushNotesManager,
         notificationCenter: NotificationCenter = .default,
         statusFilter: OrderStatus?,
         includesFutureOrders: Bool = true) {
        self.storageManager = storageManager
        self.pushNotificationsManager = pushNotificationsManager
        self.notificationCenter = notificationCenter
        self.statusFilter = statusFilter
        self.includesFutureOrders = includesFutureOrders
    }

    deinit {
        stopObservingForegroundRemoteNotifications()
    }

    /// Start fetching DB results and forward new changes to the given `tableView`.
    ///
    /// This is the main activation method for this ViewModel. This should only be called once.
    /// And only when the corresponding view was loaded.
    ///
    func activate() {
        notificationCenter.addObserver(self, selector: #selector(handleAppDeactivation),
                                       name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleAppActivation),
                                       name: UIApplication.didBecomeActiveNotification, object: nil)

        observeForegroundRemoteNotifications()
    }

    @objc private func handleAppDeactivation() {
        isAppActive = false
    }

    /// Request a resynchornization if the app was previously in the background.
    ///
    @objc private func handleAppActivation() {
        guard !isAppActive else {
            return
        }

        isAppActive = true
        onShouldResynchronizeIfViewIsVisible?()
    }

    /// Returns what `OrderAction` should be used when synchronizing.
    func synchronizationAction(siteID: Int64,
                               pageNumber: Int,
                               pageSize: Int,
                               reason: OrderListSyncActionUseCase.SyncReason?,
                               completionHandler: @escaping (Error?) -> Void) -> OrderAction {
        let useCase = OrderListSyncActionUseCase(siteID: siteID,
                                                 statusFilter: statusFilter,
                                                 includesFutureOrders: includesFutureOrders)
        return useCase.actionFor(pageNumber: pageNumber,
                                 pageSize: pageSize,
                                 reason: reason,
                                 completionHandler: completionHandler)
    }
}

// MARK: - Remote Notifications Observation
@available(iOS 13.0, *)
private extension OrderListViewModel {
    /// Watch for "new order" Remote Notifications that are received while the app is in the
    /// foreground.
    ///
    /// A refresh will be requested when receiving them.
    ///
    func observeForegroundRemoteNotifications() {
        cancellable = pushNotificationsManager.foregroundNotifications.subscribe { [weak self] notification in
            guard notification.kind == .storeOrder else {
                return
            }

            self?.onShouldResynchronizeIfViewIsVisible?()
        }
    }

    func stopObservingForegroundRemoteNotifications() {
        cancellable?.cancel()
    }
}