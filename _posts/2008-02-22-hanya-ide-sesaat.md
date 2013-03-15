---
title: Hanya Ide Sesaat
author: gedex
layout: post
pvc_views:
  - 680
categories:
  - elec
  - just FYI
  - my opinion
tags:
  - aplikasi desktop
  - database
  - dosen
  - LCD
  - PC
  - skripsi
  - speaker
  - web server
---

Lagi iseng ngelamunin alat skripsinya Ayu, jadi muncul ide. Mungkin basi, tapi sebenarnya cukup mudah, sederhana dan tidak terlalu mahal jika diimplementasikan, bahkan bisa menghasilkan sedikit uang jika ada yang berminat. Bisa ditawarkan ke sekolah, lembaga kursus atau bahkan institusi. Wait.. wait.. ngomongin apa sih? OK, karena kebetulan ada teman yang minta dibuatkan alat buat skripsinya, munculah suatu ide dari alat tersebut (jadi ini ide awalnya si Ayu, bukan gw). Sepertinya belum diaplikasikan di sebagian besar institusi. Alat yang dibuat sebenarnya sebuah tampilan (berupa LCD) yang menampilkan status dosen apakah masuk atau tidak masuk. Mudahkan? Karena ini buat mahasiswi TI, maka saya buat tidak terlalu ribet. Pakai modul uC (kit jadi), komunikasi serial antara modul uC dan PC, dan modul uC yang akan mengontrol tampilan LCD. Aplikasi yang berjalan di PC cukup dibuat mudah saja dengan aplikasi berbasis desktop. Nah, aplikasi desktop ini melakukan query ke database dosen. Sehingga di aplikasi ini, pengguna cukup memilih daftar dosen dari *dropdown list*, memberinya keterangan masuk atau tidak masuk. Ada *field* tambahan, misal jika tidak masuk bisa digunakan untuk memberi informasi tugas. Nah itu sederhananya alat skripsi teman saya. Mudahkan?

Ide tambahannya adalah, menjadikannya aplikasi di PC (server) menjadi berbasis web dan membuatnya online. Sehingga bila ada dosen yang sedang kencan di Bumi Wiyata dan tidak bisa datang, si dosen bisa mengakses melalui web (atau juga dibuatkan aplikasi yang di*embedd* di *mobile phone* dosen) dan memberitahu mahasiswanya yang di kelas. Jadi setiap kelas memiliki LCD informasi dosen tersebut. Toh, dengan ini tidak perlu lagi gaji tambahan untuk operator buat ngebacot. Eits, ngomong-ngomong ngebacot, saya jadi inget operator robot palang rel kereta api. Ya, selain outputnya display (LCD) bisa juga kan berupa voice.

Jadi yang dibutuhkan adalah 1 server web (bisa juga ditambahkan sms gateway, jika fitur mobile dibutuhkan), output di setiap kelas (bisa berupa LCD atau speaker) dan PC jadul untuk di setiap kelas. Modul uC bisa dibuang disini, karena komunikasi dengan device output bisa dihubungkan langsung dengan PC. Gimana?
