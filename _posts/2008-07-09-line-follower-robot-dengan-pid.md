---
title: Line Follower Robot dengan PID
author: gedex
layout: post
excerpt: Line Follower Robot dengan PID
thickbox:
  - thickbox
pvc_views:
  - 40438
categories:
  - coding
  - robot
  - tutorial AVR
tags:
  - PID linefollower
---


Sesuai janji saya, kali ini akan saya bahas robot line follower dengan sistem kontrol PID. Patokan yang saya gunakan berasal dari [artikel di Chibots][1], perbedaannya adalah sistem [steering][2] yang digunakan robot. Pada artikel tersebut PID digunakan untuk mengontrol servo rear (steering) dan kecepatan 1 servo belakang (moving). Pada kasus saya, robot menggunakan [differential wheeled][3]. Keseluruhan fisik robot (yang diberi nama Semar Mesem ini) dibuat oleh Dadank, saya hanya menulis programnya saja. Saya tidak memegang skematiknya, tapi kurang lebih rangkaiannya terdiri dari:

 [1]: http://www.chibots.org/drupal/?q=node/339
 [2]: http://en.wikipedia.org/wiki/Steering
 [3]: http://en.wikipedia.org/wiki/Differential_wheeled_robot

*   Microcontroller ATMega16 dengan clock 4MHz
*   L298 untuk driver motor yang terhubung dengan PORD.1 – PORTD.6
*   10 Sensor (menggunakan phototransistor dan LED biru) yang terhubung ke IC LM339 (komparator). 8 sensor terhubung dengan PINA untuk sensor depan, 2 sensor (PINB.5 dan PINB.6) untuk bagian tengah kiri dan kanan ujung.
*   LCD 2×16 yang terhubung dengan PORTC
*   4 tactile switch yang terhubung dengan PINB.0 – PINB.3. Switch ini digunakan untuk tombol navigasi menu yang ditampilkan lewat LCD.

Bentuk jadinya robot :

<img src="http://gedex.web.id/wp-content/uploads/2008/07/dsc00023.jpg">

Photo lainnya yang memperlihatkan rangkaian dan gear motor bisa dilihat di:

[http://picasaweb.google.co.uk/gedex.adc/SemarMesem](http://picasaweb.google.co.uk/gedex.adc/SemarMesem)

Semar mesem menggunakan 8 sensor di depan untuk mengikuti garis. Lebar garis yang ideal untuk diikuti adalah 1.5 – 2 cm dengan kemungkinan 2 – 3 sensor dapat mengenai garis. Langkah selanjutnya adalah melakukan mapping nilai sensor untuk mendapatkan *process variable* (PV). Kurang lebih seperti berikut (misal nilai 0 merepresentasikan sensor mengenai garis):

{% highlight text %}
    11111110 (-7)        // ujung kiri
    11111000 (-6)
    11111100 (-6)
    11111101 (-5)
    11110001 (-4)
    11111001 (-4)
    11111011 (-3)
    11100011 (-2)
    11110011 (-2)
    11110111 (-1)
    11100111 (0)        // tengah
    11101111 (1)
    11000111 (2)
    11001111 (2)
    11011111 (3)
    10001111 (4)
    10011111 (4)
    10111111 (5)
    00011111 (6)
    00111111 (6)
    01111111 (7)        // ujung kanan
    11111111 (8 / -8)  // loss
{% endhighlight text %}

Kondisi ideal pada robot adalah bergerak maju lurus mengikuti garis, dengan kata lain PV = 0 (nilai sensor = 11100111). Dari sini bisa kita asumsikan Set Point (**SP**) / kondisi ideal adalah saat SP = 0. Nilai sensor yang dibaca oleh sensor disebut Process Variable (PV) / nilai aktual pembacaan. Menyimpangnya posisi robot dari garis disebut sebagai error (**e**), yang didapat dari `e = SP - PV`. Dengan mengetahui besar error, microcontroller dapat memberikan nilai PWM motor kanan dan kiri yang sesuai agar dapat menuju ke posisi ideal (SP = 0). Nah besar PWM ini bisa kita dapatkan dengan menggunakan kontrol Proportional (**P**), dimana `P = e * Kp` (Kp adalah konstanta proportional yang nilainya kita set sendiri dari hasil tuning). Misalkan nilai PWM didefinisikan dari 0 – 255 dengan nilai 0 berarti berhenti dan 255 berarti kecepatan penuh. Dari data nilai 8 sensor yang telah dimapping ada 16 PWM untuk tiap motor. Tapi dalam kondisi real dimisalkan saat sepelan-pelannya motor adalah PWM < 30 dan secepat-cepatnya (maju lurus) adalah 250. Saat PV = 8 atau -8 itu tergantung dari kondisi PV sebelumnya, jika PV lebih besar dari 0 maka, nilai PV adalah 8 dan jika PV kurang dari 0 maka nilai PV adalah -8. Kodenya bisa ditulis secara sederhana seperti berikut:

{% highlight c %}
    ...
    Kp = 1;
    SP = 0;
    MAXPWM = 255;
    MINPWM = 0;
    intervalPWM = (MAXPWM - MINPWM) / 8;

    void scan() {
        switch(sensor) {
            case 0b11111110:        // ujung kiri
                PV = -7;
                break;
            case 0b11111000:
            case 0b11111100:
                PV = -6;
                break;
            case 0b11111101:
                PV = -5;
                break;
            case 0b11110001:
            case 0b11111001:
                PV = -4;
                break;
            case 0b11111011:
                PV = -3;
                break;
            case 0b11100011:
            case 0b11110011:
                PV = -2;
                break;
            case 0b11110111:
                PV = -1;
                break;
            case 0b11100111:        // tengah
                PV = 0;
                break;
            case 0b11101111:
                PV = 1;
                break;
            case 0b11000111:
            case 0b11001111:
                PV = 2;
                break;
            case 0b11011111:
                PV = 3;
                break;
            case 0b10001111:
            case 0b10011111:
                PV = 4;
                break;
            case 0b10111111:
                PV = 5;
                break;
            case 0b00011111:
            case 0b00111111:
                PV = 6;
                break;
            case 0b01111111:        // ujung kanan
                PV = 7;
                break;
            case 0b11111111:        // loss

            if (PV < 0) {
                PV = -8;
            } else if (PV > 0) {
                PV = 8;
            }
        }

        error = SP - PV;
        P = Kp * error;

        MV = P;
        if (MV == 0) { //lurus, maju cepat
            lpwm = MAXPWM;
            rpwm = MAXPWM;
        } else if (MV > 0) { // alihkan ke kiri
            rpwm = MAXPWM - ((intervalPWM - 20) * MV);
            lpwm = (MAXPWM - (intervalPWM * MV) - 15);

            if (lpwm < MINPWM) lpwm = MINPWM;
            if (lpwm > MAXPWM) lpwm = MAXPWM;
            if (rpwm < MINPWM) rpwm = MINPWM;
            if (rpwm > MAXPWM) rpwm = MAXPWM;
        } else if (MV < 0) { // alihkan ke kanan
            lpwm = MAXPWM   ( ( intervalPWM - 20 ) * MV);
            rpwm = MAXPWM   ( ( intervalPWM * MV ) - 15 );

            if (lpwm < MINPWM) lpwm = MINPWM;
            if (lpwm > MAXPWM) lpwm = MAXPWM;
            if (rpwm < MINPWM) rpwm = MINPWM;
            if (rpwm > MAXPWM) rpwm = MAXPWM;
        }
    }

    }
    ...
{% endhighlight c %}

Nah dengan mengukur seberapa jauh robot menyimpang dari kondisi ideal, sistem kontrol P sudah diterapkan. Output (berupa nilai PWM) didapat dari perhitungan yang melibatkan hanya variabel `P = e * Kp`. Jika pergerakan robot masih terlihat bergelombang, bisa ditambahkan kontrol Derivative (**D**). Kontrol D digunakan untuk mengukur seberapa cepat robot bergerak dari kiri ke kanan atau dari kanan ke kiri. Semakin cepat bergerak dari satu sisi ke sisi lainnya, maka semakin besar nilai D. Konstanta D (Kd) digunakan untuk menambah atau mengurangi imbas dari derivative. Dengan mendapatkan nilai Kd yang tepat pergerakan sisi ke sisi yang bergelombang akibat dari proportional PWM bisa diminimalisasi. Nilai D didapat dari: `D = Kd * rate`, dimana `rate = e(n) - e(n-1)`. Dalam program nilai error (SP – PV) saat itu menjadi nilai last_error, sehingga rate didapat dari `error - last_error`
Untuk menambahkan kontrol D, program di atas dapat dimodifikasi menjadi :

{% highlight c %}
    Kd = 0.8;

    ...

    error = SP - PV;
    P = Kp * error;

    rate = error - last_error;
    D    = rate * Kd;

    last_error = error;

    MV = P   D;

    ...
{% endhighlight c %}

Jika dengan P D sudah membuat pergerakan robot cukup *smooth*, maka penambahan Integral menjadi opsional. Jika ingin mencoba-coba bisa ditambahakan Integral (**I**). I digunakan untuk mengakumulasi error dan mengetahui durasi error. Dengan menjumlahkan error disetiap pembacaan PV akan memberikan akumulasi offset yang harus diperbaiki sebelumnya. Saat robot bergerak menjauhi garis, maka nilai error akan bertambah. Semakin lama tidak mendapatkan SP, maka semakin besar nilai I. Degan mendapatkan nilai Ki yang tepat, imbas dari Integral bisa dikurangi. Nilai akumulasi error didapat dari: `I = I   error`. Nilai I sendiri : `I = I * Ki`. Jika dinginkan nilai `MV = P   I   D`, maka program di atas di modifikasi menjadi :

{% highlight c %}
    Kd = 0.8;
    Ki = 0.3;

    ...

    error = SP - PV;
    P = Kp * error;

    I = I   error;
    I = I * Ki;

    rate = error - last_error;
    D    = rate * Kd;

    last_error = error;

    MV = P   I   D;

    ...
{% endhighlight text %}

Keseluruhan [source code robot Semar Mesem dapat diunduh di sini][6]. Fitur menu belum sepenuhnya ada, silahkan modifikasi sesuai kebutuhan dan sesuaikan formula untuk lpwm dan rpwm dengan kecepatan motor DC yang digunakan. Video Semar Mesem bisa dilihat [di sini][7] dan [di sana][8]. Penggunaan PID di Semar Mesem masih sangat sederhana, jika dirasa ada yang salah dengan penggunaan PID atau mungkin cara mendapatkan nilai PWM yang tepat dari MV mohon dishare di sini. Knowledge is Belong to the World.

 [6]: http://gedex.web.id/wp-content/uploads/2008/07/tesmenu04.c "source code semar mesem"
 [7]: http://www.youtube.com/watch?v=fgrwD3nvwLM
 [8]: http://www.youtube.com/watch?v=NnnVGzKcCh4

Update Rangkaian dari Dadank:

<img src="http://gedex.web.id/wp-content/uploads/2008/09/line-tracer.gif">

Referensi:

* [http://en.wikipedia.org/wiki/PID_controller](http://en.wikipedia.org/wiki/PID_controller)
* [http://www.chibots.org/drupal/?q=node/339](http://www.chibots.org/drupal/?q=node/339)
