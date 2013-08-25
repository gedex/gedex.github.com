---
title: PWM Motor DC dari ADC
author: gedex
layout: post
pvc_views:
  - 5418
categories:
  - coding
  - robot
  - tutorial AVR
tags:
  - adc pwm joystick kri
---

Kebetulan Mamank lagi buat PI untuk joystick yang mengatur PWM motor DC dari nilai ADC. Rangkaian yang dibuat sebelumnya dibuat tanpa menggunakan microcontroller. Nah sebenarnya kita bisa memanfaatkan microcontroller yang punya fitur ADC internal (seperti ATMega16 atau ATMega8535) untuk mengurangi komponen elektronik. Kebetulan ada yang bertanya lewat email mengenai program untuk ini, jadi sekalian saya jawab lewat posting ini. Rangkaian seperti ini banyak digunakan untuk joystick pengendali robot manual di KRI (Kontes Robot Indonesia). Saya menggunakan ADC0 (PINA.0) yang terhubung ke potensio untuk mengatur PWM motor kiri dan ADC1 (PINA.1) untuk motor kanan. PORTB untuk LCD dan PORTD ke driver motor DC. Rangkaian yang terhubung ke PIN ADC kurang lebih seperti ini :

<img src="http://gedex.web.id/wp-content/uploads/2008/07/adc01.jpg">

Nilai R1, R2, R3 dan R4 bisa 180, 220 atau 330 ohm. Resistor tersebut hanya menjaga agar VCC dan GND tidak langsung terhubung saat nilai R1 dan R2 kecil. R1 dan R2 adalah potensio 10k atau 50k. Program sederhananya bisa di download di [sini][2]. Saya akan jelaskan sedikit programnya. Karena range nilai adc adalah 1 – 255, maka saya ambil nilai tengah 126 – 128 untuk kondisi motor stop. Saat nilai adc lebih besar dari 128, maka motor akan bergerak maju (cw) dan range 129 – 255 menjadi nilai pengali PWM. Formula sederhananya untuk PWM saat motor bergerak maju adalah `( data_adc - 128 ) * 2`. Saat nilai adc kurang dari 126 maka motor akan bergerak mundur (ccw) dan range 1 – 125 menjadi nilai pengali PWM. Formula sederhananya untuk PWM saat motor bergerak mundur adalah `255 - (data_adc * 2)`. Saya menggunakan interrupt timer 0 dengan overflow untuk PWM motor. Nilai 255 adalah full speed (100%). LCD digunakan untuk mendebug nilai adc dan PWM (paling kiri adalah data untuk motor kiri, baris atas berupa nilai PWM dan status pergerakan motor dan baris bawah adalah nilai ADC0. Sedangkan sebelah kanan adalah data untuk motor kanan). Sesuaikan formula PWM dengan kecepatan motor DC yang ingin digunakan. Pada kasus saya, nilai PWM di bawah 15 sudah membuat motor berhenti. Semoga membantu.

 [2]: http://gedex.web.id/wp-content/uploads/2008/07/joystick01.c
