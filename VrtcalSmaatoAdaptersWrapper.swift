import Vrtcal_Adapters_Wrapper_Parent
import SmaatoSDKCore
import SmaatoSDKBanner
import SmaatoSDKInterstitial

// Must be NSObject for SMABannerViewDelegate
class VrtcalSmaatoAdaptersWrapper: NSObject, AdapterWrapperProtocol {
    
    var appLogger: Logger
    var sdkEventsLogger: Logger
    var sdk = SDK.smaato
    var delegate: AdapterWrapperDelegate
    
    var smaInterstitial: SMAInterstitial?
    
    required init(
        appLogger: Logger,
        sdkEventsLogger: Logger,
        delegate: AdapterWrapperDelegate
    ) {
        self.appLogger = appLogger
        self.sdkEventsLogger = sdkEventsLogger
        self.delegate = delegate
    }
    
    func initializeSdk() {
        let config = SMAConfiguration(publisherId: "1100043958")!
        config.httpsOnly = true
        config.logLevel = .verbose
        config.maxAdContentRating = .undefined
        SmaatoSDK.initSDK(withConfig:config)
        sdkEventsLogger.log("Smaato does not provide an sdk init callback")
    }
    
    func handle(adTechConfig: AdTechConfig) {
        
        switch adTechConfig.placementType {
            case .banner:
                appLogger.log("Smaato Banner")
                let smaBannerView = SMABannerView()
                smaBannerView.delegate = self
                delegate.provide(banner: smaBannerView)
                smaBannerView.load(
                    withAdSpaceId: adTechConfig.adUnitId,
                    adSize: .xxLarge_320x50
                )

            case .interstitial:
                appLogger.log("Smaato Interstitial")
                SmaatoSDK.loadInterstitial(
                    forAdSpaceId: adTechConfig.adUnitId,
                    delegate: self
                )
                
                
            case .rewardedVideo:
                fatalError("rewardedVideo not supported for Smaato")
                
            case .showDebugView:
                appLogger.log("Smaato doesn't have a debug view")
        }
    }
    
    func showInterstitial() -> Bool {
        if let smaInterstitial {
            smaInterstitial.show(from: delegate.viewController)
            return true
        }
        
        return false
    }
    
    func destroyInterstitial() {
        smaInterstitial = nil
    }
}

extension VrtcalSmaatoAdaptersWrapper: SMABannerViewDelegate {
    func presentingViewController(for bannerView: SMABannerView) -> UIViewController {
        return delegate.viewController
    }

    func bannerViewDidLoad(_ bannerView: SMABannerView) {
        sdkEventsLogger.log("Smaato bannerViewDidLoad")
    }
     
    func bannerView(_ bannerView: SMABannerView, didFailWithError error: Error) {
        sdkEventsLogger.log("Smaato bannerView didFailWithError: \(error)")
    }

    func bannerViewDidTTLExpire(_ bannerView: SMABannerView) {
        sdkEventsLogger.log("Smaato bannerViewDidTTLExpire")
    }
}


extension VrtcalSmaatoAdaptersWrapper: SMAInterstitialDelegate {
    func interstitialDidLoad(_ interstitial: SMAInterstitial) {
        sdkEventsLogger.log("Smaato interstitialDidLoad")
        self.smaInterstitial = interstitial
    }
    
    func interstitial(_ interstitial: SMAInterstitial?, didFailWithError error: Error) {
        sdkEventsLogger.log("Smaato interstitial didFailWithError: \(error)")
    }
    
    func interstitialDidTTLExpire(_ interstitial: SMAInterstitial) {
        sdkEventsLogger.log("Smaato interstitialDidTTLExpire")
    }
}

