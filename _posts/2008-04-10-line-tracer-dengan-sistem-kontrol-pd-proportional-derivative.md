---
title: Line Tracer dengan Sistem Kontrol PD (Proportional Derivative)
author: gedex
layout: post
excerpt: "Line Tracer dengan Sistem Kontrol PD (Proportional Derivative)"
---

Misalkan kita mempunyai susunan sensor, tampak atas, seperti berikut:

    (4) ------ (3) - (2) -(1) ------ (0)

Dimana angka menunjukkan pin uC, katakanlah pada PORT C. Jadi kita menggunakan pin PORTC.0 untuk sensor paling kanan,
PORTC.1 untuk sensor tengah kanan, dst hingga PORTC.4 untuk sensor paling kiri. Untuk mempermudah, saya biasanya menggunakan
data mapping. Jadi kondisi sensor akan di mapping dengan data PWM motor. Katakanlah sensor line tracer itu aktif low,
jadi pin uC akan membaca logika 0 saat mengenai garis. Oke, karena ada 5 sensor maka akan ada 2^5 = 32 kemungkinan kondisi sensor.
Saya hanya akan membuat kedua robot bergerak maju, sehingga bisa di buat kontroler motor untuk bergerak satu arah saja.
Saya akan membuat beberapa nilai sensor (dalam hexa) saja sebagai contoh, sisanya bisa diimpementasikan sendiri. Berikut tabelnya:

    -----------------------------------------------
    Nilai sensor | PWM motor kiri | PWM motor kanan
    -----------------------------------------------
    0×11         | 0xEF           | 0xFF
    0×17         | 0xA0           | 0xFF
    0x1D         | 0xEF           | 0x9F
    0x0F         | 0×20           | 0xFF
    0x1E         | 0xEF           | 0x2F
    dst…         | dst…           | dst…

Saya mengimplementasikan PWM dengan menggunakan interrupt timer pada uC, dimana nilai 0xff adalah PWM full speed (100%)
dan motor akan berhenti dengan nilai 0. Pada kasus saya, motor kanan dan kiri akan mempunyai nilai PWM yang berbeda untuk
kecepatan aktual yang terlihat sama, jika dilihat pada tabel untuk membuat motor maju lurus nilai PWM kanan dan kiri berbeda 15 desimal.
Jika merujuk ke sunsunan sensor, nilai 0×11 menunjukkan tiga sensor tengah mengenai garis, sehingga PWM motor diberi hampir full agar
bergerak maju lurus. Kondisi 0×17 mengharuskan robot bergerak serong kiri dan kondisi 0x1E mengharuskan robot banting kanan.
Dengan cara mapping nilai sensor dari PINC dengan data PWM kita sudah mengimplementasikan sistem kontrol proportional,
dimana gain motor akan mempunyai proporsi sesuai nilai sensor yg diinput ke PINC. Untuk menulisnya dengan bahasa C,
saya akan menggunakan array untuk menampung data PWM, berikut potongan programnya:

{% highlight c %}
    /**
     * isikan data PWM motor kiri dan kanan
     * sesuai dengan 32 kondisi sensor
     */
    unsigned char PWMKiri[32] = { 0x00, 0x00, ... }
    unsigned char PWMKanan[32] = { 0x00, 0x00, ... }
    unsigned char state;

    void scan() {
        state = PINC & 0x1F; //baca PINC.0 - PINC.4
        /**
         * beri nilai PWM motor kiri dengan
         * data PWMKiri dan PWMkanan
         * dimana indexnya adalah kondisi sensor
         */
        PWMKiriVal = PWMKiri[state];
        PWMKananVal = PWMKanan[state];
    }
{% endhighlight c %}

Untuk menambahkan kontrol derivative, kita perlu menggunakan delta PWM. Kita perlu mencatat data PWM sebelumnya.
Kita bisa mengubah fungsi scan menjadi:

{% highlight c %}
    //variabel untuk menampung nilai PWM sebelumnya
    unsigned char last_state, d;

    //jika dipanggil tanpa argumen, fungsi scan hanya sistem kontrol proportional
    void scan(d = false) {
        state = PINC & 0x1F;

        //jika dipanggil dengan scan(1), aktifkan fungsi proportioal-derivative
        if (d) {
            PWMKiriVal = PWMKiri[state]   (PWMKiri[state] - PWMKiri[last_state]);
            PWMKananVal = PWMKanan[state]   (PWMKanan[state] - PWMKanan[last_state]);
        } else { //sistem proportional saja
             /* beri nilai PWM motor kiri dan kanan
             * dimana indexnya adalah kondisi sensor
             */
            PWMKiriVal = PWMKiri[state];
            PWMKananVal = PWMKanan[state];
        }
    last_state = state;
    }
{% endhighlight c %}

Sistem derivative di atas hanya gambaran bagaimana menerapkan sistem kontrol PD, dan agak redundant jika digunakan dalam robot
sederhana dengan 5 sensor. Dalam mendesain sistem derivative perlu diperhatikan apakah penyimpangan error dalam kondisi sistem
itu cukup signifikan untuk membuat sistem bergerak stabil jika ditambahkan ke dalam sistem kontrol. Jika masih bingung apa itu sistem PID,
coba di googling. Sebagai pendahuluan coba baca [artikel PID di Wikipedia][1].

 [1]: http://en.wikipedia.org/wiki/PID_controller
