# CochlearPhotos

### Acknowledgements
CochlearPhotos uses two POD dependancies:

* [Alamofire](https://github.com/Alamofire/Alamofire)
* [GRDB](https://github.com/groue/GRDB.swift)

Material Design

* [Material Icons](https://material.io/resources/icons)

### Product requirements
* Provide a map screen (using any map SDK of your choosing)
* Allow custom locations to be added from the map screen
* The user should be able to provide names for these locations
* Show pins for both default and custom locations on the map
* Provide a screen listing all locations, sorted by distance
* When locations are selected on either the map or list screen, show a detail screen
* In the detail screen, allow the user to enter notes about the location
* All information entered by the user must be persisted between app launches

### Technical requirements
* Locations JSON file: http://bit.ly/test-locations
* Third-party libraries are allowed, except when they solve the whole problem
* The app must include unit tests

## User Assumptions
### iOS Version Support
* Requires iOS 13.2
* Requires iPad or iPhone.

### Location Services
* Location Services must be enabled within iOS settings.
* Upon initial use of the app, authorisation must be accepted for location services.
### Onboarding
* An initial onboarding view will be presented to describe functionality.
* During onboarding, default locations will be downloaded to the app.
* After locations are downloaded, a button labelled "OK LET'S GO" will appear.
* Pressing this button will present the location map view.
### Map View
* A map view will take up most of the screen and is interactive.
* The map view can be navigated panning and zooming the view.
* Locations are viewed as pins (annotations) on the map view.
* Pressing a pin will present a location detail view.
* Long-pressing (press for 2 seconds) on any point on the map view will create a new pin, and present the location detail view.
* A button (with target image) exists to navigate to the current user location.
### Location List
* A location list of default locations will initially be presented over the map view.
* The location list can be moved up and down to reveal more or less of the map view.
* Default location cells have a gray background.
* For distances less than 1 kilometre, the distance will be displayed in meters with no decimal place.
* For distances between than 1 kilometre and 10 kilometres, the distance will be displayed in kilometres to one decimal place.
* For distances greater than 10 kilometres, the distance will be displayed in kilometres with no decimal place.
### Location Detail
* For Default locations, the name is read-only, and notes is editable.
* For Custom locations, both name and notes is editable.
* Tapping on the fields will take the field into edit mode (where allowable).
* Pressing the "Back" button will automatically save changes.
* Custom locations allow for both the location name and notes to be edited.
### User Interface
* Supports landscape and portrait mode.
* Supports Dark mode.

