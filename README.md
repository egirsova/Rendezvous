# Rendezvous
-
iOS app that helps friends meet up by allowing them to share their locations with each other in real-time.   
Automatically notifies each individual using push notifications if the friend they are tracking is 5 minutes away or running late (these notifications can be configured in the app settings).

## Development
### Requirements
If you wish to build Rendezvous yourself, you will need the following components/tools:

* Xcode (6.3.0 or later)
* iOS SDK (8.0 or later)
* Git
* Google Maps iOS SDK
* Parse iOS SDK
* PubNub iOS SDK

#### Instructions
**Begin by cloning the repository**

1. Open Terminal and navigate to the directory you want the project to be in using `cd`:  

	`$ cd <path-to-project>`  
	

2. Clone the repository by typing the following command:  

	`$ git clone https://github.com/egirsova/Rendezvous.git`
	
	Once the repository has been cloned, you will need to install the three third-party APIs. The easiest way to install them is using CocoaPods. Complete the instructions below in order:
	  
**Install CocoaPods Tool (if you don't have it already)**
	
1. Open Terminal and run the following command:  
	
	`$ sudo gem install cocoapods`  
	
	If it runs without errors, CocoaPods should have successfully been installed on your computer. You will now use CocoaPods to install the two of the three libraries.

**Install the Google Maps iOS SDK and PubNub iOS SDK using CocoaPods**

1. In Terminal, navigate to your project directory using the `cd` command (if you are not in it already):  
	
	`$ cd <path-to-project>`

2. Create a `Podfile` in your project directory that will include two of the APIs by running:  
	
	`$ touch Podfile`

3. Find your Podfile in Finder, open it, add the following text, and save the changes:  
	
	~~~
	source 'https://github.com/CocoaPods/Specs.git'
	platform :ios, ‘8.0’
	use_frameworks!
	link_with ‘Rendezvous’, ‘RendezvousTests’
	pod 'GoogleMaps'
	pod "PubNub"
	~~~

4. In Terminal, navigate to your project directory using `cd` again (if you're not in it):  
	
	`$ cd <path-to-project>`
	
5. Run the `pod install` command:  
	
	`$ pod install`
	
	This may take a while. After this is successfully completed, you will have the Google iOS SDK and PubNub iOS SDK installed.
	
6. If Xcode is open, close it. From now on you will be using the project's `.xcworkspace` file to open the project.

**Install the Parse iOS SDK**  

Note: You can also install this using CocoaPods by adding `pod 'Parse'` to your previously created `Podfile` and running `pod install`, but described below is the way I installed it for this project (not sure why, please don't ask):

1. Download the SDK using this link: [Download Parse iOS SDK](https://parse.com/downloads/ios/parse-library/latest)
2. Unzip and drag the following files into the Xcode project folder target: Bolts.framework, Parse.framework, and ParseUI.framework. Make sure you check the "Copy items to destination's group folder" checkbox when prompted
3. Add the Dependencies by navigating in Xcode to Target -> Rendezvous -> and the Build Phases Tab. Make sure the three files you added in step 2 are shown in the "Link Binary With Libraries" section. In addition, add the following libraries by clicking the "+" in the bottom left:  
	
	* AudioToolbox.framework
	* CFNetwork.framework
	* CoreGraphics.framework
	* CoreLocation.framework
	* QuartzCore.framework
	* Security.framework
	* StoreKit.framework
	* SystemConfiguration.framework
	* libz.tbd
	* libsqlite3.tbd

	**Note**: not all of these frameworks may be necessary for your app (such as CoreLocation or StoreKit)

**Get API Keys for all three APIs**

1. Create accounts at all three APIs and register the app to generate keys. Instructions are available at each of their developer websites:  
	
	Google Maps: [https://developers.google.com/maps/documentation/ios-sdk/?hl=en](https://developers.google.com/maps/documentation/ios-sdk/?hl=en)  
	Parse: [https://www.parse.com/signup](https://www.parse.com/signup)  
	PubNub: [https://www.pubnub.com](https://www.pubnub.com)

**Configure the project to use the API keys**

For security reasons, the API keys I use are not included in the repository. You will need to create your own files that will include the keys that you just created.

1. In Xcode, create a new `.swift` file by navigating to File -> New -> File...
2. Under iOS, choose "Source" and select "Swift File". Title the file `ApiKeys.swift`
3. Open the newly created `ApiKeys.swift` file and add the following code under `import Foundation`:  
	
	~~~swift
	struct ApiKeys {
    static let parseApplicationId = "<your-parse-app-id>"
    static let parseClientKey = "<your-parse-client-key"
    static let pubnubPublishKey = "<your-pubnub-publish-key>"
    static let pubnubSubscribeKey = "<your-pubnub-subscribe-key>"
    static let googleMapsKey = "<your-googleMaps-key>"
	}
	~~~
4. Create a new javascript file called `api-keys.js` using your favorite text editor and save it in your `Cloud/cloud` directory in the repository directory. It should look like the following:
	
	~~~javascript
	var publishKey = '<your-pubnub-publish-key>';
	var subscribeKey = '<your-pubnub-subscribe-key>';
	
	module.exports.pubnub = function(name) {
	  var key = "";
	    if (name === 'publishKey') {
	      key = publishKey;
	  } else if (name === 'subscribeKey') {
	      key = subscribeKey;
	  } 
	    return key;
	}
	~~~
	
	**Note:** Both of this files are part of the repository `.gitignore` because you NEVER want to share your API keys with anyone

Phew. That's it! Your project should now build and compile without error.

<br>
#### Troubleshooting
If you are having trouble installing the APIs, check out the following installation documentation from each of the APIs:  
**Google Maps:** [https://developers.google.com/maps/documentation/ios-sdk/start] (https://developers.google.com/maps/documentation/ios-sdk/start)  
**Parse:** [https://parse.com/apps/quickstart#parse_data/mobile/ios/native/existing](https://parse.com/apps/quickstart#parse_data/mobile/ios/native/existing)  
**PubNub:** [https://www.pubnub.com/docs/swift/pubnub-swift-sdk] (https://www.pubnub.com/docs/swift/pubnub-swift-sdk)