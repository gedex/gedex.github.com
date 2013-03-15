/*****************************************************
This program was produced by the
CodeWizardAVR V1.25.3 Standard
Automatic Program Generator
© Copyright 1998-2007 Pavel Haiduc, HP InfoTech s.r.l.
http://www.hpinfotech.com

Project : 
Version : 
Date    : 6/25/2008
Author  : F4CG                            
Company : F4CG                            
Comments: test PID


Chip type           : ATmega16
Program type        : Application
Clock frequency     : 12.000000 MHz
Memory model        : Small
External SRAM size  : 0
Data Stack size     : 256
*****************************************************/

#include <mega16.h>    
#include <delay.h>
#include <stdio.h>

// Alphanumeric LCD Module functions
#asm
   .equ __lcd_port=0x15 ;PORTC
#endasm
#include <lcd.h>

typedef unsigned char byte;
/* table for the user defined character
   arrow that points to the top right corner */
flash byte char0[8]={
0b1100000,
0b0011000,
0b0000110,
0b1111111,
0b1111111,
0b0000110,
0b0011000,
0b1100000};

char lcd_buffer[33]; 

/* function used to define user characters */
void define_char(byte flash *pc,byte char_code)
{
byte i,a;
a=(char_code<<3) | 0x40;
for (i=0; i<8; i++) lcd_write_byte(a++,*pc++);
}
    
void tampil(unsigned char dat)
{
	unsigned char data;
	
	data = dat / 100;
	data+=0x30;
	lcd_putchar(data);
	
	dat%=100;
	data = dat / 10;
	data+=0x30;
	lcd_putchar(data);
	
	dat%=10;
	data = dat + 0x30;
	lcd_putchar(data);
}
                         
// switch
#define sw_ok     PINB.0
#define sw_cancel PINB.1
#define sw_up     PINB.2
#define sw_down   PINB.3

// eeprom & inisialisasi awal, ketulis lg saat ngisi chip
eeprom byte Kp = 10; 
eeprom byte Ki = 0;
eeprom byte Kd = 5;
eeprom byte MAXSpeed = 255;
eeprom byte MINSpeed = 0;
eeprom byte WarnaGaris = 1; // 1 : putih; 0 : hitam
eeprom byte SensLine = 2; // banyaknya sensor dlm 1 garis
eeprom byte Skenario = 2;                           

void tulisKeEEPROM ( byte NoMenu, byte NoSubMenu, byte var_in_eeprom ) {
                                                     lcd_gotoxy(0, 0);
        lcd_putsf("Tulis ke EEPROM ");
        lcd_putsf("...             ");
        switch (NoMenu) {
          case 1: // PID
                switch (NoSubMenu) {
                  case 1: // Kp 
                        Kp = var_in_eeprom;
                        break;
                  case 2: // Ki
                        Ki = var_in_eeprom;
                        break;
                  case 3: // Kd
                        Kd = var_in_eeprom;
                        break;
                }
                break;
          case 2: // Speed
                switch (NoSubMenu) {
                  case 1: // MAX 
                        MAXSpeed = var_in_eeprom;
                        break;
                  case 2: // MIN
                        MINSpeed = var_in_eeprom;
                        break;
                }
                break;
          case 3: // Warna Garis
                switch (NoSubMenu) {
                  case 1: // Warna 
                        WarnaGaris = var_in_eeprom;
                        break;
                  case 2: // SensL
                        SensLine = var_in_eeprom;
                        break;
                }
                break;
          case 4: // Skenario
                Skenario = var_in_eeprom;
                break;
        }
        delay_ms(200);
}

void setByte( byte NoMenu, byte NoSubMenu ) {
        byte var_in_eeprom;    
        byte plus5 = 0;
        char limitPilih = -1;
        
        lcd_clear();
        lcd_gotoxy(0, 0);
        switch (NoMenu) {
          case 1: // PID
                switch (NoSubMenu) {
                  case 1: // Kp
                        lcd_putsf("Set Kp :        ");
                        var_in_eeprom = Kp;
                        break;
                  case 2: // Ki
                        lcd_putsf("Set Ki :        ");
                        var_in_eeprom = Ki;
                        break;
                  case 3: // Kd
                        lcd_putsf("Set Kd :        ");
                        var_in_eeprom = Kd;
                        break;
                }
                break;
          case 2: // Speed   
                plus5 = 1;
                switch (NoSubMenu) {
                  case 1: // MAX
                        lcd_putsf("Set MAX Speed : ");
                        var_in_eeprom = MAXSpeed;
                        break;
                  case 2: // MIN
                        lcd_putsf("Set MIN Speed : ");
                        var_in_eeprom = MINSpeed;
                        break;
                }
                break;
          case 3: // Warna Garis
                switch (NoSubMenu) {
                  case 1: // Warna
                        limitPilih = 1;
                        lcd_putsf("Warna Garis   : ");
                        var_in_eeprom = WarnaGaris;
                        break;
                  case 2: // SensL
                        limitPilih = 3;
                        lcd_putsf("SensLine :      ");
                        var_in_eeprom = SensLine;
                        break;
                }  
                break;
          case 4: // Skenario  
                  lcd_putsf("Skenario :      ");
                  var_in_eeprom = Skenario; 
                  limitPilih = 8;
                  break;
        }
        
        while (sw_cancel) {  
                delay_ms(150);
                lcd_gotoxy(0, 1);
                tampil(var_in_eeprom);
                
                if (!sw_ok)   {
                        lcd_clear();
                        tulisKeEEPROM( NoMenu, NoSubMenu, var_in_eeprom );
                        goto exitSetByte;
                }
                if (!sw_down) { 
                        if ( plus5 )
                                if ( var_in_eeprom == 0 )
                                        var_in_eeprom = 255;
                                else 
                                        var_in_eeprom -= 5;
                        else     
                                if ( !limitPilih )
                                        var_in_eeprom--;
                                else {  
                                        if ( var_in_eeprom == 0 )
                                          var_in_eeprom = limitPilih;
                                        else
                                          var_in_eeprom--;
                                }
                }  
                if (!sw_up)   {
                        if ( plus5 )
                                if ( var_in_eeprom == 255 )
                                        var_in_eeprom = 0;
                                else
                                        var_in_eeprom += 5;
                        else
                                if ( !limitPilih )
                                        var_in_eeprom++;
                                else {
                                        if ( var_in_eeprom == limitPilih )
                                          var_in_eeprom = 0;
                                        else
                                          var_in_eeprom++;
                                }
                }
        } 
      exitSetByte:
        delay_ms(100);
        lcd_clear();
}

byte kursorPID, kursorSpeed, kursorGaris;  
void showMenu() { 
        lcd_clear();
    menu01: 
        delay_ms(125);   // bouncing sw  
        lcd_gotoxy(0,0);
                // 0123456789abcdef
        lcd_putsf("  Set PID       ");
        lcd_gotoxy(0,1);
        lcd_putsf("  Set Speed     ");
        
        // kursor awal
        lcd_gotoxy(0,0);
        lcd_putchar(0);
        
        if (!sw_ok)   {
                lcd_clear();
                kursorPID = 1;
                goto setPID;
        }
        if (!sw_down) {
                goto menu02;
        }  
        if (!sw_up)   {
                lcd_clear();
                goto menu05;
        }
        
        goto menu01;
    menu02:         
        delay_ms(125);
        lcd_gotoxy(0,0);
                 // 0123456789abcdef
        lcd_putsf("  Set PID       ");
        lcd_gotoxy(0,1);
        lcd_putsf("  Set Speed     ");
        
        lcd_gotoxy(0,1);
        lcd_putchar(0); 
        
        if (!sw_ok) {   
                lcd_clear(); 
                kursorSpeed = 1;
                goto setSpeed;
        }
        if (!sw_up) {
                goto menu01;
        }
        if (!sw_down) {
                lcd_clear();
                goto menu03;        
       }
        goto menu02;
    menu03:       
        delay_ms(125);
        lcd_gotoxy(0,0);
                // 0123456789abcdef
        lcd_putsf("  Set Garis     ");
        lcd_gotoxy(0,1);
        lcd_putsf("  Skenario      ");
        
        lcd_gotoxy(0,0);
        lcd_putchar(0); 
        
        if (!sw_ok) {
                lcd_clear(); 
                kursorGaris = 1;  
                goto setGaris;
        }
        if (!sw_up) {  
                lcd_clear();
                goto menu02;
        }
        if (!sw_down) { 
                goto menu04;
        }
        goto menu03;
    menu04:  
        delay_ms(125);
        lcd_gotoxy(0,0);  
                // 0123456789abcdef
        lcd_putsf("  Set Garis     ");
        lcd_gotoxy(0,1);
        lcd_putsf("  Skenario      ");
        
        lcd_gotoxy(0,1);
        lcd_putchar(0); 
        
        if (!sw_ok) {  
                lcd_clear();
                goto setSkenario;
        }
        if (!sw_up) { 
                goto menu03;
        }
        if (!sw_down) {
                lcd_clear();
                goto menu05;
        }
        goto menu04;
    menu05:      
        delay_ms(125);
        lcd_gotoxy(0,0);
        lcd_putsf("  Start!!      ");
        lcd_gotoxy(0,0);
        lcd_putchar(0); 
        
        if (!sw_ok) {   
                lcd_clear();
                goto startRobot;
        }
        if (!sw_up) {
                lcd_clear();
                goto menu04;
        }
        if (!sw_down) {
                lcd_clear();
                goto menu01;
        }
       
        goto menu05;
   
    setPID: 
        delay_ms(150);
        lcd_gotoxy(0,0);
                // 0123456789ABCDEF
        lcd_putsf("  Kp   Ki   Kd  ");
        // lcd_putsf(" 250  200  300  "); 
        lcd_putchar(' ');
        tampil(Kp); lcd_putchar(' '); lcd_putchar(' '); 
        tampil(Ki); lcd_putchar(' '); lcd_putchar(' ');
        tampil(Kd); lcd_putchar(' '); lcd_putchar(' ');   
        
        switch (kursorPID) {        
          case 1:
                lcd_gotoxy(1,0); // kursor Kp
                lcd_putchar(0);  
                break;
          case 2:
                lcd_gotoxy(6,0); // kursor Ki
                lcd_putchar(0);
                break;
          case 3:
                lcd_gotoxy(11,0); // kursor Kd
                lcd_putchar(0);
                break;      
        }
        
        if (!sw_ok) {
                setByte( 1, kursorPID); 
                delay_ms(200);
        }
        if (!sw_up) {
                if (kursorPID == 3) {
                        kursorPID = 1;        
                } else kursorPID++;
        }
        if (!sw_down) {
                if (kursorPID == 1) {
                        kursorPID = 3;        
                } else kursorPID--;
        } 

        if (!sw_cancel) {   
                lcd_clear();
                goto menu01;
        }
        
        goto setPID;
         
    setSpeed:
        delay_ms(150);
        lcd_gotoxy(0,0);
                // 0123456789ABCDEF
        lcd_putsf("   MAX    MIN   ");
        lcd_putchar(' ');lcd_putchar(' ');lcd_putchar(' ');
        
        //lcd_putsf("   250    200   ");  
        tampil(MAXSpeed); 
        lcd_putchar(' '); lcd_putchar(' ');lcd_putchar(' '); lcd_putchar(' '); 
        tampil(MINSpeed); 
        lcd_putchar(' ');lcd_putchar(' ');lcd_putchar(' ');           
        
        switch (kursorSpeed) {        
          case 1:
                lcd_gotoxy(2,0); // kursor MAX
                lcd_putchar(0);  
                break;
          case 2:
                lcd_gotoxy(9,0); // kursor MIN
                lcd_putchar(0);
                break;  
        }
        
        if (!sw_ok) {
                setByte( 2, kursorSpeed); 
                delay_ms(200);
        }
        if (!sw_up) {
                if (kursorSpeed == 2) {
                        kursorSpeed = 1;        
                } else kursorSpeed++;
        }
        if (!sw_down) {
                if (kursorSpeed == 1) {
                        kursorSpeed = 2;        
                } else kursorSpeed--;
        } 

        if (!sw_cancel) {   
                lcd_clear();
                goto menu02;
        }

        goto setSpeed;  
        
     setGaris: // not yet
        delay_ms(150);  
        lcd_gotoxy(0,0);
                // 0123456789ABCDEF
        if ( WarnaGaris == 1 )
                lcd_putsf("  WARNA : Putih "); 
        else
                lcd_putsf("  WARNA : Hitam "); 
                
        //lcd_putsf("  LEBAR: 1.5 cm ");  
        lcd_gotoxy(0,1);
        lcd_putsf("  SensL :        ");                              
        lcd_gotoxy(10,1);
        tampil( SensLine );
        
        switch (kursorGaris) {        
          case 1:
                lcd_gotoxy(0,0); // kursor Warna
                lcd_putchar(0);  
                break;
          case 2:
                lcd_gotoxy(0,1); // kursor SensL
                lcd_putchar(0);
                break;  
        } 
        
        if (!sw_ok) {
                setByte( 3, kursorGaris); 
                delay_ms(200);
        }
        if (!sw_up) {
                if (kursorGaris == 2) {
                        kursorGaris = 1;        
                } else kursorGaris++;
        }
        if (!sw_down) {
                if (kursorGaris == 1) {
                        kursorGaris = 2;        
                } else kursorGaris--;
        }           
        
        if (!sw_cancel) {   
                lcd_clear();
                goto menu03;
        }
        
        goto setGaris;    
        
     setSkenario:
        delay_ms(150);
        lcd_gotoxy(0,0);
                // 0123456789ABCDEF
        lcd_putsf("Sken. yg  dpake:");
        lcd_gotoxy(0, 1);
        tampil( Skenario );  
        
        if (!sw_ok) {
                setByte( 4, 0); 
                delay_ms(200);
        }
        
        if (!sw_cancel) {   
                lcd_clear();
                goto menu04;
        }
        
        goto setSkenario; 
        
     startRobot:   
        lcd_clear();
 
}


              
#define sensor    PINA
#define s0   PINA.0
#define s1   PINA.1
#define s2   PINA.2
#define s3   PINA.3
#define s4   PINA.4
#define s5   PINA.5
#define s6   PINA.6
#define s7   PINA.7                

#define sKi  PINB.5
#define sKa  PINB.6

void displaySensorBit()
{      
    lcd_gotoxy(2,1);
    if (s7) lcd_putchar('1');
    else    lcd_putchar('0');
    if (s6) lcd_putchar('1');
    else    lcd_putchar('0');    
    if (s5) lcd_putchar('1');
    else    lcd_putchar('0'); 
    if (s4) lcd_putchar('1');
    else    lcd_putchar('0'); 
    if (s3) lcd_putchar('1');
    else    lcd_putchar('0');
    if (s2) lcd_putchar('1');
    else    lcd_putchar('0');
    if (s1) lcd_putchar('1');
    else    lcd_putchar('0');
    if (s0) lcd_putchar('1');
    else    lcd_putchar('0'); 
}                                         

#define Enki PORTD.1
#define kirplus PORTD.2
#define kirmin PORTD.3
#define Enka PORTD.6
#define kaplus PORTD.5
#define kamin PORTD.4    

unsigned char xcount;
int lpwm, rpwm, MAXPWM, MINPWM, intervalPWM;    
byte diffPWM = 5; // utk kiri
// Timer 0 overflow interrupt service routine
interrupt [TIM0_OVF] void timer0_ovf_isr(void)
{
        // Place your code here
	xcount++;
	if(xcount<=lpwm)Enki=1;
	else Enki=0;
	if(xcount<=rpwm)Enka=1;
	else Enka=0;
	TCNT0=0xFF; 
}

void maju()
{   
        kaplus=1;kirplus=1;
        kamin=0;kirmin=0;
}

void mundur()
{   
        kaplus=0;kirplus=0;
        kamin=1;kirmin=1;
}

void bkan()
{
        kaplus=0;
        kamin=1;
}

void bkir()
{
        kirplus=0;
        kirmin=1;
}   
 
void stop()
{   
        rpwm=0;lpwm=0;
        kaplus=0;kirplus=0;
        kamin=0;kirmin=0; 
}

int MV, P, I, D, PV, error, last_error, rate;
int var_Kp, var_Ki, var_Kd;
unsigned char max_MV = 100;
unsigned char min_MV = -100;
unsigned char SP = 0;
void scanBlackLine() {

    switch(sensor) { 
        case 0b11111110:        // ujung kiri        
                PV = -7;
                maju();
                break;
        case 0b11111000:        
        case 0b11111100:        
                PV = -6;
                maju();
                break;
        case 0b11111101:        
                PV = -5;
                maju();
                break;
        case 0b11110001:        
        case 0b11111001:        
                PV = -4;
                maju();
                break;
        case 0b11111011:        
                PV = -3;
                maju();
                break;
        case 0b11100011:        
        case 0b11110011:        
                PV = -2;
                maju();
                break;
        case 0b11110111:        
                PV = -1;
                maju();
                break;
        case 0b11100111:        // tengah        
                PV = 0;
                maju();           
                break;
        case 0b11101111:
                PV = 1;
                maju();     
                break;
        case 0b11000111:
        case 0b11001111:        
                PV = 2;
                maju();
                break;
        case 0b11011111:        
                PV = 3;
                maju();   
                break;
        case 0b10001111:
        case 0b10011111:        
                PV = 4;
                maju();    
                break;
        case 0b10111111:        
                PV = 5;
                maju(); 
                break;
        case 0b00011111:
        case 0b00111111:        
                PV = 6;
                maju();  
                break;
        case 0b01111111:        // ujung kanan        
                PV = 7;
                maju();      
                break;
        case 0b11111111:        // loss
                //if (PV < -3) {
                if (PV < 0) {
                        // PV = -8;
                        lpwm = 150; 
                        rpwm = 185;
                        bkir();
                        goto exit;
                //} else if (PV > 3) {
                } else if (PV > 0) {
                        // PV = 8;
                        lpwm = 180; 
                        rpwm = 155;
                        bkan();
                        goto exit;
                } /*else {
                        PV = 0;
                        lpwm = MAXPWM - 5; 
                        rpwm = MAXPWM;
                        maju();
                }*/
    }
    
    error = SP - PV;
    P = (var_Kp * error) / 10;  
    
    I = I + error;
    I = (I * var_Ki) / 10;
    
    rate = error - last_error;
    D    = (rate * var_Kd) / 10;
    
    last_error = error; 
    
    MV = P + I + D;
    
    if (MV == 0) {
         lpwm = MAXPWM - diffPWM;
         rpwm = MAXPWM;
    } else if (MV > 0) { // alihkan ke kiri
        rpwm = MAXPWM - ((intervalPWM - 20) * MV);
        lpwm = (MAXPWM - (intervalPWM * MV) - 15) - diffPWM;
    
        //rpwm = MAXPWM - ((intervalPWM - 12) * MV);
        //lpwm = (MAXPWM - (intervalPWM * MV)) - diffPWM;
        
        if (lpwm < MINPWM) lpwm = MINPWM;
        if (lpwm > MAXPWM) lpwm = MAXPWM;
        if (rpwm < MINPWM) rpwm = MINPWM;
        if (rpwm > MAXPWM) rpwm = MAXPWM;
    } else if (MV < 0) { // alihkan ke kanan
        lpwm = MAXPWM + ( ( intervalPWM - 20 ) * MV);
        rpwm = MAXPWM + ( ( intervalPWM * MV ) - 15 ); 
        
        if (lpwm < MINPWM) lpwm = MINPWM;
        if (lpwm > MAXPWM) lpwm = MAXPWM;
        if (rpwm < MINPWM) rpwm = MINPWM;
        if (rpwm > MAXPWM) rpwm = MAXPWM;
        
        //lpwm = MAXPWM + ( ((intervalPWM - 12) + 5) * MV);
        //rpwm = MAXPWM + ((intervalPWM * MV) * MV); 
    } 
    
    exit:
    //debug pwm
    sprintf(lcd_buffer,"%d   %d",lpwm, rpwm);
    lcd_gotoxy(0, 0);
    lcd_putsf("                ");
    lcd_gotoxy(0, 0);
    lcd_puts(lcd_buffer);
    delay_ms(5);     
    
    /*debug MV
    sprintf(lcd_buffer,"MV:%d",MV);
    lcd_gotoxy(0,0);
    lcd_putsf("                ");
    lcd_gotoxy(0,0);
    lcd_puts(lcd_buffer);
    delay_ms(10); */
    
}        
     
int hitungSiku;
void ketemuSiku(unsigned char belokKanan) {
    stop();  
    
    lpwm = 120;
    rpwm = 120;
    mundur();
     
loopSiku:
    if ( !sKi ) goto keluarSiku_;
    if ( !sKa ) goto keluarSiku_;
    if ( sensor != 0xff ) goto keluarSiku_; 
    goto loopSiku; 
    
keluarSiku_:    
    stop();
    lpwm = 150;
    rpwm = 155;    
    
    if ( belokKanan ) { 
        while (sensor == 0xff) {
                bkan(); 
        }
    } else {
        while (sensor == 0xff) {
                bkir(); 
        }
    }
keluarSiku:
    for (hitungSiku = 0; hitungSiku < 150; hitungSiku++) {
        scanBlackLine();
        delay_ms(1);
    }       
}

void main(void)
{
// sensor
PORTA=0x00;
DDRA=0x00;

//switch & sKi & sKa
PORTB=0x0F;
DDRB=0x00;

//lcd
PORTC=0x00;
DDRC=0x00;
     
//motor
PORTD=0x00;
DDRD=0xFF;

// Timer/Counter 0 initialization
// Clock source: System Clock
// Clock value: Timer 0 Stopped
// Mode: Normal top=FFh
// OC0 output: Disconnected
TCCR0=0x00;
TCNT0=0x00;
OCR0=0x00;

// Timer/Counter 1 initialization
// Clock source: System Clock
// Clock value: Timer 1 Stopped
// Mode: Normal top=FFFFh
// OC1A output: Discon.
// OC1B output: Discon.
// Noise Canceler: Off
// Input Capture on Falling Edge
// Timer 1 Overflow Interrupt: Off
// Input Capture Interrupt: Off
// Compare A Match Interrupt: Off
// Compare B Match Interrupt: Off
TCCR1A=0x00;
TCCR1B=0x00;
TCNT1H=0x00;
TCNT1L=0x00;
ICR1H=0x00;
ICR1L=0x00;
OCR1AH=0x00;
OCR1AL=0x00;
OCR1BH=0x00;
OCR1BL=0x00;

// Timer/Counter 2 initialization
// Clock source: System Clock
// Clock value: Timer 2 Stopped
// Mode: Normal top=FFh
// OC2 output: Disconnected
ASSR=0x00;
TCCR2=0x00;
TCNT2=0x00;
OCR2=0x00;

// External Interrupt(s) initialization
// INT0: Off
// INT1: Off
// INT2: Off
MCUCR=0x00;
MCUCSR=0x00;

// Timer(s)/Counter(s) Interrupt(s) initialization
TIMSK=0x01;

// Analog Comparator initialization
// Analog Comparator: Off
// Analog Comparator Input Capture by Timer/Counter 1: Off
ACSR=0x80;
SFIOR=0x00;

// LCD module initialization
lcd_init(16);   

/* define user character 0 */
define_char(char0,0);

// stop motor
TCCR0=0x00;
stop();               

showMenu(); 
TCCR0=0x05;   
#asm("sei")

// read eeprom
var_Kp  = Kp;
var_Ki  = Ki;
var_Kd  = Kd;   
MAXPWM = (int)MAXSpeed + 1;
MINPWM = MINSpeed;

intervalPWM = (MAXSpeed - MINSpeed) / 8;
PV = 0;
error = 0;
last_error = 0;   
 
maju();
while (1)
      {
       displaySensorBit();
       if ( (!sKi) && (sensor==0xff) ) {
         ketemuSiku(0); 
         goto scan01;
       } 
       if ( (!sKa) && (sensor==0xff) ) {
        ketemuSiku(1);  
       }
    scan01: 
       scanBlackLine();
      };
}
