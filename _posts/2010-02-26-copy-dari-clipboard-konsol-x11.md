---
title: Copy dari clipboard konsol (X11)
author: gedex
layout: post
pvc_views:
  - 2589
categories:
  - linux
  - 'tips &amp; tricks'
tags:
  - xclip
---

Suatu saat Anda berada dalam konsol server yang tidak memiliki tetikus (*mouse*). Katakanlah Anda perlu mengkopi suatu berkas ke berkas lain, mungkin langkahnya seperti berikut:

1.  membuka suatu berkas (misal dengan vim), dan
2.  memblok seluruh baris lalu melakukan kopi (Ctrl-C), tutup berkas, dan
3.  membuka berkas lainnya untuk mem-paste-nya.

Ups, mungkin Anda lupa bagaimana perintah di Vim untuk memblok keseluruhan baris. Disini xclip membantu Anda. Hal yang umum dilakukan kita adalah mengkopi isi dari berkas SSH Public Key di dalam berkas ~/.ssh/id_rsa.pub. Contohnya:

`cat ~/.ssh/id_rsa.pub | xclip -sel clip`

Silahkan klik Ctrl-V di tempat yang Anda inginkan. Untuk yang belum terinstall xclip, silahkan unduh di [sini][1]. Untuk pengguna Ubuntu:

 [1]: http://sourceforge.net/projects/xclip/

`sudo apt-get install xclip`

Referensi:

