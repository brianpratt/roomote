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


#include <stdio.h>    /* Standard input/output definitions */
#include <stdint.h>   /* Standard types */
#include <stdlib.h>   /* calloc, strtol */
#include <string.h>   /* strcpy */
#include <unistd.h>   /* UNIX standard function definitions */
#include <fcntl.h>    /* File control definitions */
#include <errno.h>    /* Error number definitions */
#include <termios.h>  /* POSIX terminal control definitions */
#include <sys/ioctl.h>

#include "roombalib.h"

int roombadebug = 1;

// internal use only
int roomba_init_serialport( const char* serialport, speed_t baud );

Roomba* roomba_init( const char* portpath, bool roomba500Series, bool rooToothFireFly ) 
{
	int fd;
    if (roomba500Series)
		fd = roomba_init_serialport( portpath, B115200 );
    else
		fd = roomba_init_serialport( portpath, B57600 );
    if( fd == -1 ) return NULL;
	
    if(roombadebug)
        fprintf(stderr,"roomba_init: successfully opened port\n");
	
    uint8_t cmd[10];
	int n;
	
	// If using RooTooth (and a series 500 Roomba), set up the baud rate between the RooTooth and the Roomba
	if (roomba500Series && rooToothFireFly) {
		
		roomba_delay(COMMANDPAUSE_MILLIS);
		
		// Put RooTooth into Command Mode
		cmd[0] = '$';
		cmd[1] = '$';
		cmd[2] = '$';
		n = write(fd, cmd, 3);
		if( n!=3 ) {
			perror("roomba_init: Unable to write to port ");
			return NULL;
		}
		roomba_delay(COMMANDPAUSE_MILLIS);
		
		// Set baud rate to 115k (for 500 series Roombas)
		cmd[0] = 'U';
		cmd[1] = ',';
		cmd[2] = '1';
		cmd[3] = '1';
		cmd[4] = '5';
		cmd[5] = 'k';
		cmd[6] = ',';
		cmd[7] = 'N';
		cmd[8] = '\n';
		n = write(fd, cmd, 9);
		if( n!=9 ) {
			perror("roomba_init: Unable to write to port ");
			return NULL;
		}
		roomba_delay(COMMANDPAUSE_MILLIS);
	}
    
	cmd[0] = 128;      // START
    n = write(fd, cmd, 1);
    if( n!=1 ) {
        perror("open_port: Unable to write to port ");
        return NULL;
    }
    roomba_delay(COMMANDPAUSE_MILLIS);
    
    cmd[0] = 130;   // CONTROL
    n = write(fd, cmd, 1);
    if( n!=1 ) {
        perror("open_port: Unable to write to port ");
        return NULL;
    }
    roomba_delay(COMMANDPAUSE_MILLIS);

    Roomba* roomba = calloc( 1, sizeof(Roomba) );
    roomba->fd = fd;
    strcpy(roomba->portpath, portpath);
    roomba->velocity = DEFAULT_VELOCITY;
	roomba->is500Series = roomba500Series;

    return roomba;
}

void roomba_free( Roomba* roomba ) 
{
    if( roomba!= NULL ) {
        if( roomba->fd ) roomba_close( roomba );
        free( roomba );
    }
}

const char* roomba_get_portpath( Roomba* roomba )
{
    return roomba->portpath;
}

void roomba_close( Roomba* roomba )
{
    close( roomba->fd );
    roomba->fd = 0;
}

// is this Roomba pointer valid (but not necc connected)
int roomba_valid( Roomba* roomba )
{
    return (roomba!=NULL && roomba->fd != 0);
}

void roomba_set_velocity( Roomba* roomba, int vel )
{
    roomba->velocity = vel;
}

int roomba_get_velocity( Roomba* roomba )
{
    return roomba->velocity;
}

// send an arbitrary length roomba command
int roomba_send( Roomba* roomba, const uint8_t* cmd, int len )
{
    int n = write( roomba->fd, cmd, len);
    if( n!=len )
        perror("roomba_send: couldn't write to roomba");
    return (n!=len); // indicate error, can usually ignore
}

// Move Roomba with low-level DRIVE command
void roomba_drive( Roomba* roomba, int velocity, int radius )
{
    uint8_t vhi = velocity >> 8;
    uint8_t vlo = velocity & 0xff;
    uint8_t rhi = radius   >> 8;
    uint8_t rlo = radius   & 0xff;
    if(roombadebug) 
        fprintf(stderr,"roomba_drive: %.2hhx %.2hhx %.2hhx %.2hhx\n",
                vhi,vlo,rhi,rlo);
    uint8_t cmd[5] = { 137, vhi,vlo, rhi,rlo };  // DRIVE
    int n = write(roomba->fd, cmd, 5);
    if( n!=5 )
        perror("roomba_drive: couldn't write to roomba");
}

void roomba_stop( Roomba* roomba )
{
    roomba_drive( roomba, 0, 0 );
}

void roomba_forward( Roomba* roomba )
{
    roomba_drive( roomba, roomba->velocity, 0x8000 );
}
void roomba_forward_at( Roomba* roomba, int velocity )
{
    roomba_drive( roomba, velocity, 0x8000 );
}

void roomba_backward( Roomba* roomba )
{
    roomba_drive( roomba, -roomba->velocity, 0x8000 );
}
void roomba_backward_at( Roomba* roomba, int velocity )
{
    roomba_drive( roomba, -velocity, 0x8000 );
}

void roomba_spinleft( Roomba* roomba )
{
    roomba_drive( roomba, roomba->velocity, 1 );
}
void roomba_spinleft_at( Roomba* roomba, int velocity )
{
    roomba_drive( roomba, velocity, 1 );
}

void roomba_spinright( Roomba* roomba )
{
    roomba_drive( roomba, roomba->velocity,  -1 );
}
void roomba_spinright_at( Roomba* roomba, int velocity )
{
    roomba_drive( roomba, velocity,  -1 );
}

void roomba_play_note( Roomba* roomba, uint8_t note, uint8_t duration ) 
{
    uint8_t cmd[] = { 140, 0, 1, note, duration, // SONG, then
                      141, 0 };                  // PLAY
    int n = write( roomba->fd, cmd, 7);
    if( n!=7 )
        perror("roomba_play_note: couldn't write to roomba");
}

// Turns on/off the non-drive motors (main brush, vacuum, sidebrush).
void roomba_set_motors( Roomba* roomba, uint8_t mainbrush, uint8_t vacuum, uint8_t sidebrush)
{
    uint8_t cmd[] = { 138,                        // MOTORS
                      ((mainbrush?0x04:0)|(vacuum?0x02:0)|(sidebrush?0x01:0))};
    int n = write( roomba->fd, cmd, 2);
    if( n!=2 )
        perror("roomba_set_motors: couldn't write to roomba");
}

// Turns on/off the various LEDs.
void roomba_set_leds( Roomba* roomba, uint8_t status_green, uint8_t status_red,
                      uint8_t spot, uint8_t clean, uint8_t max, uint8_t dirt, 
                      uint8_t power_color, uint8_t power_intensity )
{
    uint8_t v = (status_green?0x20:0) | (status_red?0x10:0) |
                (spot?0x08:0) | (clean?0x04:0) | (max?0x02:0) | (dirt?0x01:0);
    uint8_t cmd[] = { 139, v, power_color, power_intensity }; // LEDS
    int n = write( roomba->fd, cmd, 4);
    if( n!=4 )
        perror("roomba_set_leds: couldn't write to roomba");
}

// Turn all vacuum motors on or off according to state
void roomba_vacuum( Roomba* roomba, uint8_t state ) {
    roomba_set_motors( roomba, state,state,state);
}


// CLEANING COMMANDS

// This command starts the default cleaning mode.
void roomba_clean( Roomba* roomba )
{
    uint8_t cmd = 135;
    int n = write( roomba->fd, &cmd, 1);
    if( n!=1 )
        perror("roomba_clean: couldn't write to roomba");
}

// This command starts the Max cleaning mode.
void roomba_max( Roomba* roomba )
{
    uint8_t cmd = 136;
    int n = write( roomba->fd, &cmd, 1);
    if( n!=1 )
        perror("roomba_max: couldn't write to roomba");
}

// This command starts the Spot cleaning mode.
void roomba_spot( Roomba* roomba )
{
    uint8_t cmd = 134;
    int n = write( roomba->fd, &cmd, 1);
    if( n!=1 )
        perror("roomba_spot: couldn't write to roomba");
}

// This command sends Roomba to the dock.
void roomba_dock( Roomba* roomba )
{
    uint8_t cmd = 143;
    int n = write( roomba->fd, &cmd, 1);
    if( n!=1 )
        perror("roomba_dock: couldn't write to roomba");
}

// This command sends Roomba a new schedule. To disable scheduled cleaning, send all 0s.
void roomba_schedule( Roomba* roomba, uint8_t days, uint8_t sun_hour, uint8_t sun_min, 
					 uint8_t mon_hour, uint8_t mon_min, uint8_t tue_hour, uint8_t tue_min, 
					 uint8_t wed_hour, uint8_t wed_min, uint8_t thu_hour, uint8_t thu_min, 
					 uint8_t fri_hour, uint8_t fri_min, uint8_t sat_hour, uint8_t sat_min )
{
    
}

// This command sets Roomba’s clock
void roomba_set_day_time( Roomba* roomba, uint8_t day, uint8_t hour, uint8_t minute )
{
    
}

// This command powers down Roomba. The OI can be in Passive, Safe, or Full mode to accept this command.
void roomba_power( Roomba* roomba )
{
    uint8_t cmd = 133;
    int n = write( roomba->fd, &cmd, 1);
    if( n!=1 )
        perror("roomba_power: couldn't write to roomba");
}



// MODE COMMANDS

// This command starts the OI. You must always send the Start command before sending any other 
// commands to the OI. Puts the Roomba in Passive mode
void roomba_start( Roomba* roomba )
{
    uint8_t cmd = 128;
    int n = write( roomba->fd, &cmd, 1);
    if( n!=1 )
        perror("roomba_start: couldn't write to roomba");
}

// This command puts the OI into Safe mode, enabling user control of Roomba. It turns off all LEDs. The OI 
// can be in Passive, Safe, or Full mode to accept this command. If a safety condition occurs (see above) 
// Roomba reverts automatically to Passive mode.
void roomba_safe( Roomba* roomba )
{
    uint8_t cmd = 131;
    int n = write( roomba->fd, &cmd, 1);
    if( n!=1 )
        perror("roomba_safe: couldn't write to roomba");
}

// This command gives you complete control over Roomba by putting the OI into Full mode, and turning off 
// the cliff, wheel-drop and internal charger safety features.  That is, in Full mode, Roomba executes any 
// command that you send it, even if the internal charger is plugged in, or command triggers a cliff or wheel 
// drop condition.
void roomba_full( Roomba* roomba )
{
    uint8_t cmd = 132;
    int n = write( roomba->fd, &cmd, 1);
    if( n!=1 )
        perror("roomba_full: couldn't write to roomba");
}


int roomba_clear_read_buf( Roomba* roomba )
{
	uint8_t buf[100];
    int n = read( roomba->fd, buf, 100);
	if(roombadebug)
		fprintf(stderr,"roomba_clear_read_buf: read n=%d bytes\n",n);

	return n;
}


int roomba_read_sensors( Roomba* roomba )
{
    uint8_t cmd[2] = { 142, 0 };          // SENSOR, get all sensor data
    int n = write( roomba->fd, cmd, 2);
    roomba_delay(COMMANDPAUSE_MILLIS);  //hmm, why isn't VMIN & VTIME working?
    n = read( roomba->fd, roomba->sensor_bytes, 26);
    if( n!=26 ) {
        if(roombadebug)
            fprintf(stderr,"roomba_read_sensors: not enough read (n=%d)\n",n);
        return -1;
    }
    return 0;
}

void roomba_print_raw_sensors( Roomba* roomba )
{
    uint8_t* sb = roomba->sensor_bytes;
    int i;
    for(i=0;i<26;i++) {
        printf("%.2hhx ",sb[i]);
    }
    printf("\n");
}

void roomba_print_sensors( Roomba* roomba )
{
    uint8_t* sb = roomba->sensor_bytes;
    printf("bump: %x %x\n", bump_left(sb[0]), bump_right(sb[0]));
    printf("wheeldrop: %x %x %x\n", wheeldrop_left(sb[0]),
           wheeldrop_caster(sb[0]), wheeldrop_right(sb[0]));
    printf("wall: %x\n", sb[1]);
    printf("cliff: %x %x %x %x\n", sb[2],sb[3],sb[4],sb[5] );
    printf("virtual_wall: %x\n", sb[6]);
    printf("motor_overcurrents: %x %x %x %x %x\n", motorover_driveleft(sb[7]),
           motorover_driveright(sb[7]), motorover_mainbrush(sb[7]),
           motorover_sidebrush(sb[7]),  motorover_vacuum(sb[7]));
    printf("dirt: %x %x\n", sb[8],sb[9]);
    printf("remote_opcode: %.2hhx\n", sb[10]);
    printf("buttons: %.2hhx\n", sb[11]);
    printf("distance: %.4x\n",    (sb[12]<<8) | sb[13] );
    printf("angle: %.4x\n",       (sb[14]<<8) | sb[15] );
    printf("charging_state: %.2hhx\n", sb[16]);
    printf("voltage: %d\n",     (sb[17]<<8) | sb[18] );
    printf("current: %d\n",     ((int8_t)sb[19]<<8) | sb[20] );
    printf("temperature: %d\n",    sb[21]);
    printf("charge: %d\n",      (sb[22]<<8) | sb[23] );
    printf("capacity: %d\n",    (sb[24]<<8) | sb[25] );
}

int roomba_read_mode( Roomba* roomba )
{
    uint8_t cmd[2] = { 142, 35 };          // OI Mode, get current mode
    int n = write( roomba->fd, cmd, 2);
    roomba_delay(COMMANDPAUSE_MILLIS);
	uint8_t mode;
    n = read( roomba->fd, &mode, 1);
    if( n!=1 ) {
        if(roombadebug)
            fprintf(stderr,"roomba_read_mode: not the right amount of bytes read (n=%d)\n",n);
        return -1;
    }
    if( mode > 3 ) {
        if(roombadebug)
            fprintf(stderr,"roomba_read_mode: invalid mode (mode=%d)\n",mode);
        return -1;
    }
    return mode;
}

// 100,000 us == 100 ms == 0.1s
void roomba_delay( int millisecs )
{
    usleep( millisecs * 1000 );
}



// private
// returns valid fd, or -1 on error
int roomba_init_serialport( const char* serialport, speed_t baud )
{
    struct termios toptions;
    int fd;

    if(roombadebug)
        fprintf(stderr,"roomba_init_serialport: opening port %s\n",serialport);

    fd = open( serialport, O_RDWR | O_NOCTTY | O_NDELAY );
    if (fd == -1)  {     // Could not open the port.
        perror("roomba_init_serialport: Unable to open port ");
        return -1;
    }
    
    if (tcgetattr(fd, &toptions) < 0) {
        perror("roomba_init_serialport: Couldn't get term attributes");
        return -1;
    }
    
    cfsetispeed(&toptions, baud);
    cfsetospeed(&toptions, baud);

    // 8N1
    toptions.c_cflag &= ~PARENB;
    toptions.c_cflag &= ~CSTOPB;
    toptions.c_cflag &= ~CSIZE;
    toptions.c_cflag |= CS8;
    // no flow control
    toptions.c_cflag &= ~CRTSCTS;

    toptions.c_cflag    |= CREAD | CLOCAL;  // turn on READ & ignore ctrl lines
    toptions.c_iflag    &= ~(IXON | IXOFF | IXANY); // turn off s/w flow ctrl

    toptions.c_lflag    &= ~(ICANON | ECHO | ECHOE | ISIG); // make raw
    toptions.c_oflag    &= ~OPOST; // make raw

    toptions.c_cc[VMIN]  = 26;
    toptions.c_cc[VTIME] = 2;           // FIXME: not sure about this
    
    if( tcsetattr(fd, TCSANOW, &toptions) < 0) {
        perror("roomba_init_serialport: Couldn't set term attributes");
        return -1;
    }

    return fd;
}
