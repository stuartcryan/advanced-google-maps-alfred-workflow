# Advanced Google Maps Workflow for Alfred

Easy searching of Google Maps including directions to or from work/home.

## Donations
This workflow represents many many hours effort of development, testing and rework. So if you love the workflow, get use out of it every day, and would love to see me continuing development, a donation is a great way. You can either [donate to me via Fundly (preferred)](https://fundly.com/alfred-workflows-continued-development#) which gives the option of a re-occurring donation and also has some suggestions, [donate to me via Patreon (if that is your preference)](https://www.patreon.com/stuartcryan) or [donate to me via Paypal](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=JM6E65M2GLXHE). 

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=JM6E65M2GLXHE" target="_blank"><img src="https://www.paypalobjects.com/en_AU/i/btn/btn_donateCC_LG.gif" border="0" alt="PayPal — The safer, easier way to pay online."></a>
<a href="https://www.patreon.com/bePatron?u=4157196" data-patreon-widget-type="become-patron-button"><img src="https://c5.patreon.com/external/logo/become_a_patron_button@2x.png" height="47" width="200"></a>

## 1.3.0 Release Special Information
Due to a bug with special characters which required a new way of handling the storage of home and work locations, you must now re-set up those locations in the latest version. Apologies, there was no way around this, HOWEVER, there are loads of awesome new features, which hopefully offset the inconvenience!

## Installation

1. Ensure you have Alfred installed with the Alfred Powerpack License
2. Download the .alfredworkflow file
3. Open the .alfredworkflow file to import into Alfred
4. To configure your home address run:
	mapsethome <home address including street number, name, postcode> (i.e. what you would type into Google Maps)
5. To configure your work address run:
	mapsetwork <work address including street number, name, postcode> (i.e. what you would type into Google Maps)

### Current Location Feature Setup
If you wish to use the 'Directions from Current Location - dirfc' command or the 'here' modifier, you will need to also install homebrew and the CoreLocationCLI package.

1. Install Homebrew using instructions from https://brew.sh/
2. Install the CoreLocationCLI utility by running the following command in a terminal 'brew cask install corelocationcli'.
3. Check your installed location by running 'which CoreLocationCLI'
4. Ensure the workflow environment variable on the Workflow Configuration screen matches the installed location.


## Usage

* dir <query> to <query> to <query> etc (seperate multiple addresses with " to " minus the quotes, and you will get a multiple location search)
* [NEW] dir now does all the heavy lifting. You can use the modifiers 'here' (current location, must have CoreLocationCLI installed), 'work' and 'home' in any query. For example 'dir home to work to new york'.
* [NEW] dirfc <query> this will use your current location (WiFi card must be active) to the destination.
* [NEW] dirtc <query> Show directions from query to current location
* [NEW] All commands now support the following modifiers: walk, bike, drive, pt (public transport). The modifier can be invoked by 'dirX <mode> <destination address>' e.g. 'dirfw pt <destination address>' will give you public transport directions. This also works with 'dir' and multiple waypoints.
* [NEW] Localisation now defaults to USA, hence make sure you update workflow parameters if you wish to use a different country code on the Google URL.
* dirfw <query> Show directions from Work to address
* dirfh <query> Show directions from Home to address
* dirtw <query> Show directions from query to Work address
* dirth <query> Show directions from query to Home address
* trafficw - Show traffic from Home to Work
* traffich - Show traffic from Work to Home
* [NEW] dir now supports up to 9 waypoints. For example 'dir origin to waypoint 1 to waypoint 2 etc to destination'

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## History

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
* [Technical Notebook Wiki](http://technicalnotebook.com/wiki)
* [Technical Notebook JIRA](http://technicalnotebook.com/jira)

## License

Released under the GNU GENERAL PUBLIC LICENSE Version 2, June 1991