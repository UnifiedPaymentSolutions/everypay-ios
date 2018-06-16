#
#  Be sure to run `pod spec lint everyPay-ios.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "everyPay-ios"
  s.version      = "1.0.11"
  s.summary      = "iOS SDK for EveryPay service."

  s.description  = <<-DESC
                   EveryPay SDK for iOS allows merchants to easily integrate EveryPay payment flow into applications.
                   Check homepage for sample usage.
                   DESC

  s.homepage     = "https://github.com/UnifiedPaymentSolutions/everypay-ios"
  s.license      = "Apache License, Version 2.0"
  s.author             = { "Lauri Eskor" => "lauri.eskor@lab.mobi" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/UnifiedPaymentSolutions/everypay-ios.git", :tag => "#{s.version}" }
  s.source_files  = "everyPay/sdk/*{m,h}", "everyPay/sdk/api/*{m,h}", "everyPay/sdk/category/*{m,h}", "everyPay/sdk/model/*{m,h}", "everyPay/sdk/utility/*{m,h}", "everyPay/sdk/viewController/*{m,h}"
  s.resources    = "everyPay/sdk/viewController/*.{xib}", "everyPay/sdk/Base.lproj/*.strings"
  s.requires_arc = true

end
