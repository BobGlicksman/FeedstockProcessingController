//Software for a feedstock processing Controller.
//  name:  Processing_11 (release version 1.101)
//  author:  Bob Glicksman;  date: 2/28/2012
// 
//  (c) Bob Glicksman 2012; all rights reserved.
//  Released under Creative Commons license Attribution-ShareAlike 3.0.  To view a copy of this license, 
//  visit http://creativecommons.org/licenses/by-sa/3.0/ or send a letter to Creative Commons, 
//  444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//  
//  This Controller monitors the temperature of a process and, optionally, controls a heat source to keep the 
//  process temperature close to a user-preset temperature value.  The user may preset the desired temperature
//  and have the Controller continuously monitor the process (probe) temperature and alarm the user if the 
//  process temperature goes outside of upper and lower limit values.  The preset temperature establishes 
//  default upper and lower alarm limits, but the user may modify these as desired.  A piercing audible alert 
//  is used to sound the alarm.  The user may mute the alert by pressing the DOWN button on the controller.  
//  The alert will mute itself when the process temperature returns to within the upper and lower limits, or 
//  the limits are altered to place the process temperature back in range.  The mute will automatically re-arm 
//  itself when the temperature returns to within the user-set upper and lower limits.
//
//  The Controller continuously monitors the process temperature (temperature probe value) and, when the 
//  heater function is enabled (enabled by default), turns the heater ON when the process temperature is
//  one-half degree less than the desired (setpoint) temperature and turns the heater off when the process
//  temperature is one-half degree higher than the desired (setpoint) temperature.  The user can enable or disable
//  the heater function.  The thermostat deadband of +/- 0.5 degree can be changed via a defined constant in 
//  this software, in order to accomodate the requirements of various types of heaters.  The software counts
//  and displays the total number of seconds that the heater power is on in order to provide an estimate of the
//  total energy used in the process.  The heater on-time accumulator can be reset by the user after the processing
//  experiment is complete.
//
//  The Controller provides a count-down stop watch function.  The user may set the stop watch for any time
//  up to 9 hours, in one minute increments.  The Controller issues a series of beeps when the time has expired.
//
//  The Controller uses a 4 line x 20 character per line LCD display to:
//    Line 1:  display the current process temperature and the stop watch countdown time.
//    Line 2:  display the user preset desired process temperature and the accumulated heater on-time (seconds).
//    Line 3:  display the user preset upper and lower temperature alarm limits.
//    Line 4:  display the current mode.  The next to the last position on this line displays "E" if the thermostat
//              function is enabled, or "D" if it is disabled.  The last position on this line has a "spinner" that 
//              spins when the heater is turned on and displays "X" when the heater is turned off.
//
//  The Controller is mode driven.  In the RUN mode, the stop watch timer is counting down to zero.  The Controller
//  beeps the alert 5 times when the stop watch time counts down to zero.  When not in the RUN mode, the 
//  mode provides the user with a means to set stop watch countdown time, the desired process temperature,
//  the upper and lower temperature alarm limits, enable/disable the heater function, and resent the heater 
//  on-time accumulator.  The Contoller continues to monitor and display current process temperature regardless 
//  of the mode, but stops the count down timer when not in the RUN mode in order to assist the user in setting 
//  the stop watch time.
//
//  A "deadman" watchdog timer automtically returns the Controller to the RUN mode if no button is pressed
//  within 20 seconds (configurable via a defined constant in this software), when not in the RUN mode.
//  
//  The pushbuttons on the Controller operate as follows:
//    MENU:  when in RUN mode, toggles out of RUN into stop watch time setting.  When not in RUN mode, depressing
//            MENU always immdiately returns the Controller to the run mode, "short circuiting" other setup functions.
//    SELECT:  toggles though all modes of the Controller:  RUN, set hours X1, set minutes x15, set minutes x1,
//            set temperature x10, set temperature x1, set upper limit x10, set upper limit x1, set lower limit x10
//            set lower limit x1, enable/disable the heater, reset the heat on-time accumulator, and then back to RUN.
//    UP:  does nothing in RUN mode.  In a value setting mode, increases the parameter indicated by the mode by the value
//            indicated (15, 10, 1, etc.).  In the HEATER ENABLE mode, enables the heater thermostat function.
//    DOWN:  in the RUN mode, depressing DOWN will mute the temperature out-of-limits alarm.  The alarm will remain
//            muted until the process temperature returns to within the upper and lower temperature limits.  In the 
//            reset heater on-time accumulator mode, depressing the DOWN button will reset the accumulator to zero. In a 
//            value setting mode, decreases the parameter indicated by the mode by the value indicated (15, 10, 1, etc.).  
//            In HEATER ENABLE mode, disables the heater thermostat function.
//
//  The Controller uses digital output #1 to control a solid state relay or similar device that will, in turn, active
//  and deactivate a heater unit that provides heat to the process under control.  Use of this function is optional
//  and the function can be disabled by the user, ensuring that any connected heater will not turn on.
//
//  The Controller can use any temperature probe to monitor process temperature that is based upon the Maxim/
//  Dallas Semiconductor DS18B20 temperature sensor chip.  An 8" long stainless steel probe from Brewers Hardware
//  http://www.brewershardware.com/BrewTroller-Straight-Mount-Sensors/
//  has been used in development and testing.
//      
//  Known bugs and issues:
//  (1) LCD display does not always initialize properly on power up. This is a display hardware issue.  
//      Unplugging and replugging the power to the controller will usually solve the problem.  Opening 
//      the Controller box cover and depressing the RESET button on the Shield Board will always resolve the problem.
//  (2) By design, the stop watch counter maintains its current value when exiting the RUN mode.  This is so the user
//      may change desired temperature setting and/or limits in mid process step and resume the process time-out where
//      they left off.  The user can, of course, also change the stop watch time.  However, the user can
//      only set stop watch hours and minutes.  The seconds will remain on the clock, not under the user's control.  At
//      most, this will result in 59 seconds more than the user desires, however the user can always set minutes to
//      one less resulting in at most 30 seconds more-or-less than desired.
//  (3) If the stop watch time expires (hits zero) while the temperature limit alarm is sounding, the 5 timeout beeps
//      will not be heard.  This is because the same device (alert module) is used to make both sounds, and the temperature
//      limit alarm is a constant tone.  This does not present a problem as the user is alerted by the alarm, but the 
//      user should check the stop watch time when attending to a temperature limit alarm.
//  (4) Temperature display format is correct with 2 and 3 digit temperatures (integer parts) but there is no formatting
//      for temperature settings in single digits or negative.  Code to handle these situations has not been developed because
//      low temperatures are out of scope of this application.  However, in order to maintain the display formatting integrity
//      should a low temperature be set, single digit and lower temperatures display the text "LOW" in lieu of a number.  
//  (5) Temperature offsets and defaults are numerically the same for Centigrade or Farenheight displays.  They have been
//      selected as proper defaults for Farenheight and probably should be changed for Centigrade to more reasonable 
//      values.

/********************************* GLOBAL CONSTANTS AND VARIABLES ******************************************/
#define DEBUG false  // debug mode sends debugging data to the serial monitor via the serial port.
#define Adafruit_LCD false  // true for Adafruit LCD, false for B2QCshop LCD

// includes for the DS18B20 temperature sensors
#include <OneWire.h>    // the one wire bus library
#include <DallasTemperature.h>  // the DS18B20 chip library -- uses the OneWire library

// includes for the LCD/i2c
#include <Wire.h>      // the i2c library:  clock on Analog pin 5; data on analog pin 4
#include <LiquidTWI.h>  // the high performance library (patched per Adafruit chat)
#include <LiquidCrystal_I2C.h> // the B2QC LCD library (also high performance)

// Define the data, clock and latch pins for the input and output shift registers
//  output shift register is 74HC595 
const int out_data = 6;
const int out_clock = 5;
const int out_latch = 4;

// input shift register is 74HC165 (reads push button switches)
const int in_data = 7;
const int in_clock = 9;
const int in_latch = 8;

// constants for the control panel switches
//  codes below are returned when a switch is activated, or NO_ACTION.  Multiple switch
//  activations result in the first switch in the list being the returned value.
const int NO_ACTION =  0x00;
const int MENU =       0x01;
const int CENTER =     0x02;
const int UP =         0x03;
const int DOWN =       0x04;
//const int LEFT =       0x05;  // left and right are no longer used in the controller design
//const int RIGHT =      0x06;  // left and right are no longer used in the controller design
const int ERROR =      0xFF;  //just in case -- should never occur!
const unsigned long DEBOUNCE_TIME = 20L;  //20 milliseconds to debounce switches.

// constants for the digital outputs
//  codes below can be used in the setOutput(output, value) function.
//  Output codes:
const byte HEATING_ELEMENT =   B00000001; // digital control of the heater for the process
const byte WATER_FEED_PUMP =   B00000010; // not used - reserved for future improvement
const byte BEER_FEED_PUMP =    B00000100; // not used - reserved for future improvement
const byte Y_VALVE =           B00001000; // not used - reserved for future improvement
const byte PRODUCT_VALVE =     B00010000; // not used - reserved for future improvement
const byte SPARE1 =            B00100000; // not used - reserved for future improvement
const byte ALARM =             B01000000; // not used - reserved for future improvement
const byte ALERT =             B10000000; // not used - reserved for future improvement

const byte INVERT_MASK =       B00000000;  // set a bit to 1 for active low, 0 for active high

// Value codes:
const boolean OFF = false;
const boolean ON = true;

// Constants for the DS18B20 temperature sensor switches
const int oneWireBusPin = 3;            // DIO pin #3 is the one wire bus for all DS18B20 sensors
const int temperatureResolution = 12;   // 12 bit resolution is the maximum for these devices
const int numberOfSensors = 1;          // a single DS18B20-based Brewtroller temperature probe for this application

// Constants for the LCD "spinners"
byte backSlash[8] = {B00000, B10000, B01000, B00100, B00010, B00001, B00000};  // make a backslash character
const char spinner[] = {'|', '/', '-', 0}; // sequence of symbols for the spinner, loc 0 is the backslash char
const long spinnerDelayTime = 250L;    // 250 milliseconds delay for spinner asthetics

// Constants for setPoint and limit temperature settings
const float DEFAULT_SET_POINT = 68.0F;  // initial value for the setpoint temperature
const float LIMIT_OFFSET = 10.0F;       // upper limit is setPointTemperature + LIMIT_OFFSET, lower limit is -LIMIT_OFFSET
const float THERMOSTAT_BAND = 0.5F;     // thermostat function has hysteresis of +/- 0.5 degree.
const boolean Centigrade = false;        // false for Farenheight, true for Centigrade
const unsigned long HEAT_DISPLAY_LIMIT = 99999999L; // limit for heater on time accumulation: 99,999 seconds

// Constants for the user mode
const byte RUN = 0;
const byte HR_X1 = 1;
const byte MIN_X15 = 2;
const byte MIN_X1 = 3;
const byte SET_POINT_X10 = 4;
const byte SET_POINT_X1 = 5;
const byte U_LIMIT_X10 = 6;
const byte U_LIMIT_X1 = 7;
const byte L_LIMIT_X10 = 8;
const byte L_LIMIT_X1 = 9;
const byte HEATER_EN = 10;
const byte HEAT_TIME_RST = 11;

const String modeText[] = { "* RUN             ", 
                            "* set hours x1    ",
                            "* set mins x15    ",
                            "* set mins x1     ",
                            "* set temp x10    ", 
                            "* set temp x1     ", 
                            "* set U limit x10 ", 
                            "* set U limit x1  ", 
                            "* set L limit x10 ", 
                            "* set L limit x1  ",
                            "* heater enable   ",
                            "* heat time reset "};

// Deadman timeout
const unsigned long DEADMAN_TIMEOUT = 20000L;  //20 seconds deadman timeout

// Global variables for pushbutton switches and output controls
int switchCount; //test the debouncing - count should only increase by 1 for each switch activation
byte output; //variable to hold the contents for the output shift register

// Global variables for DS18B20 sensors
OneWire oneWire(oneWireBusPin);   // create an instance of the one wire bus
DallasTemperature sensors(&oneWire);  // create instance of DallasTemperature devices on the one wire bus
DeviceAddress processTemperatureProbeAddress;  // array to hold the device ID code for the process monitoring temperature probe
float processTemperature = 0.0F;    // the current value of the process temperature probe reading
float setPointTemperature = DEFAULT_SET_POINT;  // the desired temperature (setpoint)
float upperLimitTemperature;  // the upper temperature limit above which the alarm will sound.
float lowerLimitTemperature;  // the lower temperature limit below which the alarm will sound.


// Global variables for LCD
LiquidTWI lcdA(0); // create an Adafruit LCD instance on the i2c bus, address 0
LiquidCrystal_I2C lcdB(0x27, 20, 4); // create a B2QCshop LCD instance on the i2c bus, address 0x27
#if Adafruit_LCD
  #define lcd lcdA
#else
  #define lcd lcdB
#endif
boolean spinnerState = OFF;  // initialize spinner to OFF

// stopwatch timer remaining time
int stopWatch;

// user mode (use defined constants above):
byte mode = RUN;

// thermostat globals
boolean heatEnable = ON;   // true if thermostat function is enabled, false if disabled
unsigned long heatTime = 0L;  // accumulate the time that the heater is on


/********************************* END OF GLOBAL CONSTANTS AND VARIABLES ***********************************/

/********************************* BEGINNING OF setup() ****************************************************/
void setup()
{
  // define the Uno pins for the output shift register 74HC595
  pinMode (out_data, OUTPUT);
  pinMode (out_clock, OUTPUT);
  pinMode (out_latch, OUTPUT);
 
  // define the Uno pins for the input shift register 74HC165 
  pinMode (in_data, INPUT);
  pinMode (in_clock, OUTPUT);
  pinMode (in_latch, OUTPUT);
  
  //debug mode -- send switch activation code and count to the serial monitor
  if (DEBUG)
  {
    Serial.begin (9600);
    switchCount = 0; //test the debouncing
  }
  
  // clear all output controls at the start
  updateOutputShiftRegister(B00000000);
  
  // detect the DS18B20 temperature sensor and get its addresses
  sensors.begin();      // startup the temperature sensor instance
  if (DEBUG)
  {
    int numSensors = sensors.getDeviceCount();  // how many are found on the bus?
    if ( numSensors == numberOfSensors)
    {
      Serial.println ("Found all devices - OK!");
    }  else
    {
      Serial.print ("Found ");
      Serial.print ( numSensors );
      Serial.println (" sensors - ERROR!!");
    }
  }
  
  // Get the address for the temperature sensor
  //  or the address can be manually set as an alternative
  sensors.getAddress ( processTemperatureProbeAddress, 0 );
  sensors.setResolution ( temperatureResolution ); // set the resolution of all temperature sensors to 12 bits
  sensors.setWaitForConversion ( false ); // set the sensors for non-blocking operation
  
 // Set up the LCD - always part of setup()
  if ( Adafruit_LCD )
  {
    lcdA.begin ( 20, 4 );  // startup the Adafruit lcd instance for 20x4 LCD
  }
  else
  {    
    lcdB.init();  // startup the B2QCshop lcd instance
  }
  
  lcd.setBacklight ( HIGH );
  lcd.createChar ( 0, backSlash ); // Write the backslash char into LCD char loc 0
  
// Display the main screen 
  lcd.clear();
  
  // first line
  lcd.setCursor ( 0, 0 ); 
  lcd.print ( "T: xxx.x" );
  lcd.setCursor ( 8, 0 );
  if ( Centigrade )
  {
    lcd.write ( 'C' );
  } else
  {
    lcd.write ( 'F' );
  }
  lcd.setCursor ( 9, 0 );
  lcd.print ( " S: h:mm:ss" );
  
  // second line
  lcd.setCursor ( 0, 1 ); 
  lcd.print ( "Set: xxx" );
  lcd.setCursor ( 8, 1 );
  if ( Centigrade )
  {
    lcd.write ( 'C' );
  } else
  {
    lcd.write ( 'F' );
  }
  lcd.setCursor ( 9, 1 );
  lcd.print ( "  H:       " ); 
  
  // third line
  lcd.setCursor ( 0, 2 ); 
  lcd.print ( "Upr: xxx" );
  lcd.setCursor ( 8, 2 );
  if ( Centigrade )
  {
    lcd.write ( 'C' );
  } else
  {
    lcd.write ( 'F' );
  }
  lcd.setCursor ( 9, 2 );
  lcd.print ( "  Lwr: xxx" ); 
  lcd.setCursor ( 19, 2 );
  if ( Centigrade )
  {
    lcd.write ( 'C' );
  } else
  {
    lcd.write ( 'F' );
  }  

  // fourth line for status
  lcd.setCursor ( 0, 3 );
  lcd.print ( modeText[mode] );
  lcd.setCursor ( 18, 3 );
  lcd.print ("E");
  
  // defaults for temperature limits
  upperLimitTemperature = setPointTemperature + LIMIT_OFFSET;
  lowerLimitTemperature = setPointTemperature - LIMIT_OFFSET;
  
  lcd.setCursor ( 5, 1 );
  formattedPrint ( setPointTemperature, false );
  
  lcd.setCursor ( 14, 1 );
  lcd.print (heatTime);
  
  lcd.setCursor ( 5, 2 );
  formattedPrint ( upperLimitTemperature, false );
  lcd.setCursor ( 16, 2 );
  formattedPrint ( lowerLimitTemperature, false );
  
  setOutput (HEATING_ELEMENT, OFF);
  setSpinner (OFF);  
  
  stopWatch = 0;
  displayTime ( stopWatch );
  
}
/********************************* END OF setup() **********************************************************/

/********************************* BEGINNING OF loop() *****************************************************/
// The main loop reacts to push button activations as described above. It reads the process temperature and
//  maintains the display of the process temperature regardless of mode.  In the RUN mode, the main loop
//  continuously compares the process temperature to the upper and lower limits and sounds the alarm for out
//  of limit temperature unless the alarm is muted.  The main loop re-arms the mute when the the process 
//  temperature returns within the limits.  
// The main loop controls the setting of the stop watch time, desired temperature and temperature upper and
//  lower limits and alarm muting.  When in RUN mode, the main loop maintains the count-down of the stop
//  watch timer and activates the timeout beep when when time hits zero.
// The main loop uses functions to implement the major activities.  All timing is non-blocking to allow
//  completely parallel and overlapping operation of all critical time functions such as timekeeping,
//  switch activation/debouncing, temperature sensor reading/conversion, and alert beeping.

void loop()
{ 
  int switchValue; //hold the pushbutton switch return code
  static boolean muteAlarm = false;   // if true, mutes the alarm until the process temperature is back 
                                      //   between upper and lower limits
  static boolean alarmFlag = false;   // if true, starts the alert tone, if false, turns alert tone off 
                                      //  unless timeout is beeping
  static boolean beepFlag = false;    // true is a trigger to start the stop-watch beeper; false is used 
                                      //   to continue the non-blocking function without resetting
  static boolean countDown = false;   // if true, begins the process of decrementing the stopWatch timer
  static unsigned long startTimeT;    // holds the system time when entering the run mode
  unsigned long newStartTimeT;        // temporary storage for new system time
  int differenceT;                    // difference between current system time and the startTime
  
  // Obtain a new pushbutton activation code when a button is depressed
  switchValue = readSwitches();
  
  // Main "switch" function to process each pushbutton activation according to Controller mode
  //  Each pushbutton "case" is evaluated according to the Controller mode to determine the resulting
  //  action.
  
  switch (switchValue)
  {
    case NO_ACTION:
      break;
      
    case MENU: 
      deadman ( true );  // reset the deadman watchdog   
      if ( (mode != RUN) )  // not run mode --> go directly to run mode
      {
        mode = RUN;
        countDown = true;  
        startTimeT = millis();  
      } else                // was in RUN mode, proceed to exit run 
      {
        mode = HR_X1;  // was the run mode, now set time hour x1 mode
        countDown = false;   
      }     
      // Update the display of the current mode
      lcd.setCursor ( 0, 3);
      lcd.print ( modeText[mode] );      
      break;
      
    case CENTER:  
      deadman ( true );  // reset the deadman watchdog
      if ( mode >= HEAT_TIME_RST )  // Last of the modes in sequence, return to RUN
      {
        mode = RUN;  
        countDown = true;  
        startTimeT = millis();     
      } else                    // not the last mode, go to the next mode in sequence
      {
        mode++;
        countDown = false; 
      }
      // Update the display of the current mode      
      lcd.setCursor ( 0, 3);
      lcd.print ( modeText[mode] ); 
      break;
      
    case UP:
      deadman ( true );  // reset the deadman watchdog
      switch( mode )    // the UP button acts according to the current mode
      {
        case RUN:       // RUN mode - do nothing
        {
          break;
        }
        
        case HR_X1:      // Set Hour x 1
        {
          stopWatch = changeTime (stopWatch, 3600);  // increment the time by one hour = 3600 seconds
          displayTime ( stopWatch );          
          break;
        }
        
        case MIN_X15:    // Set minutes in increments of 15
        {
          stopWatch = changeTime (stopWatch, 900);  // increment the time by 15 mins = 900 seconds 
          displayTime ( stopWatch );        
          break;
        }
 
        case MIN_X1:     // Set minutes in increments of 1
        {       
          stopWatch = changeTime (stopWatch, 60);  // increment the time by 1 min = 60 seconds
          displayTime ( stopWatch );          
          break;
        }

        case SET_POINT_X10: // in TEMP x10 mode, increment setpoint and limits by 10
        {
          setPointTemperature += 10.0F;
          upperLimitTemperature = setPointTemperature + LIMIT_OFFSET;
          lowerLimitTemperature = setPointTemperature - LIMIT_OFFSET;
          
          // Update the display of the current temperature settings  
          lcd.setCursor ( 5, 1 );
          formattedPrint ( setPointTemperature, false ); 
          lcd.setCursor ( 5 , 2 );
          formattedPrint ( upperLimitTemperature, false ); 
          lcd.setCursor ( 16 , 2);
          formattedPrint ( lowerLimitTemperature, false );         
          break; 
        }
        
        case SET_POINT_X1: // in TEMP x1 mode, increment setpoint and limits by 1
        {
          setPointTemperature += 1.0F;
          upperLimitTemperature = setPointTemperature + LIMIT_OFFSET;
          lowerLimitTemperature = setPointTemperature - LIMIT_OFFSET;
          
          // Update the display of the current temperature settings
          lcd.setCursor ( 5, 1 );
          formattedPrint ( setPointTemperature, false ); 
          lcd.setCursor ( 5 , 2 );
          formattedPrint ( upperLimitTemperature, false ); 
          lcd.setCursor ( 16 , 2);
          formattedPrint ( lowerLimitTemperature, false ); 
          break; 
        }

        case U_LIMIT_X10: // in UPPER LIMIT x10 mode, increment upper limit by 10
        { 
          upperLimitTemperature += 10.0F;
          
          // Update display with new upper limit
          lcd.setCursor ( 5, 2 );
          formattedPrint ( upperLimitTemperature, false ); 
          break; 
        } 

        case U_LIMIT_X1: // in UPPER LIMIT x1 mode, increment upper limit by 1 
        { 
          upperLimitTemperature += 1.0F;
          
          // Update display with new upper limit
          lcd.setCursor ( 5, 2 );
          formattedPrint ( upperLimitTemperature, false ); 
          break; 
        }    

       case L_LIMIT_X10: // in LOWER LIMIT x10 mode, decrement lower limit by 10  
        { 
          lowerLimitTemperature += 10.0F;
          
         // Update display with new lower limit          
          lcd.setCursor ( 16, 2 );
          formattedPrint ( lowerLimitTemperature, false ); 
          break; 
        }     
        
        case L_LIMIT_X1: // in LOWER LIMIT x1 mode, decrement lower limit by 1   
        { 
          lowerLimitTemperature += 1.0F;
          
         // Update display with new lower limit            
          lcd.setCursor ( 16, 2 );
          formattedPrint ( lowerLimitTemperature, false ); 
          break; 
        }
        case HEATER_EN: // in HEATER ENABLE mode, enable the heater
        {
          heatEnable = ON;
          lcd.setCursor( 18, 3 );
          lcd.print("E"); 
        }
        
        default:
        {
          break;
        }
      }
      break;
      
    case DOWN:
       deadman ( true );  // reset the deadman watchdog
       switch( mode )    // the DOWN button acts according to the current mode
      {
        case RUN:        // RUN mode - mute the alarm
        {
          muteAlarm = true;
          lcd.setCursor (13,3);
          lcd.print ( "MUTE");
          break;
        }
  
        case HR_X1:      // Set Hour x 1
        {
          stopWatch = changeTime (stopWatch, -3600);  // decrement the time by one hour = 3600 seconds
          displayTime ( stopWatch );          
          break;
        }
        
        case MIN_X15:      // Set minutes in increments of 15
        {
          stopWatch = changeTime (stopWatch, -900);  // decrement the time by 15 mins = 900 seconds 
          displayTime ( stopWatch );        
          break;
        }
 
        case MIN_X1:       // Set minutes in increments of 1
        {       
          stopWatch = changeTime (stopWatch, -60);  // decrement the time by 1 min = 60 seconds
          displayTime ( stopWatch );          
          break;
        }
        case SET_POINT_X10: // in TEMP x10 mode, decrement setpoint and limits by 10
        {
          setPointTemperature -= 10.0F;
          upperLimitTemperature = setPointTemperature + LIMIT_OFFSET;
          lowerLimitTemperature = setPointTemperature - LIMIT_OFFSET;
          
          // Update the display of the current temperature settings 
          lcd.setCursor ( 5, 1 );
          formattedPrint ( setPointTemperature, false ); 
          lcd.setCursor ( 5 , 2 );
          formattedPrint ( upperLimitTemperature, false ); 
          lcd.setCursor ( 16 , 2);
          formattedPrint ( lowerLimitTemperature, false );     
          break; 
        }

        case SET_POINT_X1: // in TEMP x1 mode, decrement setpoint and limits by 1
        {
          setPointTemperature -= 1.0F;
          upperLimitTemperature = setPointTemperature + LIMIT_OFFSET;
          lowerLimitTemperature = setPointTemperature - LIMIT_OFFSET;
          
          // Update the display of the current temperature settings          
          lcd.setCursor ( 5, 1 );
          formattedPrint ( setPointTemperature, false ); 
          lcd.setCursor ( 5 , 2 );
          formattedPrint ( upperLimitTemperature, false ); 
          lcd.setCursor ( 16 , 2);
          formattedPrint ( lowerLimitTemperature, false );     
          break; 
        }

        case U_LIMIT_X10: // in UPPER LIMIT x10 mode, decrement upper limit by 10
        { 
          upperLimitTemperature -= 10.0F;
          
          // Update display with new upper limit
          lcd.setCursor ( 5, 2 );
          formattedPrint ( upperLimitTemperature, false ); 
          break; 
        } 

        case U_LIMIT_X1: // in UPPER LIMIT x1 mode, decrement upper limit by 1  
        { 
          upperLimitTemperature -= 1.0F;
          
          // Update display with new upper limit         
          lcd.setCursor ( 5, 2 );
          formattedPrint ( upperLimitTemperature, false ); 
          break; 
        }    

       case L_LIMIT_X10: // in LOWER LIMIT x10 mode, decrement lower limit by 10  
        { 
          lowerLimitTemperature -= 10.0F;
          
          // Update display with new lower limit             
          lcd.setCursor ( 16, 2 );
          formattedPrint ( lowerLimitTemperature, false ); 
          break; 
        }     

        case L_LIMIT_X1: // in LOWER LIMIT x1 mode, decrement lower limit by 1  
        { 
          lowerLimitTemperature -= 1.0F;
          
          // Update display with new lower limit         
          lcd.setCursor ( 16, 2 );
          formattedPrint ( lowerLimitTemperature, false ); 
          break; 
        } 

        case HEATER_EN: // in HEATER ENABLE mode, disable the heater
        {
          heatEnable = OFF;
          lcd.setCursor( 18, 3 );
          lcd.print("D"); 
          break;
        }
        
        case HEAT_TIME_RST: // reset the heat time accumulator
        {
          heatTime = 0L;
          // clear out accumulator display field
          lcd.setCursor( 13, 1 );
          lcd.print("       ");
          break;
        }
        
        default:
        {
          break;
        }
      }
      break; 
      
    default:
      break; 
  }   
      
  if (switchValue != NO_ACTION)
  {
    if (DEBUG)
    {
      switchCount++;
      Serial.print (switchValue, HEX);
      Serial.print (" ; ");
      Serial.println (switchCount);
    }
  }
  
  // Read process temperature and update the display   
  if ( readTemperatureSensors() == true )  // call the function to determine is new value is available
  {
    lcd.setCursor ( 3, 0 );
    formattedPrint ( processTemperature, true );      
    if (DEBUG)
    {
      Serial.println ( processTemperature );
      Serial.println ( "" );
    }
    
    // new temperature value: check against limits and alarm if out of bounds and in the run mode
    if ( (mode == RUN) && ((processTemperature > upperLimitTemperature) || (processTemperature < lowerLimitTemperature)) )
    {
      if ( muteAlarm )
      {
        alarmFlag = OFF;
      }
      else // alarm not muted by pushing DOWN button in RUN mode
      {
        alarmFlag = ON;
      }
    }
    else  // process temperature in range, regardless of mode
    {
      alarmFlag = OFF; 
      muteAlarm = false;
      if ( mode == RUN )
      {
        lcd.setCursor (13,3);
        lcd.print ( "    ");  // remove MUTE indicator
      }
    }  
 
    // the thermostat functions regardless of mode, in order to keep process temperature steady
    if ( heatEnable )  // skip if thermostat function is not enabled
    {
      if ( processTemperature > (setPointTemperature + THERMOSTAT_BAND) ) 
      {
       heaterControl( OFF, false );  // the heat is to be off; not in the deadzone
      } else 
       if  ( processTemperature < (setPointTemperature - THERMOSTAT_BAND) ) 
       {
          heaterControl( ON, false );  // the heat is to be on; not in the deadzone 
       }  else  // we are in the deazone
       {
          heaterControl( ON, true );  // tell function we are in deadzone, it will know if heat is on or off         
       }
    } else   // heat not enabled
    {
      heaterControl( OFF, false );  // the heat is to be off; not in the deadzone 
    }
    displayHeaterOnTime();  // update the display of the heat time accumulator
  }
  
  // Update the count-down time when in RUN mode
  if (countDown == true)
  {
    newStartTimeT = millis();
    differenceT = (int) ( diff( newStartTimeT , startTimeT ) );  // new time in seconds
    if (differenceT > 1000)  // one second or more has elapsed
    {
      if (stopWatch <= 0 )  // turn off the countdown if hits zero and beep the alert!
      {
        countDown = false;
        beepFlag = ON;  // start the alert beeping by setting the flag
      }
      else
      {
        stopWatch = stopWatch - (differenceT / 1000);  // decrement the stopWatch time
        displayTime ( stopWatch );
        startTimeT = newStartTimeT;
      }
    }
  }
  
  // Main loop functions - called each loop using flags that havew been set during the loop
  beep (beepFlag, alarmFlag);  // beeping will continue until it times out or alarm is reset
  beepFlag = OFF; 
  spin();  // run the spinner according to the state.
  if ( (mode !=RUN) && deadman (false) )  // return to the RUN mode automatically if no
                                          // button push in DEADMAN_TIMEOUT seconds
  {
    mode = RUN;  
    countDown = true;  
    startTimeT = millis();  
    lcd.setCursor ( 0, 3);
    lcd.print ( modeText[mode] ); 
  }
}  //end of loop() function
/********************************* END OF loop() ***********************************************************/

/********************************* BEGINNING OF heaterControl() ********************************************/
// Function to control the heater digital output, the spinner indicator, accumulate heater on time and display
//  the accumulated value.  The function uses a flag to detect transitions from OFF to ON and from ON to OFF.
//  When the transition is to ON, the digital output and the spinner are turned on.  While ON, the global
//  heatTime variable accumulates and the display updates the accumulated time.  When the transition is to
//  OFF, the digital output and spinner are turned off and the last bit of on time is accumulated and displayed.
// Arguments:
//  heaterStatus:  boolean that is ON when the heater should be on and OFF when the heater should be off.
//  deadzone:  boolean that indicates the thermostat is in the deadzone.  If true, heat time accumulation
//    is determined by whether the heat was previously on (the internal flag).  If false, time accumulation
//    is determined by whether the heater is supposed to be on or off, as determined by the heater status flag.

void heaterControl ( boolean heaterStatus, boolean deadzone )
{
  static unsigned long lastHeaterOnTime;  // store the last system time heater is on after display update
  unsigned long newHeaterOnTime;
  static boolean heatStatusFlag = OFF; // store the last state of the heat (ON/ OFF) to detect transitions
  
  if ( !deadzone)  // this logic evaluates the heaterStatus argument to determine if heat needs to be changed.
  {
    if ( heaterStatus == OFF)  // heater is commanded to be turned off
    {
      if ( heatStatusFlag == ON ) // heater was previously on, now turn it off and record accumulated time
      {
        heatStatusFlag = OFF;  
        setOutput (HEATING_ELEMENT, OFF);  // turn off the heater control
        setSpinner (OFF);  // turn off the heater indicator  
        newHeaterOnTime = millis();  
        heatTime += diff( newHeaterOnTime, lastHeaterOnTime );  // update heat time accumulator
      }
      return;
    }
    
    // heater status is to be on
    if ( heatStatusFlag == OFF )    // detect transition to ON
    {
      heatStatusFlag = ON;
      setOutput (HEATING_ELEMENT, ON);  // turn on the heater control
      setSpinner (ON);  // turn on the heater indicator   
      lastHeaterOnTime = millis();
    }  else  // the heat is already on -- update the heatTime accumulator
    {
      newHeaterOnTime = millis();
      heatTime += diff (newHeaterOnTime, lastHeaterOnTime);  // update heat time accumulator
      lastHeaterOnTime = newHeaterOnTime; // update the last time accumulated
    }
    return;
  }
  // if we are in the deadzone, keep accumulating if the heater flag is on. Heat status cannot change in deadzone.
  if ( heatStatusFlag == ON )
  {
   newHeaterOnTime = millis();
   heatTime += diff (newHeaterOnTime, lastHeaterOnTime);  // update heat time accumulator
   lastHeaterOnTime = newHeaterOnTime; // update the last time accumulated
  }
  return;
} 

/********************************* END OF heaterControl() **************************************************/

/********************************* BEGINNING OF displayHeaterOnTime() **************************************/
// Function to display the tim that the heater is on.  Clamps the time to 999,999

void displayHeaterOnTime()
{
  if ( heatTime > HEAT_DISPLAY_LIMIT)  // clamp to the limit
  {
    heatTime = HEAT_DISPLAY_LIMIT;
  }
  // update the display
  lcd.setCursor ( 14, 1 );
  lcd.print (heatTime/1000L);
}

/********************************* END OF displayHeaterOnTime() ********************************************/

/********************************* BEGINNING OF deadman() **************************************************/
// Function to provide a deadman timer.  Used to reset the mode automatically to RUN if no button pushed
//  within a designated number of seconds when not inthe RUN mode.
// Arguments:
//   boolean resetDeadman:  when true, resets the deadman timer; when false, does nto reset the deadman timer
// Returns:
//   boolean:  true of hte deadman timeout exceeded, false otherwise

boolean deadman ( boolean resetDeadman )
{
  static unsigned long startTime = 0L;
  
  if (resetDeadman)
  {
    startTime = millis();
  }
  
  if ( diff( millis(), startTime ) > DEADMAN_TIMEOUT )
  {
    return true;
  } else
  {
    return false;
  }
    
}
/********************************* END OF deadman() *********************************************************/

/********************************* BEGINNING OF beep() ******************************************************/
// Function to manage to the audible alert hardware.  Two conditions make the alert beep:  (1) out of limits on the
//  temperature while in the RUN mode unconditionally sets the alert to issue a continuous tone.  (2) stop watch
//  time going to zero causes the alert to beep 5 times (1/2 second beeps) unless #1 is in effect.
//  This function is non-blocking.  It must be called once per loop() in order for its time keeping and tracking
//  to update.  
//
// Arguments:
//  boolean startBeep:  flag that triggers the 5 beeps associated with stop watch timeout.  Once triggered,
//    subsequent calls to beep() should be made with this flag set to off (false), otherwise it will retrigger.  
//  boolean alarm:  flag that causes the continuous alert tone associated with temperature out of limits.  When
//    the flag is set (true), the alert hardware will issue a continuous sound until this function is called again
//    with this fag set to off (false).

void beep (boolean startBeep, boolean alarm)
{
  static unsigned long beepingStartTime = 0L;
  unsigned long beepingTime;
  unsigned long timeInBeep;
  const int BEEP_DURATION = 5000L;  // 5 second duration
  static boolean initFlag = false;  // prevents beeping when first power up
  
  if ( alarm )  // unconditional sounding of the alert
  {
    setOutput (ALERT, ON);
    return;
  }
  
  // if no alarm, fall through to here
  if ( startBeep )  // trigger the beeping sequence
  {
    beepingStartTime = millis();
    initFlag = true; // get started via startBeep
  }
  
  // implement the beeping sequence - 5 beeps of 1/2 second on, 1/2 second off
  beepingTime = millis();  // get the new time
  timeInBeep = diff( beepingTime, beepingStartTime );
  if (  initFlag && (timeInBeep < BEEP_DURATION) )
  {
    if ( ((int)timeInBeep / 500) %2 == 0) // toggle every 1/2 second to make a beep
    {
      setOutput (ALERT, ON);
    } else
    {
      setOutput (ALERT, OFF);
    }
    return;
  } else  // exceeded the duration of the beeps
  {
    setOutput (ALERT, OFF);
    initFlag = false;
    return;
  }
  return;
}
/********************************* END OF beep *************************************************************/  

/********************************* BEGINNING OF changeTime *************************************************/
// Function to add and subtract from the current time of the stop watch and set limits of 09:00:00 on the
//  upper end and 00:00:00 on the lower end.  Used in time setting only.
//  Arguments:
//    int currentTime:  the current value of the stop watch time
//    int timeIncrement:  the value to be added to the current stop watch time.
//  Return:  the new value for the stop watch time

int changeTime ( int currentTime, int timeIncrement )
{
  currentTime += timeIncrement;  // add the increment
  if (currentTime >= 32400)  // max time is 09:00:00 = 32400
  {
    return 32400;
  }
  if (currentTime < 0)
  {
    return 0;
  } else
  {
    return currentTime;
  }
}
/********************************* END OF changeTime ********************************************************/

/********************************* BEGINNING OF displayTime() ***********************************************/
// Function to take an int and format it into hours:minutes:seconds and then display the time on the LCD
//  in the following column of row 0:  HH in columns 12 and 13; MM in columns 15 and 16; SS in columns
//  18 and 19.
// Arguments:
//  int time:  the current stopwatch time, in seconds

void displayTime ( int time )
{
  int hours;
  int minutes;
  int seconds;
  String displayedTime;
  
  hours = time / 3600;
  minutes = (time % 3600) / 60;
  seconds = (time % 3600) % 60;
  
  lcd.setCursor ( 13 , 0 );
  lcd.print ( hours % 10 );
  
  lcd.setCursor ( 15 , 0 );
  lcd.print ( minutes / 10 );
  lcd.setCursor ( 16 , 0 );
  lcd.print ( minutes % 10 );  

  lcd.setCursor ( 18 , 0 );
  lcd.print ( seconds / 10 );
  lcd.setCursor ( 19 , 0 );
  lcd.print ( seconds % 10 );

}
/********************************* END OF displayTime() ****************************************************/

/********************************* BEGINNING OF readSwitches() *********************************************/
// function to determine if a pushbutton switch has been activated.  If so, returns the switch code constant representing
//  the activated switch.  If no switch has been activated, NO_ACTION is returned.  If multiple switches are
//  activated (generally precluded by the mechanics of the switches, but possible nonetheless), the first switch activation
//  found is returned.
//
// The function reads the input shift register data and masks off the non-switch bits.  It stores the current state of the
//  switches in a static variable.  It also stores a static boolean representing a change in raw switch data, for debouncing.
//  When new switch data from the input shift register differs from the previously stored value, the boolean "debouncing" is set true and
//  the system time is stored.  When the function is entered with the boolean "debouncing" set true, the current time is compared to the
//  previously stored time to see if the debounce period has eneded.  If so, the input shift register data is again sampled and if
//  the state is the same as previously, a switch activation is declared and the switch value is encoded and returned.
//
// This function is non-blocking.  It returns immediately and does not block on the debounce time.  Debouncing is determined dynamically
//  each time the function is called.

int readSwitches()
{
  static unsigned long changeDetectionTime;  // variable to hold the system time for debouncing
  static boolean debouncing = false; //set true if debouncing
  static byte switchState = 0; //hold the last read state of the input shift register for debouncing
  unsigned long newTime; // hold the current system time
  byte newSwitchState; // hold the current data from the input switch register
  unsigned long timeInterval;
  
  if (debouncing) //code if in the process of debouncing switches
  {
    newTime = millis(); //get the new time
    timeInterval = diff (newTime, changeDetectionTime);
    if ( timeInterval < DEBOUNCE_TIME ) //still waiting on debounce
    {
      return NO_ACTION;
    } else    //debounce time expired - recheck switches and return code
    {
      newSwitchState = getShiftRegisterData();
      newSwitchState = newSwitchState & 0x0F; //mask off extra 4 bits
      debouncing = false; //reset debounce flag
      if (newSwitchState == switchState) //confirmed switch data
      {
        if ( (switchState == 0) ) return NO_ACTION; // all switches released
        if ( (switchState & 0x01) != 0 ) return MENU; 
        if ( (switchState & 0x02) != 0 ) return CENTER;        
        if ( (switchState & 0x04) != 0 ) return UP;   
        if ( (switchState & 0x08) != 0 ) return DOWN;   
        return ERROR; // just in case something went wrong with the code!
      }  else  // switch action not confirmed -- just noise
      {
        return NO_ACTION; 
      }     
    }
  } 
 
  else  //code if not debouncing
  {
    newSwitchState = getShiftRegisterData();
    newSwitchState = newSwitchState & 0x3F; //mask off extra bits
    if (newSwitchState == switchState) //no change in the shift register data
    {
      return NO_ACTION;
    } else    //shift register data has changed -- debounce
    {
      switchState = newSwitchState;  //store the new switch state
      changeDetectionTime = millis(); //store time time for debouncing
      debouncing = true; //set debouncing flag
      return NO_ACTION; //no decision until after debouncing time and re-verification
    }
  }
}
/********************************* END OF readSwitches() ***************************************************/

/********************************* BEGINNING OF getShiftRegiesterData() ************************************/
// function to read in the data from the 74HC165 shift register.  One unsigned byte of data is returned.
//  arguments:  none.
//  return:  one byte of data representing:
//    bit 0: MENU button depressed
//    bit 1: pushbutton switch CENTER depressed
//    bit 2: pushbutton switch UP depressed
//    bit 3: pushbutton switch DOWN depressed
//    bit 4: spare (formally LEFT button depressed)
//    bit 5: spare (formally RIGHT button depressed)
//    bit 6: spare - not presently connected
//    bit 7: spare - not presently connected
//  It is possible to have multiple bits set in the returned byte.  The returned byte just contains the present status 
//  of all 8 74HC165 parallel inputs.

byte getShiftRegisterData()
{
  byte shiftData = 0;
  digitalWrite (in_clock, HIGH); //initialize
  
   //sample the switches
  digitalWrite (in_latch, LOW);
  digitalWrite (in_latch, HIGH);
  
  //read in the shift register data
  shiftData = shiftIn (in_data, in_clock, MSBFIRST);
  return shiftData;
}
/********************************* END OF getShiftRegiesterData() ******************************************/

/********************************* BEGINNING OF getOutputStatus() ******************************************/
// function to test the value of the output global variable the reflects the current status of the 
//  74HC595 output shift register contents.  
//  arguments:
//    control: the mask code for the output control to be tested.  See the defined constants.
//    return:  the result as ON or OFF based upon the defined constants.
boolean getOutputStatus(byte control)
{
  byte result;
  result = output & control;  //mask off all but the selected code
  if (result == 0)
  {
    return OFF;
  } else
  {
    return ON;
  }
}
/********************************* END OF getOutputStatus() ************************************************/

/********************************* BEGINNING OF setOutput() ************************************************/
// function to set/reset output controls individually.  The bit masks in the defined constants are used to set or clear
//  individual bits in the global variable "output", whose contents reflect the current state of the 74HC595 shift
//  register.  When the new value of output has been computed, updateOutputShiftRegister() is used to transfer
//  the values to the hardware.
//  arguments:
//    control: the mask code for the output control to be set/reset.  See the defined constants. 
//    state: ON or OFF value to set the control to.  See the defined constants.
void setOutput(byte control, boolean state)
{
  if (state == ON)
  {
    output = output | control;  //set the proper bit on leaving all others alone
  } else
  {
    output = output & (~control); //reset the proper bit off leaving all others alone
  }
  updateOutputShiftRegister(output);  //transfer the output byte to the output shift register
}
/********************************* END OF setOutput() ******************************************************/

/********************************* BEGINNING OF updateOutputShiftRegister() ********************************/
// updateOutputShiftRegister: use "shiftOut()" to transfer a byte 
//    to the 74HC595 shift register
//  arguments:  one byte of data representing (1 = ON, 0 = OFF):
//    bit 0: the HEATING_ELEMENT
//    bit 1: the WATER_FEED_PUMP
//    bit 2: the BEER_FEED_PUMP
//    bit 3: the Y_VALVE
//    bit 4: the PRODUCT_VALVE
//    bit 5: spare output - not presently used
//    bit 6: ALARM
//    bit 7: ALERT audiable indicator

void updateOutputShiftRegister(byte value)
{
  digitalWrite (out_latch, LOW);
  shiftOut (out_data, out_clock, MSBFIRST, value ^ INVERT_MASK);
  digitalWrite (out_latch, HIGH);
}
/********************************* END OF updateOutputShiftRegister() **************************************/

/********************************* BEGINNING OF readTemperatureSensors() ***********************************/
// Function to perform non-blocking reading of the DS18B20 Temerature sensors
//  Returns true if there is a new reading (750 ms from command)
//  also updates the global variables with the temperatures read

boolean readTemperatureSensors()
{
  const unsigned long readingTime = 750L;  //DS18B20 spec wait time for 12 bit reading
  
  static boolean readingInProgress = false; 
  static unsigned long lastTime;
  static unsigned long newTime;
  
  unsigned long timeInterval;
  
  if ( !readingInProgress ) // idle
  {
    sensors.requestTemperatures(); // get all sensors started reading
    readingInProgress = true;
    lastTime = millis();
    
  }  else // waiting on conversion completion
  {
     newTime = millis();
     timeInterval = diff (newTime, lastTime);
     if (timeInterval < readingTime)  // still reading 
     {
       return false;  // no new temps
     } else  // conversion complete -- get the values in degrees F
     {
       if (Centigrade)
       {
         processTemperature = sensors.getTempC ( processTemperatureProbeAddress );
       }  else
       {
         processTemperature = sensors.getTempF ( processTemperatureProbeAddress );
       }
       readingInProgress = false;
       return true; // new temps available 
     }

  }
}  
/********************************* END OF readTemperatureSensors() *****************************************/

/********************************* BEGINNING OF formattedPrint() *******************************************/
// Function to print temperatures in 3.0 or 3.1 format
//  arguments:
//    value: the floating point number to convert to a proper 3.1 string
//    resolution:  false for 3.0 format (integer) or true for 3.1 format (one decimal place
//  also prints the resulting string to the LCD display at the current cursor position

void formattedPrint( float value, boolean resolution )
{
  float temp;
  int integralPart;
  int decimalPart;
  String printString;
 
  if (value < 10.0F)  // display for low temperatures, single digit or negative
  {
    printString = "LOW";
    lcd.print(printString);
    return;
  }
 
 // format the display for temeratures above 10 degrees 
  temp = (value * 10.0F) + 0.5F;  // round off to tenths of a degree
  integralPart = (int)temp / 10;
  decimalPart = (int)temp % 10;
  if ( integralPart < 100 )  // add leading blank for 2 digit value
  {
    printString = " ";
  } else
  {
    printString = "";
  }
  printString = printString + String(integralPart);
  
  if ( resolution )  // add the one decimal place display part if true
  {
    printString = printString + '.';
    printString = printString + String(decimalPart);
  }
  lcd.print(printString);
}
/********************************* END OF formattedPrint() *************************************************/

/********************************* BEGINNING OF setSpinner() ***********************************************/
// Function to set the state of the specified spinners ON or OFF
//  arguments:
//    spinnerNumber - the number (0, 1, 2, or 3) of the spinner
//    state - boolean: ON or OFF
//  also sets the boolean in the global array "spinnerState" to ON or OFF

void setSpinner (boolean state)
{
  spinnerState = state;
}
/********************************* END OF setSpinner() *****************************************************/

/********************************* BEGINNING OF spin() *****************************************************/
// Spin each spinner that is on one step increment of the pattern
//  This function takes no arguments.  It uses the global array "spinnerState" to determine
//    whether to spin or not to spin a spinner.  Each time this function is called, it increments to
//    the next spinner, from spinner(0) to spinner(numberOfSpinners - 1).  If there are 4 spinners
//    total, it will take four calls to this function to advance each spinner one step in the 
//    dynamic spin display.  This keeps the spinner timing the same regardless of hoq many spinners
//    are activated and spinning.
void spin ()
{
  static int symbol = 0; // hold current spinner symbol
  static unsigned long lastTime = 0L;
  unsigned long newTime;
  
  newTime = millis(); 
  if ( diff (newTime, lastTime) > spinnerDelayTime)  // Time to update the next spinner
  {
    lcd.setCursor ( 19, 3 );
    if ( spinnerState == ON )  // write the next spinner symbol
    {
      if ( symbol > 2)  // determine the next spinner symbol
      {
        symbol = 0;
      } else
      {
        symbol++;
      }      
      lcd.write ( spinner[symbol] );
    } else                        // write a "-"
    {
      lcd.write ( 'X' );  // stopped spinner is a "X"
    }    
    
    lastTime = newTime;
  }
}
/********************************* END OF spin() ***********************************************************/

/********************************* BEGINNING OF diff() *****************************************************/
// Function to subtract a new and old millis() reading, correcting for millis() overflow
//  arguments:
//    newTime - the current, updated time from millis()
//    oldTime - the previous time, from millis() for comparision for non-blocking delays
//  returns:  the time difference, correcting for millis() overflow which occurs one every 70 days
unsigned long diff ( unsigned long newTime, unsigned long oldTime )
{
  const unsigned long maxTimeValue = 0xFFFFFFFF;  // max value if millis() before overflow to 0x00000000
  long timeInterval;
 
  if ( newTime < oldTime )  // overflow of millis() has occurred -- fix
  {
    timeInterval = newTime + (maxTimeValue - oldTime) + 1L;
  }  else
  {
    timeInterval = newTime - oldTime;
  }
  return timeInterval;
}
/********************************* END OF diff() ***********************************************************/
