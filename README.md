# Siri, Open Front Door
This project stems from the time Apple did not allow third party developers to interact with Siri yet. Inspired by the fact that the intercom for our third floor apartment was not working, me and my two roommates reaching peak laziness levels around that time, and my interest in microcontrollers, I decided to create my own voice-enabled electronic lock.

This small project includes code for a Particle Photon microcontroller used as a replacement door opener, and a Swift app used to send unlock commands to the microcontroller via the Particle Cloud platform. The door can either be opened by asking Siri to "Open front door", or by pressing a button in the app itself. It also features a small web app for direct access from our laptops.

### Swift App
For faster access and to prevent having to constantly search for the required app and waiting for it to load before pressing the button, I decided to look into Siri as an alternative way to control the door besides the app GUI. Since Apple does not allow custom Siri commands and requires an expensive MFI license for homekit developers, I eventually managed to bypass these limits by simply creating an app that upon opening automatically connects to the cloud, finds the device and fires the command. After it receives a response that the request was successful it shuts down using exit(0) (thus preventing use of this solution for any app needing to pass App Store submission). By calling the app "voordeur" ("front door"), since Siri accepts the 'open' command for apps, this is now a valid action according to Siri.

### Photon Code
The wifi-enabled [Photon microcontroller](https://store.particle.io/#photon) was mounted in a small box against our front door, making use of already present wiring for the broken intercom to power it. Spare space inside the old electronic door lock allowed for the placing of a [micro servo](https://hobbyking.com/en_us/hxt900-micro-servo-1-6kg-0-12sec-9g.html) inside the lock, to pull back and activate the door knob used when opening the door from the inside. Once the Particle cloud has received a request from the Swift app, it checks if the microcontroller is online and if so, the request is forwarded to the microcontroller. This then activates power supply to the servo through a transistor and pulls back the servo lever to open the door. To receive a notification of every successful/unsuccessful unlock on both my computer and iPhone, the microcontroller publishes these to a PushBullet API webhook, which pushes notifications to both my computer and phone.

### Web App
For easy access from a laptop whenever my phone isn't around, the project also includes a small password-enabled web app for unlocking, which was deployed on Google App Engine. Visitors needed to be logged in on one of the three Google Accounts belonging to the house residents to be able to use the app.

### Demo
A short recording of both the project in action and our genuine excitement about not having to run downstairs anymore for every guest or package delivery can be found [here](https://www.facebook.com/t.nederveen/videos/vb.575399338/10153714596014339)
