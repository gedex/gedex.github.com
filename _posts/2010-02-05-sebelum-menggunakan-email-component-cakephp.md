---
title: Sebelum Menggunakan Email Component CakePHP
excerpt: "Sebelum Menggunakan Email Component CakePHP"
author: gedex
layout: post
pvc_views:
  - 672
categories:
  - coding
  - 'tips &amp; tricks'
tags:
  - cakephp
  - mta
  - sendmail
---

Yang umum dalam halaman pendaftaran adalah selesai mendaftar akan ada konfirmasi telah mendaftar. Halaman konfirmasi tersebut bisa saja dengan halaman web atau dikirim ke email pendaftar. Kebetulan saya sedang mengerjakan hal serupa dimana konfirmasi juga dikirimkan ke email pendaftar. Saya menggunakan CakePHP untuk mengembangkan aplikasi, dimana telah tersedia komponen Email untuk memudahkan pekerjaan seperti ini. Penjelasan di [cookbook CakePHP, bagian Email Component](http://book.cakephp.org/view/176/Email) itu sudah cukup jelas dan sudah saya coba. Tapi jika Anda mengalami kendala tidak terkirimnya Email, mungkin saja sistem operasi Anda belum terinstall MTA (Mail Transfer Agent). Anda bisa gunakan sendmail. Instalasi MTA dan asosiasinya dengan DNS Server-nya tidak akan saya jelaskan disini, saya sendiripun belum pernah mencoba!. Untuk coba-coba saat pengembangan, Anda bisa menggunakan MTA sendmail.

<!-- more -->

Saya menggunakan Ubuntu, untuk menginstall-nya gunakan perintah ini:

{% highlight bash %}
sudo apt-get install sendmail mailutils
{% endhighlight %}

Untuk mencoba mengirim email bisa gunakan utiliti mail :

{% highlight bash %}
mail -s "Test" me@example.net < /var/log/email.info
{% endhighlight %}

Ini akan mengirim email ke me@example.net dengan subject Test dan isi pesannya adalah isi dari berkas `/var/log/email.info`. Kebetulan server development di tempat saya MTA-nya sudah terasosiasi dengan DNS Server-nya jadi saya bisa menerima email tersebut ke inbox gmail saya, tanpa masuk ke spam, from-nya otomatis terisi oleh nama_user_di_server_development@nama_domain. Jika belum terasosiasi dengan DNS-Server-nya akan nyangkut di spam. Jika sudah terinstall MTA dan bisa terkirim emailnya ke tujuan, saatnya mencobanya dengan CakePHP. Good luck!
