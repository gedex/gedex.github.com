---
title: ls direktori dalam format tree
author: gedex
layout: post
pvc_views:
  - 747
categories:
  - linux
  - 'tips &amp; tricks'
tags:
  - ls
  - tree
---

Apabila kita bekerja dengan konsol dan ingin mengetahui struktur direktori tertentu biasanya kita melakukannya dengan perintah `ls nama_direktori`, lalu kita `ls` lagi direktori di dalamnya. Jika kita bekerja di desktop, kita dapat mengetahui struktur direktori tertentu dengan membuka penjelajah berkas (*file browser*). Sebenarnya di konsol, ada perintah `tree` untuk melihat senarai direktori dalam format *tree*.

> tree – list contents of directories in a tree-like format.

Saya menggunakan ubuntu, cukup mudah menginstalnya jika perintah `tree` belum tersedia.

`sudo apt-get install tree`

Lalu kita lihat seperti apa keluarannya:

    akeda@akeda-desktop:~$ tree ~/www/keuangan/app/models
    /home/akeda/www/keuangan/app/models
    |-- activity.php
    |-- activity_child.php
    |-- behaviors
    |   |-- empty
    |   |-- formatable.php
    |   `-- money.php
    |-- budget.php
    |-- budget_detail.php
    |-- budget_detail_description.php
    |-- city.php
    |-- datasources
    |   `-- empty
    |-- funding_source.php
    |-- group.php
    |-- groups_module_action.php
    |-- journal_bank.php
    |-- journal_cash.php
    |-- journal_tax.php
    |-- menu.php
    |-- menu_type.php
    |-- module.php
    |-- module_action.php
    |-- province.php
    |-- site_setting.php
    |-- tax_type.php
    |-- transaction.php
    |-- transaction_revision.php
    |-- unit.php
    |-- unit_code.php
    |-- user.php
    |-- user_log.php
    `-- volume.php
    
    2 directories, 30 files
    



Sebernarnya keluaran hasil `tree` di atas berwarna tergantung tipe berkas dan ekstensinya (yang terdefinsi dalam `dircolors`). Untuk penggunaan lebih lanjut silahkan coba-coba dan baca `man tree`.
