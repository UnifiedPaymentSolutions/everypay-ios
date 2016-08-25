## A guide on how to release EveryPay iOS SDK
## CONTENTS:
- A. Prerequisites
- B. Getting SDK to git repo and to cocoaPods
- C. Testing cocoaPods dependency


## A. Prerequisites
0) Make sure that you are owner of everyPay-ios pod in cocoaPods.
1) Update version under project target. Version number according to scheme:

    a)    MAJOR version when you make incompatible API changes.
    
    b)   MINOR version when you add functionality in a backwards-compatible manner.
    
    c)  PATCH version when you make backwards-compatible bug fixes.
    
Additional labels for pre-release and build metadata are available as extensions to the MAJOR.MINOR.PATCH format.


## B. Getting SDK to git repo and to cocoaPods
1) Modify everyPay-ios.podspec file line : s.version = "MAJOR.MINOR.PATCH"
2) After locally confirmed that everything works push your changes to git repo master branch. NB! Make sure that modified .podspec file gets pushed
3) Make new release and tag it with same version number specified in .podspec file.
4) Run `pod lib lint` to verifiy that podspec is correct.
5) If podspec is verified then run `pod trunk push everyPay-ios.podspec`
6) Wait until terminal says that pod is uploaded


## C. Testing cocoaPods dependency
1) Change the version of everyPay-ios pod in Podfile.
2) Run `pod update` in folder where Podfile is.
3) Test the flows in test application.



