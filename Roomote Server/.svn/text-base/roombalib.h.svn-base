/*
 * roombalib -- Roomba C API
 *
 * http://hackingroomba.com/
 *
 * Copyright (C) 2006, Tod E. Kurt, tod@todbot.com
 * 
 * Updates:
 * 14 Dec 2006 - added more functions to roombalib
 *
 * Updated by Brian Pratt, http://www.brianhpratt.net
 *   2009-2010
 */


#include <stdint.h>   /* Standard types */

#define DEFAULT_VELOCITY 200
#define MIN_VELOCITY 0
#define MAX_VELOCITY 500
//#define COMMANDPAUSE_MILLIS 100
#define COMMANDPAUSE_MILLIS 300

// the four SCI/OI modes
#define OFF_MODE 0
#define PASSIVE_MODE 1
#define SAFE_MODE 2
#define FULL_MODE 3

/*
// some module-level definitions for the robot commands
START = chr(128)    # already converted to bytes...
BAUD = chr(129)     # + 1 byte
CONTROL = chr(130)  # deprecated for Create
SAFE = chr(131)
FULL = chr(132)
POWER = chr(133)
SPOT = chr(134)     # Same for the Roomba and Create
CLEAN = chr(135)    # Clean button - Roomba
COVER = chr(135)    # Cover demo - Create
MAX = chr(136)      # Roomba
DEMO = chr(136)     # Create
DRIVE = chr(137)    # + 4 bytes
MOTORS = chr(138)   # + 1 byte
LEDS = chr(139)     # + 3 bytes
SONG = chr(140)     # + 2N+2 bytes, where N is the number of notes
PLAY = chr(141)     # + 1 byte
SENSORS = chr(142)  # + 1 byte
FORCESEEKINGDOCK = chr(143)  # same on Roomba and Create
// the above command is called "Cover and Dock" on the Create
DRIVEDIRECT = chr(145)       # Create only
STREAM = chr(148)       # Create only
QUERYLIST = chr(149)       # Create only
PAUSERESUME = chr(150)       # Create only

// the four SCI modes
// the code will try to keep track of which mode the system is in,
// but this might not be 100% trivial...
OFF_MODE = 0
PASSIVE_MODE = 1
SAFE_MODE = 2
FULL_MODE = 3

// the sensors
BUMPS_AND_WHEEL_DROPS = 7
WALL_IR_SENSOR = 8
CLIFF_LEFT = 9
CLIFF_FRONT_LEFT = 10
CLIFF_FRONT_RIGHT = 11
CLIFF_RIGHT = 12
VIRTUAL_WALL = 13
LSD_AND_OVERCURRENTS = 14
INFRARED_BYTE = 17
BUTTONS = 18
DISTANCE = 19
ANGLE = 20
CHARGING_STATE = 21
VOLTAGE = 22
CURRENT = 23
BATTERY_TEMP = 24
BATTERY_CHARGE = 25
BATTERY_CAPACITY = 26
WALL_SIGNAL = 27
CLIFF_LEFT_SIGNAL = 28
CLIFF_FRONT_LEFT_SIGNAL = 29
CLIFF_FRONT_RIGHT_SIGNAL = 30
CLIFF_RIGHT_SIGNAL = 31
CARGO_BAY_DIGITAL_INPUTS = 32
CARGO_BAY_ANALOG_SIGNAL = 33
CHARGING_SOURCES_AVAILABLE = 34
OI_MODE = 35
SONG_NUMBER = 36
SONG_PLAYING = 37
NUM_STREAM_PACKETS = 38
REQUESTED_VELOCITY = 39
REQUESTED_RADIUS = 40
REQUESTED_RIGHT_VELOCITY = 41
REQUESTED_LEFT_VELOCITY = 42
// others just for easy access to particular parts of the data
POSE = 100
LEFT_BUMP = 101
RIGHT_BUMP = 102
LEFT_WHEEL_DROP = 103
RIGHT_WHEEL_DROP = 104
CENTER_WHEEL_DROP = 105
LEFT_WHEEL_OVERCURRENT = 106
RIGHT_WHEEL_OVERCURRENT = 107
ADVANCE_BUTTON = 108
PLAY_BUTTON = 109

//                   0 1 2 3 4 5 6 7 8 9101112131415161718192021222324252627282930313233343536373839404142
SENSOR_DATA_WIDTH = [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,2,2,1,2,2,1,2,2,2,2,2,2,2,1,2,1,1,1,1,1,2,2,2,2]
*/


// holds all the per-roomba info
// consider it an opaque blob, please
typedef struct Roomba_struct {
    int fd;
    char portpath[80];
    uint8_t sensor_bytes[26];
    int velocity;
	bool is500Series;
} Roomba;

// set to non-zero to see debugging output
extern int roombadebug;

// given a serial port name, create a Roomba object and return it
// or return NULL on error
//Roomba* roomba_init( const char* portname );
Roomba* roomba_init( const char* portpath, bool roomba500series, bool rooTooth );

// frees the memory of the Roomba object created with roomba_init
// will close the serial port if it's open
void roomba_free( Roomba* roomba );

// close the serial port connected to the Roomba
void roomba_close( Roomba* roomba );

// is this Roomba pointer valid (but not necc connected)
int roomba_valid( Roomba* roomba );

// return the serial port path for the given roomba
const char* roomba_get_portpath( Roomba* roomba );

// send an arbitrary length roomba command
int roomba_send( Roomba* roomba, const uint8_t* cmd, int len );

// Move Roomba with low-level DRIVE command
void roomba_drive( Roomba* roomba, int velocity, int radius );

// stop the Roomba 
void roomba_stop( Roomba* roomba );

// Move Roomba forward at current velocity
void roomba_forward( Roomba* roomba );
void roomba_forward_at( Roomba* roomba, int velocity );

// Move Roomba backward at current velocity
void roomba_backward( Roomba* roomba );
void roomba_backward_at( Roomba* roomba, int velocity );

// Spin Roomba left at current velocity
void roomba_spinleft( Roomba* roomba );
void roomba_spinleft_at( Roomba* roomba, int velocity );

// Spin Roomba right at current velocity
void roomba_spinright( Roomba* roomba );
void roomba_spinright_at( Roomba* roomba, int velocity );

// Set current velocity for higher-level movement commands
void roomba_set_velocity( Roomba* roomba, int velocity );

// Get current velocity for higher-level movement commands
int roomba_get_velocity( Roomba* roomba );

// play a musical note
void roomba_play_note( Roomba* roomba, uint8_t note, uint8_t duration );

// Turns on/off the non-drive motors (main brush, vacuum, sidebrush).
void roomba_set_motors( Roomba* roomba, uint8_t mainbrush, uint8_t vacuum, uint8_t sidebrush);

// Turns on/off the various LEDs.
void roomba_set_leds( Roomba* roomba, uint8_t status_green, uint8_t status_red,
                      uint8_t spot, uint8_t clean, uint8_t max, uint8_t dirt, 
                      uint8_t power_color, uint8_t power_intensity );

// Turn all vacuum motors on or off according to state
void roomba_vacuum( Roomba* roomba, uint8_t state );


// CLEANING COMMANDS

// This command starts the default cleaning mode.
void roomba_clean( Roomba* roomba );

// This command starts the Max cleaning mode.
void roomba_max( Roomba* roomba );

// This command starts the Spot cleaning mode.
void roomba_spot( Roomba* roomba );

// This command sends Roomba to the dock.
void roomba_dock( Roomba* roomba );

// This command sends Roomba a new schedule. To disable scheduled cleaning, send all 0s.
void roomba_schedule( Roomba* roomba, uint8_t days, uint8_t sun_hour, uint8_t sun_min, uint8_t mon_hour, uint8_t mon_min, uint8_t tue_hour, uint8_t tue_min, uint8_t wed_hour, uint8_t wed_min, uint8_t thu_hour, uint8_t thu_min, uint8_t fri_hour, uint8_t fri_min, uint8_t sat_hour, uint8_t sat_min );

// This command sets Roomba’s clock
void roomba_set_day_time( Roomba* roomba, uint8_t day, uint8_t hour, uint8_t minute );

// This command powers down Roomba. The OI can be in Passive, Safe, or Full mode to accept this command.
void roomba_power( Roomba* roomba );


// MODE COMMANDS

// This command starts the OI. You must always send the Start command before sending any other 
// commands to the OI. Puts the Roomba in Passive mode
void roomba_start( Roomba* roomba );

// This command puts the OI into Safe mode, enabling user control of Roomba. It turns off all LEDs. The OI 
// can be in Passive, Safe, or Full mode to accept this command. If a safety condition occurs (see above) 
// Roomba reverts automatically to Passive mode.
void roomba_safe( Roomba* roomba );

// This command gives you complete control over Roomba by putting the OI into Full mode, and turning off 
// the cliff, wheel-drop and internal charger safety features.  That is, in Full mode, Roomba executes any 
// command that you send it, even if the internal charger is plugged in, or command triggers a cliff or wheel 
// drop condition.
void roomba_full( Roomba* roomba );

// Clear out the read buffer from the Roomba connection
int roomba_clear_read_buf( Roomba* roomba );

// Get the sensor data from the Roomba
// returns -1 on failure
int roomba_read_sensors( Roomba* roomba );

// print existing sensor data nicely
void roomba_print_sensors( Roomba* roomba );

// print existing sensor data as string of hex chars
void roomba_print_raw_sensors( Roomba* roomba );

// read the current mode of the Roomba
// 0	Off
// 1	Passive
// 2	Safe
// 3	Full
int roomba_read_mode( Roomba* roomba );

// utility function
void roomba_delay( int millisecs );
#define roomba_wait roomba_delay

// some simple macros of bit manipulations
#define bump_right(b)           ((b & 0x01)!=0)
#define bump_left(b)            ((b & 0x02)!=0)
#define wheeldrop_right(b)      ((b & 0x04)!=0)
#define wheeldrop_left(b)       ((b & 0x08)!=0)
#define wheeldrop_caster(b)     ((b & 0x10)!=0)

#define motorover_sidebrush(b)  ((b & 0x01)!=0) 
#define motorover_vacuum(b)     ((b & 0x02)!=0) 
#define motorover_mainbrush(b)  ((b & 0x04)!=0) 
#define motorover_driveright(b) ((b & 0x08)!=0) 
#define motorover_driveleft(b)  ((b & 0x10)!=0) 

