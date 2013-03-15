---
title: Electronics
author: gedex
layout: page
pvc_views:
  - 1309
---
# 

Some projects which made by me when idle. Feel free to ask me if you have same interest.

*   **Electronic** 
    *   **Simple Line Tracker Robot**  
        [![wedus gembel][2]][2]  
        A simple line tracker robot built with [AT89S51][2] and 5 sensors (IR LED and Phototransistor) which coded in assembler ([ASM51][3]). Robot was moving just with [Proportional (P) control][4] (PWM Gain), for better acceleration i suggest you to add [Derivative control][5]. You can watch the video of my robot [here][6]. Source code can be downloaded [here][7]. Rough explanation (in Bahasa Indonesia) can be read [here][8]. Sorry if i couldn’t provide its schematic here. Well, source code gives you obvious connection. For line detection sensor, you can googling by yourself.
    *   **Simple Line Follower Robot With PID**  
        [![robot semar mesem][10]][10]  
        Overall robot was built by Dadank, program was coded by me. Explanation in Bahasa Indonesia can be [read here][10]. [Picture in different looks at picasa][11]. Video while robot moving [fast][12] and [slow][13]. Source Code is [here][14].
    *   **Simple Fire Fighting Robot**  
        [![ghotic-s tampak samping][16]][16]  
        Er, this robot is not completely finish. It tooks me more than two weeks to get everything clear. This robot has three microcontrollers, the master ([ATMega16][16]); which acts as a referee where it decides robot navigation based on [Fuzzy Logic][17], the 1st slave (ATMega16); which controls 6 ultrasonic sensors ([PING][18]) and the 2nd slave (AT90S2313); as an additional sensors placeholder ([CMPS03][19], 2 [GP2D15][20] and two bumper switches). For candle’s flame detection it uses UVTron. Unfortunately, i didn’t make video for this robot and now the robot became cannibal spare part for new [CERC][21]‘s robot. OK, here are the source code which coded in C using CodeVisionAVR IDE :  
        *   [Master uC][22] (receives PING data from 1st slave and does FL rules)
        *   [1st Slave uC][23] (transmits PING data into its master)
        *   [2nd Slave uC][24] (i coded only CMPS03, the rest is your homework ![:)][25] ).
    *   **Simple Digital Lock**  
        ![][26]  
        I have no idea if someone still searching this stuff. Simple Digital Lock with LCD was made for my damn PI. Really simple, using AT89S51, LCD 2×16 (any LCD based on Hitachi 44780 chip controller) and numeric keypad. Files, source code and paper (in Bahasa Indonesia), can be downloaded [here][27].
    *   **Digital Clock Stopwatch**  
        Read my blog post [here][28].
    *   **Automatic Fan With PWM Control**  
        I built this one for my friend’s PI. It uses LM35DZ and built in ADC on ATMega8535. [Here’s the source code][29].

 []: http://www.flickr.com/photos/gedex/1398074617/ "wedus gembel by gedex, on Flickr"
 [2]: http://www.atmel.com/dyn/resources/prod_documents/doc2487.pdf "AT89S51 datasheet"
 [3]: http://www.metaice.com/ASM51/ASM51.htm "ASM51"
 [4]: http://en.wikipedia.org/wiki/PID_controller#Proportional_term "Proportional Control"
 [5]: http://en.wikipedia.org/wiki/PID_controller#Derivative_term "Derivative control"
 [6]: http://www.youtube.com/v/ks1zYPqFcEI
 [7]: http://gedex.web.id/wp-content/uploads/2007/05/FIN.zip
 [8]: http://gedex.web.id/archives/2007/05/24/fuzzy-logic-untuk-navigasi-robot-bagian-i/
 []: http://gedex.web.id/wp-content/uploads/2008/07/dsc00023.jpg
 [10]: http://gedex.web.id/archives/2008/07/09/line-follower-robot-dengan-pid/
 [11]: http://picasaweb.google.co.uk/gedex.adc/SemarMesem
 [12]: http://www.youtube.com/watch?v=fgrwD3nvwLM
 [13]: http://www.youtube.com/watch?v=NnnVGzKcCh4
 [14]: http://gedex.web.id/wp-content/uploads/2008/07/tesmenu04.c
 []: http://www.flickr.com/photos/gedex/1399399792/ "ghotic-s tampak samping by gedex, on Flickr"
 [16]: http://www.atmel.com/dyn/resources/prod_documents/doc2466.pdf "ATMega16 datasheet"
 [17]: http://en.wikipedia.org/wiki/Fuzzy_logic
 [18]: http://www.parallax.com/Store/Microcontrollers/BASICStampModules/tabid/134/ProductID/92/List/1/Default.aspx?SortField=ProductName,ProductName
 [19]: http://www.robot-electronics.co.uk/htm/cmps3doc.shtml
 [20]: http://document.sharpsma.com/files/GP2D15-DATA-SHEET.PDF "GP2D15 datasheet"
 [21]: http://gedex.web.id/archives/2008/01/29/sweater-for-cerc/
 [22]: http://gedex.web.id/wp-content/uploads/2006/12/master_uc.zip
 [23]: http://gedex.web.id/wp-content/uploads/2006/12/slave01.zip
 [24]: http://gedex.web.id/wp-content/uploads/2006/12/slave02.zip
 [25]: http://local-www.gedex.web.id/wp-includes/images/smilies/icon_smile.gif
 [26]: http://gedex.web.id/wp-content/uploads/2006/12/20102246.jpg
 [27]: http://gedex.web.id/wp-content/uploads/2006/12/20102246.zip
 [28]: http://gedex.web.id/archives/2007/06/22/boring-day/
 [29]: http://gedex.web.id/wp-content/uploads/2006/12/lm35_atmega8535.zip