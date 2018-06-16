## A guide on how to release EveryPay iOS SDK
## CONTENTS:
- A. Prerequisites
- B. Getting SDK to git repo and to cocoaPods
- C. Testing cocoaPods dependency
- D. Standard troubleshooting questions


## A. Prerequisites
- 0) Make sure that you are owner of everyPay-ios pod in cocoaPods.
- 1) Update version under project target. Version number according to scheme:

    a)    MAJOR version when you make incompatible API changes.
    
    b)   MINOR version when you add functionality in a backwards-compatible manner.
    
    c)  PATCH version when you make backwards-compatible bug fixes.
    
Additional labels for pre-release and build metadata are available as extensions to the MAJOR.MINOR.PATCH format.


## B. Getting SDK to git repo and to cocoaPods
- 1) Modify everyPay-ios.podspec file line : s.version = "MAJOR.MINOR.PATCH"
- 2) After locally confirmed that everything works push your changes to git repo master branch. NB! Make sure that modified .podspec file gets pushed
- 3) Run `pod lib lint` to verifiy that podspec is correct.
- 4) Make new release and tag it with same version number specified in .podspec file.
- 5) If podspec is verified then run `pod trunk push everyPay-ios.podspec`
- 5.1) You might get the following error 'You need to register a session first.'
- 5.2) Run `pod trunk register youremail@example.com 'Your Name'`
- 5.3) Verify the session by clicking the link on email sent to specified mail address
- 5.4) Run `pod trunk push everyPay-ios.podspec`
- 6) Wait until terminal says that pod is uploaded


## C. Testing cocoaPods dependency
- 1) Change the version of everyPay-ios pod in Podfile.
- 2) Run `pod update` in folder where Podfile is.
- 3) Test the flows in test application.

## D. Standard troubleshooting questions

- 1) What version of SDK are you using ? 
- 2) Is dependency strict or not ? 
- 3) Are you receiving any callback from Every Pay server ?
- 4) Could you send us logs about the issue,if you have any.
