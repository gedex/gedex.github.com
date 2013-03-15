---
title: Menggunakan Jalur I2C
author: gedex
layout: post
pvc_views:
  - 4014
categories:
  - elec
  - knowledge
  - tutorial AVR
tags:
  - I2C
---

Saya tulis ini sebagai awalan sebelum memulai interfacing dengan CMPS03 dengan cara I2C. Sebenarnya saya dulu sempat menulis mengenai I2C di text file di komputer, tapi entah kemana file itu sekarang. OK langsung saja, I2C (Inter-Integrated Circuit), dibaca *aytusi*, merupakan jalur komunikasi serial multi-master yang dikembangkan oleh Philips, sekarang menjadi tanggung jawab NXP (perusahaan semikonduktor yang didirikan Philips). Ada beberapa versi spesifikasi yang dikeluarkan. Versi awal yang dibuat pada tahun 1982 hanya dapat mencapai kecepatan 100 Kbit/s (standard mode) dan pengalamatan hanya sebesar 7 bit. Hingga tahun 1992 (versi 1.0) kecepatan masih mencapai 100 Kbit/s, namun ada penambahan mode (Fast-mode) yang dapat mencapai kecepatan 400 Kbit/s (Fast-mode hanya kompatibel dengan versi terdahulu (downward)). Versi 2.0 (tahun 1998) menjadikan jalur I2C standar de facto yang diimplementasikan lebih dari 1000 IC yang berbeda dan dilisensikan ke 50 lebih perusahaan. Modifikasi versi 2.0 ini meliputi penambahan mode High-speed mode (Hs-mode) yang dapat meningkatkan bit rate sampai 3.4 Mbit/s. Perangkat dengan Hs-mode dapat berkomunikasi dengan perangkat lainnya (dalam satu jalur I2C) yang memiliki bit rate antara 0 s/d 3.4 Mbit/s (jadi kompatibel dengan Hs-mode dan standard mode). Tahun 2000 keluar lagi versi 2.1 dan saat tulisan ini saya buat spesifikasi I2C saat ini sudah mencapai [versi 3.0][1]. Menurut saya seharusnya I2C ini masuk ke dalam materi kuliah yang berhubungan dengan interfacing. Saya tidak tahu apakah I2C pernah dibahas pada saat mata kuliah interfacing, karena saya jarang masuk kuliah.

 [1]: http://www.nxp.com/acrobat/usermanuals/UM10204_3.pdf

Sebenarnya jalur I2C banyak digunakan di PC, telpon selular, radio mobil, TV, sistem terintegrasi di rumah dan perkantoran dan bahkan kartu berganda di blade server. Apa sih yang membuat I2C begitu menarik dan banyak digunakan di perangkat digital? Well, dengan I2C kita hanya membutuhkan dua jalur untuk berkomunikasi antar perangkat. Kita tidak memerlukan address decoder untuk mengimplementasi jalur I2C. Nah dua jalur tersebut adalah **SDA (Serial Data)** dan **SCL (Serial Clock)**. SCL merupakan jalur yang digunakan untuk mensinkronisasi transfer data pada jalur I2C, sedangkan SDA merupakan jalur untuk data. Beberapa perangkat dapat terhubung ke dalam jalur I2C yang sama dimana SCL dan SDA terhubung ke semua perangkat tersebut, hanya ada satu perangkat yang mengontrol SCL yaitu perangkat master. Jalur dari SCL dan SDA ini terhubung dengan pull-up resistor yang besar resistansinya tidak menjadi masalah (bisa 1K, 1.8K, 4.7K, 10K, 47K atau nilai diantara range tersebut). Kurang lebih gambarnya seperti ini:

http://gedex.web.id/wp-content/uploads/2008/05/i2c.gif

Gambar 1. Contoh implementasi jalur I2C

Dengan adanya pull-up disini, jalur SCL dan SDA menjadi [open drain][4], yang maksudnya adalah perangkat hanya perlu memberikan output 0 (LOW) untuk membuat jalur menjadi LOW, dan dengan membiarkannya pull-up resistor sudah membuatnya HIGH. Kembali ke I2C, umumnya dalam I2C ada satu perangkat yang berperan menjadi master (meskipun dimungkinkan beberapa perangkat, dalam jalur I2C yang sama, menjadi master) dan satu atau beberapa perangkat slave. Dalam jalur I2C, hanya perangkat master yang dapat mengontrol jalur SCL yang berarti transfer data harus diinisialisasi terlebih dahulu oleh perangkat master melalui serangkaian pulsa clock (slave tidak bisa, tapi ada satu kasus yang disebut clock streching). Tugas perangkat slave hanya merespon apa yang diminta master. Slave dapat memberi data ke master dan menerima data dari master setelah server melakukan inisialisasi. Misalkan microcontroller (uC) adalah perangkat master yang terhubung dalam satu I2C dengan perangkat-perangkat slave seperti modul pengendali motor servo, modul kompas dan sensor lainnya. Nah uC dapat mengontrol pergerakan servo dengan memberikan data ke modul servo, mendapatkan data kompas dengan memerintahkan modul kompas agar mengirimkan data. Semua itu hanya dibutuhkan 2 jalur dengan tambahan 2 resistor sebagai pull-up. Lalu bagaimana membedakan slave tersebut adalah modul servo atau modul kompas? Menggunakan pengalamatan tentunya, dimana setiap perangkat slave itu mempunyai alamat yang unik.

 [4]: http://www.en.wikipedia.org/wiki/Open_drain "Open Drain"

Sebelum saya bahas lebih jauh mengenai pengalamatan, saya akan bahas dulu mengenai sinyal-sinyal yang digunakan dalam protokol I2C. Sebagaimana telah dijelaskan sebelumnya, bahwa master terlebih dahulu menginisialisasi sebelum memulai transfer data antara slave-nya. Inisialisasi diawali dengan sinyal START (transisi high ke low pada jalur SDA dan kondisi high pada jalur SCL, lambang S pada gambar 2), lalu transfer data dan sinyal STOP (transisi low ke high pada jalur SDA dan kondisi high pada jalur SCL, lambang P pada gambar 2) untuk menandakan akhir transfer data.

http://gedex.web.id/wp-content/uploads/2008/05/start_stop.gif

Gambar 2. Sinyal untuk START dan STOP (sumber: UM10204 I2C-bus specification and user manual)

Banyaknya byte yang dapat dikirimkan dalam satu transfer data itu tidak ada aturannya. Jika transfer data yang ingin dilakukan sebesar 2 byte, maka pengiriman pertama adalah 1 byte dan setelah itu 1 byte. Setiap byte yang di transfer harus diikuti dengan bit Acknowledge (ACK) dari si penerima, menandakan data berhasil diterima. Byte yang dikirim dari pengirim diawali dari bit MSB. Saat bit dikirim, pulsa clock (SCL) di set ke HIGH lalu ke LOW. Bit yang dikirim pada jalur SDA tersebut harus stabil saat periode clock (SCL) HIGH. Kondisi HIGH atau LOW dari jalur data (SDA) hanya dapat berubah saat kondisi sinyal SCL itu LOW.

http://gedex.web.id/wp-content/uploads/2008/05/1_bit.gif

Gambar 3. Transfer bit pada jalur I2C (sumber: UM10204 I2C-bus specification and user manual)

Setiap pulsa clock itu dihasilkan (di jalur SCL) untuk setiap bit (di jalur SDA) yang ditransfer. Jadi untuk pengiriman 8 bit akan ada 9 pulsa clock yang harus dihasilkan (1 lagi untuk bit ACK). Kronologi sebelum perangkat penerima memberikan sinyal ACK adalah sebagai berikut: saat pengirim selesai mengirimkan bit ke-8, pengirim melepaskan jalur SDA ke pull-up (ingat penjelasan open drain di atas) sehingga menjadi HIGH. Nah saat kondisi tersebut terjadi, penerima harus memberikan kondisi LOW ke SDA saat pulsa clock ke-9 berada dalam kondisi HIGH.

http://gedex.web.id/wp-content/uploads/2008/05/8_bit.gif

Gambar 4. Data (byte) transfer pada jalur I2C (sumber: UM10204 I2C-bus specification and user manual)

Jika SDA tetap dalam kondisi HIGH saat pulsa clock ke-9, maka ini didefinisikan sebagai sinyal Not Acknowledge (NACK). Master dapat menghasilkan sinyal STOP untuk menyudahi transfer, atau mengulang sinyal START untuk memulai transfer data yang baru. Ada 5 kondisi yang menyebabkan NACK:

1.  Tidak adanya penerima dengan alamat yang diminta pada jalur, sehingga tidak ada perangkat yang merespon ACK.
2.  Penerima tidak dapat menerima atau mengirim karena sedang mengeksekusi fungsi lain dan tidak siap untuk memulai komunikasi dengan master.
3.  Pada saat transfer data, penerima mendapatkan data atau perintah yang tidak dimengerti oleh penerima.
4.  Pada saat transfer data, penerima tidak dapat menerima lagi byte data yang dikirimkan.
5.  Penerima-master perlu memberi sinyal pengakhiran transfer data ke penerima-slave.

Penjelasan di atas adalah sekilas mengenai protokol sinyal yang saya ambil dari spesifikasi I2C. Bagaimana untuk pengalamatan pada perankat-perangkat yang terhubung dalam jalur I2C? Pengalamatan dalam I2C bisa 7 bit atau 10 bit. Pengalamatan 10 bit jarang digunakan dan juga tidak dibahas di sini. Semua perangkat (uC dan modul-modul) yang terhubung ke dalam jalur I2C yang sama dapat dialamati sebanyak 7 bit. Ini berarti sebuah jalur I2C dengan pengalamatan 7 bit dapat menampung 128 (2^7) perangkat. Saat mengirimkan data alamat (yang 7 bit itu), kita tetap mengirim data 1 byte (8 bit). 1 bit lagi digunakan untuk menginformasikan perangkat slave apakah master menulis (write) data ke slave atau membaca (read) data dari slave. Jika bit tersebut 0, maka master menulis data ke slave. Jika bit tersebut 1, maka master membaca data dari slave. Bit ini (untuk infomasi tulis/baca) merupakan LSB, sedangkan sisanya adalah data alamat 7 bit. Berikut adalah contoh sinyal yang dimulai dengan data alamat lalu data yang ingin ditransfer ke alamat tersebut:

http://gedex.web.id/wp-content/uploads/2008/05/alamat_data.gif

Gambar 5. Sinyal alamat dan data (sumber: UM10204 I2C-bus specification and user manual)

Sebaiknya saat mengalamati perangkat-perangkat dalam I2C anggap saja menggunakan 8-bit. Jika menggunakan 7 bit justru akan membingungkan. Misal diberikan alamat 0×14 (dalam penghitungan 7 bit), maka untuk menulis ke alamat 0×14 kita harus memberikan byte 0×28 dengan menggesernya 1 bit (bit 0 pada LSB berarti menulis). Contoh yang memudahkan adalah CMPS03 yang memiliki alamat 0xC0 (perhitugan 8 bit). Untuk menulis ke CMPS03 kita menggunakan 0xC0 dan untuk membaca dari CMPS03 kita menggunakan 0xC1.

Saya rasa penjelasan di atas sudah dapat (sedikit) merepresentasikan protokol fisikal I2C. Bagaimana dari perangkat lunak (software) untuk mengimplementasikan protokol I2C di atas? Saya akan mengambil contoh dari rutin Peter Fleury dan dari rutin I2C CodeVisionAVR (yang menggunakan bahasa C). Hal yang pertama kali terjadi dalam komunikasi ini adalah server mengirimkan sinyal START (lihat gambar 2). Ini akan menginformasikan perangkat-perangkat slave yang terhubung dalam jalur I2C bahwa akan ada transfer data yang ingin dilakukan oleh master dan para slave harus siap memantau siapa yang akan dipanggil alamatnya. Selanjutnya master akan mengirimkan data berupa alamat slave yang ingin diakses. Perangkat slave yang sesuai dengan alamat yang diberikan master akan meneruskan transaksi data, slave lainnya dapat mengacuhkan transaksi tersebut dan menunggu sampai sinyal berikutnya. Setelah mendapatkan slave dengan alamat tersebut, saatnya master memberitahukan alamat internal atau nomor register yang ingin ditulis atau dibaca dari slave tersebut. Jumlah lokasi atau nomor register tersebut tergantung pada perangkat slave yang diakses. Ada beberapa yang memiliki dan ada beberapa yang tidak. Misal CMPS03, modul ini memiliki 16 lokasi dengan penomoran 0-15. Contoh lain adalah SFR08 (modul sensor ultrasonic) dengan 36 register internal yang bisa diakses. Setelah mengirim data berupa alamat slave dan kemudian data alamat internal register slave yang ingin diakses, kini saatnya master mengirim byte data. Master dapat melanjutkan mengirim byte data ke slave dan byte-byte akan ditampung di register setelahnya karena slave secara otomatis akan menaikkan alamat internal register setelah setiap byte. Ketika master selesai menulis semua data ke slave, master akan mengirim sinyal STOP untuk mengakhiri transaksi data. Jadi untuk menulis ke slave langkahnya adalah:

1.  Mengirim sinyal START
2.  Mengirim alamat slave serta operasi yang akan dilakukan (LSB)
3.  Mengirim nomor internal register yang ditulis
4.  Mengirim byte data
5.  Mengirim sinyal STOP

Misalkan kita memiliki SFR08 dengan alamat default dari pabrik 0xE0. Untuk mulai memancarkan gelombang ultrasonic SFR08 kita harus menulis data 0x51ke register command di alamat 0×00, seperti:

1.  Mengirim sinyal START
2.  Mengirim data 0xE0 (alamat I2C dari SFR08 dengan operasi tulis)
3.  Mengirim data 0×00 (Alamat internal dari register command)
4.  Mengirim data 0×51 (Perintah untuk mulai memancarkan)
5.  Mengirim sinyal STOP

Bagaimana untuk membaca? Ini agak sedikit ribet. Sebelum membaca data dari slave, master harus memberitahu alamat internal mana yang ingin dibaca. Jadi operasi baca dari slave sebenarnya dimulai dulu dengan operasi tulis. Ini sama seperti operasi tulis. Master mengirim sinyal START, alamat I2C slave dengan LSB utk operasi tulis/baca dan nomor internal register yang ingin ditulis. Setelah itu master mengirim sinyal START lagi (terkadang disebut ‘restart’) dan alamat I2C slave lagi – tapi kali ini set LSB ke 1 untuk operasi baca. Lalu master dapat mulai membaca banyak byte data yang diinginkan dan menyudahi transaksi dengan mengirimkan sinyal STOP. Misal untuk membaca data byte arah mata angin dari modul CMPS03:

1.  Mengirim sinyal START
2.  Mengirim data 0xC0 (alamat I2C dari CMPS03 dengan LSB 0 untuk operasi tulis)
3.  Mengirim data 0×01 (alamat internal dari register untuk baca byte kompas)
4.  Mengirim sinyal START lagi
5.  Mengirim data 0xC1 (alamat I2C dari CMPS03 dengan LSB 1 untuk operasi baca)
6.  Membaca byte data dari CMPS03
7.  Mengirim sinyal STOP

Rentetan bit untuk pembacaan CMPS03 kurang lebih seperti gambar di bawah ini:

http://gedex.web.id/wp-content/uploads/2008/05/read_cmps03.gif

Gambar 6. Pembacaan byte dari CMPS03 (sumber: http://www.robot-electronics.co.uk/images/i2c.GIF)

Sejauh ini contoh di atas adalah komunikasi I2C secara sederhana, ada satu yang cukup ribet. Saat master membaca data dari slave, maka slave lah yang mengirimkan bit-bit di jalur SDA, tapi tetap master yang mengontrol pulsa clock di jalur SCL. Bagaimana jika slave belum siap mengirimkan data? Dengan perangkat semacam EEPROM, hal ini bukan masalah, tapi jika perangkat slave adalah microprocessor atau microcontroller yang juga mengeksekusi instruksi lainnya hal ini bisa menjadi masalah. uC yang merupakan perangkat slave perlu mengeksekusi rutin interrupt, menyimpan register kerja saat itu, mencari tahu alamat yang diminta master untuk dibaca, ambil data dari alamat tersebut dan memberikannya ke register pengirim. Hal ini membutuhkan beberapa uS untuk dapat terjadi, sementara master memberikan pulsa clock di jalur SCL yang mana slave belum bisa merepson. Protokol I2C menyediakan solusi untuk ini: Slave diperbolehkan untuk membuat jalur SCL LOW. Hal ini disebut dengan clock stretching. Ketika slave mendapatkan perintah baca dari master, slave dapat membuat jalur SCL LOW. Slave uC lalu mendapatkan data yang diminta, memberikannya ke register pengirim dan membiarkan kembali jalur SCL agar pull-up resistor kembali membuatnya HIGH. Dari sisi master, jalur SCL akan diberi sinyal HIGH lalu akan dibaca apakah jalur tersebut benar-benar HIGH. Jika masih dalam kondisi LOW maka itu adalah ulah slave dan master harus menunggu sampai kondisi HIGH kembali. Untungnya perangkat keras pada kebanyakan port I2C uC dapat menangani hal ini secara otomatis.

Untuk implemetasi kode I2C saya mengambil contoh rutin I2C untuk AVR oleh [Peter Fleury][10] dan dari rutin-rutin I2C yang diberikan CodeVisionAVR. Karena hanya ada dua jalur, maka definisikan 2 pin untuk SCL dan SDA:

 [10]: http://jump.to/fleury

{% highlight c %}

    ;***** Adapt these SCA and SCL port and pin definition to your target !!
    ;
    #define SDA         4        // SDA Port D, Pin 4
    #define SCL        5        // SCL Port D, Pin 5
    #define SDA_PORT        PORTD           // SDA Port D
    #define SCL_PORT        PORTD           // SCL Port D

    ;******

    ;-- map the IO register back into the IO address space
    #define SDA_DDR        (_SFR_IO_ADDR(SDA_PORT) - 1)
    #define SCL_DDR        (_SFR_IO_ADDR(SCL_PORT) - 1)
    #define SDA_OUT        _SFR_IO_ADDR(SDA_PORT)
    #define SCL_OUT        _SFR_IO_ADDR(SCL_PORT)
    #define SDA_IN        (_SFR_IO_ADDR(SDA_PORT) - 2)
    #define SCL_IN        (_SFR_IO_ADDR(SCL_PORT) - 2)

{% endhighlight c %}


Untuk menginsialisasi port yang digunakan sebagai SCL dan SDA kita perlu menset pin tersebut dengan memanggil rutin di bawah ini sekali:

{% highlight text %}
    i2c_init:
    cbi SDA_DDR,SDA        ;release SDA
    cbi SCL_DDR,SCL        ;release SCL
    cbi SDA_OUT,SDA
    cbi SCL_OUT,SCL
    ret
{% endhighlight text %}

Kita perlu menggunakan rutin untuk delay sesaat antara pergantian SCL dan SDA sesuai dengan timing diagram pada spesifikasi.

{% highlight text %}
    i2c_delay_T2:        ; 4 cycles
    rjmp 1      ; 2   "
    1:    rjmp 2      ; 2   "
    2:    rjmp 3      ; 2   "
    3:    rjmp 4      ; 2   "
    4:    rjmp 5      ; 2   "
    5:     rjmp 6      ; 2   "
    6:    nop          ; 1   "
    ret          ; 3   "
    ; total 20 cyles = 5.0 microsec with 4 Mhz crystal
{% endhighlight text %}

Empat rutin di bawah ini menyediakan pensinyalan sederhana untuk START, STOP, operasi baca dan operasi tulis.

{% highlight text %}
    i2c_start:
    sbi     SDA_DDR,SDA    ;force SDA low
    rcall     i2c_delay_T2    ;delay T/2
    rcall     i2c_write    ;write address
    ret

    i2c_stop:
    sbi    SCL_DDR,SCL    ;force SCL low
    sbi    SDA_DDR,SDA    ;force SDA low
    rcall    i2c_delay_T2    ;delay T/2
    cbi    SCL_DDR,SCL    ;release SCL
    rcall    i2c_delay_T2    ;delay T/2
    cbi    SDA_DDR,SDA    ;release SDA
    rcall    i2c_delay_T2    ;delay T/2
    ret

    i2c_write:
    sec            ;set carry flag
    rol     r24        ;shift in carry and out bit one
    rjmp    i2c_write_first
    i2c_write_bit:
    lsl    r24        ;if transmit register empty
    i2c_write_first:
    breq    i2c_get_ack
    sbi    SCL_DDR,SCL    ;force SCL low
    brcc    i2c_write_low
    nop
    cbi    SDA_DDR,SDA    ;release SDA
    rjmp    i2c_write_high
    i2c_write_low:
    sbi    SDA_DDR,SDA    ;force SDA low
    rjmp    i2c_write_high
    i2c_write_high:
    rcall     i2c_delay_T2    ;delay T/2
    cbi    SCL_DDR,SCL    ;release SCL
    rcall    i2c_delay_T2    ;delay T/2
    rjmp    i2c_write_bit

    i2c_get_ack:
    sbi    SCL_DDR,SCL    ;force SCL low
    cbi    SDA_DDR,SDA    ;release SDA
    rcall    i2c_delay_T2    ;delay T/2
    cbi    SCL_DDR,SCL    ;release SCL
    i2c_ack_wait:
    sbis    SCL_IN,SCL    ;wait SCL high (in case wait states are inserted)
    rjmp    i2c_ack_wait

    clr    r24        ;return 0
    sbic    SDA_IN,SDA    ;if SDA high -> return 1
    ldi    r24,1
    rcall    i2c_delay_T2    ;delay T/2
    clr    r25
    ret

    i2c_readNak:
    clr    r24
    rjmp    i2c_read
    i2c_readAck:
    ldi    r24,0x01
    i2c_read:
    ldi    r23,0x01    ;data = 0x01
    i2c_read_bit:
    sbi    SCL_DDR,SCL    ;force SCL low
    cbi    SDA_DDR,SDA    ;release SDA (from previous ACK)
    rcall    i2c_delay_T2    ;delay T/2

    cbi    SCL_DDR,SCL    ;release SCL
    rcall    i2c_delay_T2    ;delay T/2

    i2c_read_stretch:
    sbis SCL_IN, SCL        ;loop until SCL is high (allow slave to stretch SCL)
    rjmp    i2c_read_stretch

    clc            ;clear carry flag
    sbic    SDA_IN,SDA    ;if SDA is high
    sec            ;  set carry flag

    rol    r23        ;store bit
    brcc    i2c_read_bit    ;while receive register not full

    i2c_put_ack:
    sbi    SCL_DDR,SCL    ;force SCL low
    cpi    r24,1
    breq    i2c_put_ack_low    ;if (ack=0)
    cbi    SDA_DDR,SDA    ;      release SDA
    rjmp    i2c_put_ack_high
    i2c_put_ack_low:                ;else
    sbi    SDA_DDR,SDA    ;      force SDA low
    i2c_put_ack_high:
    rcall    i2c_delay_T2    ;delay T/2
    cbi    SCL_DDR,SCL    ;release SCL
    i2c_put_ack_wait:
    sbis    SCL_IN,SCL    ;wait SCL high
    rjmp    i2c_put_ack_wait
    rcall    i2c_delay_T2    ;delay T/2
    mov    r24,r23
    clr    r25
    ret

{% endhighlight text %}

Sedangkan untuk CodeVisionAVR cukup mudah, tapi kita tidak tahu detail implementasi kode setiap rutin jadi cukup dengan mendefinisikan dan memanggil fungsi yang tersedia. Karena dibutuhkan dua jalur, kita hanya membutuhkan 2 pin pada uC AVR. Untuk menggunakan rutin I2C AVR definisikan pin untuk SCL dan SDA:

{% highlight c %}
    #asm
    .equ __i2c_port=0x1B ;port A
    .equ __sda_bit=0
    .equ __scl_bit=1
    #endasm
    #include
{% endhighlight c %}

Ada 5 fungsi yang bisa digunakan setelah pemanggilan header , yaitu:

1.  `void i2c_init(void)` untuk menginsialisasi jalur I2C.
2.  `unsigned char i2c_start(void)` untuk memberikan sinyal START, akan mengembalikan nilai 1 jika jalur berada dalam keadaan bebas atau 0 jika sedang sibuk.
3.  `unsigned char i2c_stop(void)` untuk memberikan sinyal STOP.
4.  `unsigned char i2c_read(unsigned char ack)` untuk membaca byte dari slave. Parameter ack digunakan untuk menentukan apakah sinyal ACK diperlukan setelah menerima byte dari slave. Jika ack diset ke 0 maka tidak ada sinyal ACK setelah pembacaan byte, jika 1 akan ada sinyal ACK setelah pembacaan.
5.  `unsigned char i2c_write(unsigned char data)` untuk menulis byte dari slave. Parameternya merupakan byte yang ingin ditulis. Fungsi ini akan mengembalikan nilai 1 jika slave mensinyalkan ACK dan 0 jika tidak ada sinyal ACK dari slave.

Contoh penggunaannya untuk membaca byte dari register 1 CMPS03:

{% highlight c %}
    unsigned char data;

    i2c_start();
    i2c_write(0xC0);
    i2c_write(0x01);
    i2c_start();
    i2c_write(0xC1);
    data=i2c_read(0);
    i2c_stop();
{% endhighlight c %}

Semoga bisa membantu untuk memahami I2C, postingan selanjutnya saya akan menitik beratkan ke CMPS03 dan AVRnya.

Referensi:

*   [I2C bus Specification][11]
*   [Introduction to Using I2C][12]
*   [Using the I2C Bus][13]

 [11]: http://www.semiconductors.philips.com/acrobat/literature/9398/39340011.pdf
 [12]: http://www.standardics.nxp.com/support/i2c/usage/ "Introduction to Using I2C"
 [13]: http://www.robot-electronics.co.uk/htm/using_the_i2c_bus.htm "Using the I2C Bus"
