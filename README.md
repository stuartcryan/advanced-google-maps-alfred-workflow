# Advanced Google and Apple Maps Workflow for Alfred

Easy directions from or to multiple locations, using either Google Maps or Apple Maps. Now includes custom locations in addition to just home and work, auto updating, and a wealth of new features for you to sink your teeth into.

## Getting to Know the Flow - New Course Location TBA
With the explosion of features, added configuration complexity, and awesomeness of the 2.0.0 major release (and overhaul), I have opted for a different tact, to ensure the support overhead is limited.

I have put together an hour long course that covers off every configuration option of the workflow, how to get up and running, getting into the advanced nitty gritty, and so on.

**Unfortunately, it has been brought to my attention that the platform I originally chose has non-existent quality control practices and have resulted in courses being stolen and re-sold on the platform, which I am unwilling to support. Where the new one ends up I will let you know ASAP**

Version 1.3.0 and version 2.0.0 represent almost the entirety of my holiday break over December-2017 and January-2018. I would anticipate I have over $6000 in time into this flow for these two versions alone, plus costs for the new logo, and costs for Closed Captioning in the Course. 

[So don't delay and check out the course, there are a few videos set to preview so you can try before you buy!](https://www.udemy.com/advanced-google-maps-and-apple-maps-workflow-for-alfred)

## Donations
Alternatively if a course is not your thing... You can just donate to me directly! If everyone who downloaded gave $20, that would make me a very happy camper and give me something back for my time, it would also enable me to have a custom icon set created for the flow.

So if you love the workflow, get use out of it every day, and would love to see me continuing development, a donation is a great way. You can either [donate to me via Fundly](https://fundly.com/alfred-workflows-continued-development#) which gives the option of a re-occurring donation and also has some suggestions, [donate to me via Patreon (if that is your preference)](https://www.patreon.com/stuartcryan) or [donate to me via Paypal which is nice and easy](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=JM6E65M2GLXHE). 

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=JM6E65M2GLXHE" target="_blank"><img src="https://www.paypalobjects.com/en_AU/i/btn/btn_donateCC_LG.gif" border="0" alt="PayPal — The safer, easier way to pay online."></a>
<a href="https://www.patreon.com/bePatron?u=4157196" data-patreon-widget-type="become-patron-button"><img src="https://c5.patreon.com/external/logo/become_a_patron_button@2x.png" height="47" width="200"></a>

## 2.0.0+ Release Compatibility Information
In 1.3.0 the home and work locations, required setting up again due to a bug with special characters.

In 2.0.0 the home and work locations have been moved out of the keychain (which was a legacy method of handling them before Alfred had workflow environment variables). Old locations can still be used as they would have without further intervention. However, the mapsethome and mapsetwork commands have now been removed. To add/update these now you must do so on the workflow environment variables config screen. I would also recommend you run 'zcleanmapsoldaddresses' to remove the old addresses from your Apple keychain.

## Installation

1. Ensure you have Alfred installed with the Alfred Powerpack License
2. Download the [Advanced_Google_Maps_Search.alfredworkflow](https://github.technicalnotebook.com/stuartcryan/advanced-google-maps-alfred-workflow/master/Advanced_Google_Maps_Search.alfredworkflow) file
3. Open the .alfredworkflow file to import into Alfred
4. Set up the workflow configuration parameters as you desire (see below for additional details), by clicking on the little [X] in the top right hand of the Workflow page in Alfred
5. Complete the advanced steps below to add additional (and awesome) functionality

### Current Location Feature Installation and Configuration
If you wish to use the 'Directions from Current Location - dirfc' command or the 'here' modifier, you will need to also install homebrew and the CoreLocationCLI package.

1. Install Homebrew using [instructions from https://brew.sh/](https://brew.sh/)
2. Install the CoreLocationCLI utility by running the following command in a terminal 'brew cask install corelocationcli'.
3. Check your installed location by running 'which CoreLocationCLI'
4. Ensure the workflow environment variable on the Workflow Configuration screen matches the installed location.

### Contact Address Handler Configuration
If you wish to use this workflow to handle directions to a contact's address you may do so by completing the following additional steps.

1. In Alfred's Preferences click on Features --> Contacts
2. Double click on the 'Address' field
3. In the dropdown, select "Search Contact Address with Advanced Google and Apple Maps Search"
4. Ensure you correctly configure the contactHandler parameter as per the instructions under the Configuration section.

### Fallback Search Setup
If you wish to use this workflow to handle fallback searches in Alfred, you can now do this too!

1. In Alfred's Preferences click on Features --> Default Results
2. Click the button to 'Setup Fallback Results'
3. Click the small + sign to add a new record
4. Select any of the available fallback searches provided by the workflow to add them to your personal fallback search results.

## Configuration

### Explanation of each of the Workflow Environment Variables
* contactHandler: Used as the default mechanism to handle Contact address searches. Supports two formats including "drive here to" (current location to Contact's address) "drive to here" (Contact's address to Current Location) or "('computerName:drive here to','default:drive here to')"
* CoreLocationCLIBinary: Defines the location of the installed CoreLocationCLIBinary. Supports two formats including "/usr/local/bin/CoreLocationCLI" or "('computerName:/some/other/location/CoreLocationCLI','default:/usr/local/bin/CoreLocationCLI')"
* currentLocationFallback: Used as the fallback address in case CoreLocationCLI is not installed, or fails (especially if WiFi is unavailable, or turned off). Supports two formats including "Some Address in Some State 20023" or "('computerName:home','someOtherComputerName:Some Address in Some State 20023','default:work')"
* customLocations: Supports custom location modifiers for all dir* commands. Please note, this does not dynamically add new dirfx or dirtx commands. Must be formatted in the following fashion: "('gym:49 Queens Rd, Five Dock NSW 2046','school:1A Harris Rd, Five Dock NSW 2046')"
* defaultTransportationMode: Defines the default transportation fallback mode if none is specified at runtime. Possible values include: "pt" for Public Transport, drive, walk or bike. Supports two formats including "bike" or "('computerName:pt','someOtherComputerName:walk','default:drive')"
* googleLocal: Defines which Google Locale to use such as 'com.au', 'com.tw' or 'com' as some examples. Supports two formats including "com.au" or "('computerName:com.au','someOtherComputerName:com.tw','default:com')"
* homeAddress: New storage location for Home Address. Supports two formats including "Some Address" or "('computerName:Some Address','someOtherComputerName:Another Address','default:A Third Address')"
* workAddress: New storage location for Work Address. Supports two formats including "Some Address" or "('computerName:Some Address','someOtherComputerName:Another Address','default:A Third Address')"
* mapsHandler: PLEASE NOTE this only supports a value of either "Google" or "Apple" and may not have a computer specific value. 

## Recommended Example Configuration for Workflow Environment Variables
* contactHandler: ('default:drive here to')
* CoreLocationCLIBinary: ('default:/usr/local/bin/CoreLocationCLI')
* currentLocationFallback: ('default:home')
* customLocations: ('gym:GYM ADDRESS','school:SCHOOL ADDRESS')
* defaultTransportationMode: ('default:drive')
* googleLocal: com
* homeAddress: Your Home Address
* workAddress: Your Work Address
* mapsHandler: Google

## Notes on Caveats with Apple Maps

Apple Maps does not support as many functions as Google Maps and there are two main areas that will cause graceful errors when using Apple Maps. If you attempt to use the 'bike' modifier anywhere, Apple Maps does not support such directions and therefore we gracefully tell you this won't work.

Secondly, Apple Maps does not support waypoints or building up an itinerary. Therefore if you attempt to use the dir command with more than just an origin and a destination (such as home to shops to work), we will gracefully error out and tell you such a function is not possible.

## Usage

* dir <transportModeModifier> <query> to <query> to <query> etc (seperate multiple addresses with " to " minus the quotes, and you will get a multiple location search when using Google Maps only)
* [NEW] dir now does all the heavy lifting. You can use the modifiers 'here' (current location, must have CoreLocationCLI installed), 'work' and 'home' in any query. For example 'dir home to work to new york'.
* [NEW] dirfc <query> this will use your current location (WiFi card must be active) to the destination.
* [NEW] dirtc <query> Show directions from query to current location
* [NEW] All commands now support the following modifiers: walk, bike, drive, pt (public transport). The modifier can be invoked by 'dirX <mode> <destination address>' e.g. 'dirfw pt <destination address>' will give you public transport directions. This also works with 'dir' and multiple waypoints.
* [NEW] Localisation now defaults to USA, hence make sure you update workflow parameters if you wish to use a different country code on the Google URL.
* dirfw <transportModeModifier> <query> Show directions from Work to address
* dirfh <transportModeModifier> <query> Show directions from Home to address
* dirtw <transportModeModifier> <query> Show directions from query to Work address
* dirth <transportModeModifier> <query> Show directions from query to Home address
* trafficw - Show traffic from Home to Work
* traffich - Show traffic from Work to Home
* [NEW] dir now supports up to 9 waypoints for Google Maps. For example 'dir <transportModeModifier> origin to waypoint 1 to waypoint 2 etc to destination'

## Integration hooks for Other Workflow Providers

This workflow now supports integration using external nodes. They suppor the same methods and modifiers as described for the rest of the workflow. This means you can now hook into this workflow to leverage the 'here', 'work', 'home' and other custom modifiers set up by a user, as well as provide routing directions based on your input. 

Please review the workflow for each of the hooks available.

## Contributing

1. Fork it!
2. Checkout the develop branch
3. Create your feature branch: 'feature/some-feature-name'
4. Commit your changes: 'feature/some-feature-name'
5. Merge your changes into 'develop'
5. Submit a pull request :D

## History
Version 2.0.1
* Fixed dirtw bike command... it hadn't been connected... after all the testing! #oops

Version 2.0.0
* Renamed workflow to 'Advanced Google and Apple Maps Workflow for Alfred'. Left bundleID intact deliberately
* Changed workflow logo to support new multi-brand mix
* Added feature for custom locations other than 'home' and 'work'
* Added default transportation mode setting
* Added fallback location setting in case there are issues with CoreLocationCLI
* Added hooks for Alfred fallback searches (for example if you load Alfred and just enter an address without invoking the workflow)
* Added multi-machine configuration parameters and provided a default catchall feature for this
* Added contact address handler functionality (to enable the workflow to serve as a Contact Address Handler hook)
* Migrated (future) work and home addresses out of keychain.
* Added keychain cleanup function once addresses have been manually migrated to workflow environment variables
* Implemented OneUpdater code by Vitor so updating will be simple as pie
* Externalised Perl code for much better gitifying, as well as better code reuse
* Added external triggers for other workflows to hook into
* Various code cleanups
* Significantly improved error handling to do things more gracefully
* Rectified issues with commas in addresses causing things to break a little
* Other minor bug fixes and improvements as I went along through the code, improved readability also

Version 1.3.1
* Fixed dirfh and dirfw to actually use home and work respectively, not here. #oops

Version 1.3.0 
* dirfc: Directions from Current Address. See the installation instructions above to install Homebrew and CoreLocationCLI
* dirtc: Directions to Current Address. See the installation instructions above to install Homebrew and CoreLocationCLI
* dir, dirfc and dirtc now support Google transit type (walk, drive, pt [public transport] and bike)
* dir now supports 'here'. Here anywhere in the transit plan translates to the current GPS coordinates using CoreLocationCLI. Technically this probably does away with the need for dirfc and dirtc, but, leaving them there for consistency.
* dir now supports 'work' and 'home' as modifiers
* Overhaul of changes to properly use Google API parameters
* Mass code cleanup and refactoring for simplification. Most flows now leverage the dir base code.
* Additional error handling implemented surrounding maximum number of waypoints
* Fixed a bug where special characters would not work in stored URLs
* Implemented a workflow environment variable for getting a local Google URL
* Changed to use Alfred's native URL opening functionality, this enables you to select a preferred browser

Version 1.2 - Actually this never made it out of beta, despite working, I have been kinda busy.

Version 1.1 - Set default search to be google.com rather than google.com.au

Version 1.0 - Initial Release

## Credits

Created by [Stuart Ryan](http://stuartryan.com). If you would like to get into contact you can do so via:
* [@StuartCRyan on Twitter](http://twitter.com/stuartcryan)
* [Stuart Ryan on LinkedIn](https://au.linkedin.com/in/stuartcryan)
* [Technical Notebook Blog](http://technicalnotebook.com)

## License

Released under the GNU GENERAL PUBLIC LICENSE Version 2, June 1991