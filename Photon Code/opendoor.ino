
// -----------------------------------------
// Open your front door via an internet-connected microcontroller using HTTP POST-requests
// -----------------------------------------

//The following code was written to be run on the Particle Photon, a cloud-connected microcontroller.
//The device has 1 function, openDoor, which when called opens the front door by means of a hidden servo installed within the doorhandle.
//It has an evaluateSleep() function which can be activated to conserve energy in the case of it running on a battery. Once activated, the photon goes into sleep mode at night (thursdays 4am until 9 am, all other days 10 pm until 9 am)
//When in sleep mode, reactivate by pressing the reset button, in which case the photon will stay on for at least two hours

int transistor = D0; // The transistor which controls servo power is only connected to power upon openDoor functioncall, to prevent random servo jittering on startup and limit power usage
int boardLed = D7; 

int timesPerDayOpened = 0;
unsigned long resetTime;

Servo myServo;
int openPos = 90;
int closedPos = 178;

//Enter time in GMT+1, is automatically converted to UNIX time during execution
int sleepingHourUsual = 22;                 //o'clock in the evening
int sleepingHourFriday = 4;                 //o'clock on fridaymorning. This is Thursday's sleepcycle starting on friday, currently only works for am
int wakingHourUsual = 9;                    //latest wakeup time is 1 hour later. If reset during sleepcycle, value of Time.minute() is added to wakingHourUsual
int secondsToSleep;
double hoursToSleep;

bool deactivated;                           //Ignore all incoming requests until it is unlocked again


void setup() {
    resetTime = millis();
    correctDutchTimeToUnixTime();
    
    pinMode(transistor,OUTPUT);
    pinMode(boardLed,OUTPUT);
    
    deactivated = false;
    
    Particle.function("open",openDoor);
    Particle.function("activate",activatePhoton);
    Particle.function("deactivate",deactivatePhoton);
    Particle.variable("timesPerDayOpened", &timesPerDayOpened, INT);
    Particle.publish("Status", "Woken up", 60,PRIVATE);
    delay(2000);                          //delay to wait for power surge to have stopped
    myServo.attach(D1);
    digitalWrite(transistor,HIGH);
    myServo.write(closedPos);
    digitalWrite(transistor,LOW);
    myServo.detach();
    
}

void loop() {
    //evaluateSleep();
}



bool twoHoursSinceStartup() {
    bool twoHoursPassed = ((millis() - resetTime) >= 7200000);
    return twoHoursPassed;
}


void evaluateSleep() {
        if (sleepingTime(Time.weekday()) && twoHoursSinceStartup()) { 
        if (Time.hour() > wakingHourUsual)      //if sleeping starts at pm
        {   
            secondsToSleep = ((wakingHourUsual-1 + (24 - Time.hour())) * 3600) + ((60 - Time.minute())*60);
            hoursToSleep = (double) secondsToSleep / 3600;
            Particle.publish("Going to sleep, hours:", String(hoursToSleep,1), 60,PRIVATE);
            delay(5000);
            System.sleep(SLEEP_MODE_DEEP, secondsToSleep);                               //setup is only ran after deep sleep, needed for spark publish or check "device came online?"
            
            //digitalWrite(D7,HIGH);
            //delay(1000);
        } 
        else                                    //if sleeping starts at am
        {                                      
            secondsToSleep = ((wakingHourUsual-1 - Time.hour()) * 3600) + ((60 - Time.minute())*60);
            hoursToSleep = secondsToSleep / 3600;
            delay(5000);
            Particle.publish("Going to sleep, hours:", String(hoursToSleep,1), 60,PRIVATE);
            System.sleep(SLEEP_MODE_DEEP, secondsToSleep);                              //setup is only ran after deep sleep, needed for spark publish or check "device came online?"
            
            //digitalWrite(D7,HIGH);
            //delay(1000);
            
        }
        

    }
    //digitalWrite(D7,LOW);
    //delay(2000);
}



//returns if photon should sleep based on the weekday and current hour. Different sleep cycle for Thursday night/Friday morning
bool sleepingTime(int weekday) {
    bool sleepDuringCurrentHour;
    if (!(weekday == (5 || 6)))  {         //if not Thursday or Friday. This works for both pm and am as starting sleeptime
    
        //if time(am) inbetween am sleepstart and am sleepend || if time(pm) inbetween pm sleepstart and am sleepend || if time(am) inbetween pm sleepstart and am sleepend 
        sleepDuringCurrentHour = (Time.hour() < wakingHourUsual && Time.hour() >= sleepingHourUsual) ||
        (Time.hour() >= sleepingHourUsual  && sleepingHourUsual > wakingHourUsual) ||
        (Time.hour() < wakingHourUsual && sleepingHourUsual > wakingHourUsual);    
    
    } else if (weekday == 5) {          //if Thursday.
        
        //if time(am) inbetween am sleepstart and am sleepend || if time(pm) inbetween pm sleepstart and am sleepend || if time(am) inbetween pm sleepstart and am sleepend
        sleepDuringCurrentHour = (Time.hour() < wakingHourUsual && Time.hour() >= sleepingHourUsual) ||
        (Time.hour() < wakingHourUsual && sleepingHourUsual > wakingHourUsual);
        
    } else if (weekday == 6) {           //if Friday, since thursdays sleep cycle is started on fridaymorning. This works for am as starting sleeptime
    
        //if time(am) inbetween am sleepstart and am sleepend || if time(pm) after friday pm sleepstart
        sleepDuringCurrentHour = (Time.hour() < wakingHourUsual && Time.hour() >= sleepingHourFriday) ||
        (Time.hour() >= sleepingHourUsual && sleepingHourUsual > wakingHourUsual);

    }
    return sleepDuringCurrentHour;
}

int deactivatePhoton(String command) {
    if (command=="<INSERT_PASSWORD>") {
        deactivated = true;
        Particle.publish("Pushbullet", "Photon deactivated, blocking calls", PRIVATE);
        return 1;
    } else {
        Particle.publish("Pushbullet","Invalid Request",60,PRIVATE);
        return -1;
    }
}

int activatePhoton(String command) {
    if (command=="<INSERT_PASSWORD>") {
        deactivated = false;
        Particle.publish("Pushbullet", "Photon activated, accepting calls", PRIVATE);
        return 1;
    } else {
        Particle.publish("Pushbullet","Invalid Request",60,PRIVATE);
        return -1;
    }
    
}

int openDoor(String command) {
    /* Spark.functions always take a string as an argument and return an integer.
    */

    if (command=="<INSERT_PASSWORD>") {
        if(!deactivated) {
            myServo.attach(D1); 
            digitalWrite(transistor,HIGH);
            digitalWrite(boardLed,HIGH);
            myServo.write(openPos);
            delay(500);
            myServo.write(closedPos);
            delay(1000);
            digitalWrite(boardLed,LOW);
            digitalWrite(transistor,LOW);
            myServo.detach();
            Particle.publish("Pushbullet", "Front door opened", PRIVATE);
            timesPerDayOpened++;
        } else {
            Particle.publish("Pushbullet", "Photon locked, unlock first", PRIVATE);
        }
        return 1;
    } else {
        Particle.publish("Pushbullet","Invalid Request",60,PRIVATE);
        return -1;
    }
}

void correctDutchTimeToUnixTime() {
    sleepingHourUsual--;
    sleepingHourFriday--;
    wakingHourUsual--;
}


