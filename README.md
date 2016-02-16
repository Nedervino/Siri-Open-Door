# Siri, Open Front Door
Inspired by the fact that our intercom is currently not working, this small project includes code for a Particle Photon microcontroller used as a replacement door opener, and a Swift app used to send the command via a cloud platform to this microcontroller. The door can either be opened by pressing a button in the app itself, or by asking Siri to "Open front door". I've also written a small webapp for direct access from my laptop.

###Swift App
Due to the fact that I wanted maximum ease of use, not needing to first search for the required app and then having to press the button, I decided to look into Siri as an alternative way to control the door besides the app GUI. Since Apple does not allow custom Siri commands and requires an expensive MFI license for homekit developers, I eventually managed to bypass these limits by simply creating an app that upon opening automatically connects to the cloud, finds the device and fires the command. After it receives a response that the request was succesful it shuts down using exit(0). By calling the app "voordeur" ("front door"), since Siri accepts the 'open' command for apps, this is now a valid action according to Siri.

###Photon Code
The microcontroller was placed in the hallway, making use of already present wiring to link it to a small servo hidden within the doorhandle. Once the swift app sends a request to my Particle Cloud, the cloud checks if the photon is online and if so, the request is sent through to the photon. The microcontroller then activates power supply to the servo through a transistor and opens the door. It uses a webhook listening to this event to send an HTTP request to the PushBullet API, so that my phone receives push notifications of both succesful and unsuccesful openings of the door.

###Webapp
I've included a small responsive webapp for control when I'm on my laptop, which is currently deployed on Google App Engine. It runs on PHP and allows only visitors logged in on either of the three Google Accounts registered as belonging to the house residents
