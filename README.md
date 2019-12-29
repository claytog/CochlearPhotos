# CochlearPhotos

### Acknowledgements
CochlearPhotos uses two POD dependancies:

* [Alamofire](https://github.com/Alamofire/Alamofire)
* [GRDB](https://github.com/groue/GRDB.swift)

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

## Assumptions
* The user must have Location Services enabled within Settings.
* 
