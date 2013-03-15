---
title: Intelligent Control Systems??
author: gedex
layout: post
podPressPostSpecific:
  - 'a:6:{s:15:"itunes:subtitle";s:15:"##PostExcerpt##";s:14:"itunes:summary";s:15:"##PostExcerpt##";s:15:"itunes:keywords";s:17:"##WordPressCats##";s:13:"itunes:author";s:10:"##Global##";s:15:"itunes:explicit";s:2:"No";s:12:"itunes:block";s:2:"No";}'
pvc_views:
  - 944
categories:
  - campus
  - coding
  - elec
  - knowledge
---

Beberapa hari belakangan ini gw agak sibuk ngoprek robot, sampai-sampai gw nginep di kampus selama 4 hari. Deadline untuk memberikan laporan kemajuan adalah minggu ke-3 bulan maret 2007, Jadi, selasa kemarin adalah hari terakhir. Selama 4 hari di kampus gw masih bingung bagaimana memprogram navigasi robot dengan 6 sensor ultrasonic. Ada beberapa keterbatasan, diantaranya : referensi yang tepat dan arena sementara. Arena yang dibuat masih dari kardus dan lantai karpet tanpa ada garis putih disetiap kamar. Dan juga arena masih dibuat sebatas 1 kamar dari lokasi *home* robot. Penggunaan kardus sangat tidak memungkinkan, karena sedikit robot menabrak akan merubuhkan atau memiringkan dinding kardus itu sendiri. Hal ini tidak memungkin terjadinya *trigger* untuk *bumper switch*. Ya, rencananya robot yang gw buat juga akan memakai *bumper switch* 2 module IR (GP2D15) untuk membantu penghindaran dinding selain dari ultrasonic. Program yang gw buat juga masih ‘cupu’, sensor di trigger secara *sequential* dan data di*retrieve* satu persatu dari sensor paling kiri. Gw masih prioritaskan *side* kanan dan kiri, jadi bagian sensor kiri dan kanan akan dibandingkan lalu nilai komparasi akan menentukan pergerakan motor. Bagian depan sensor akan diperhitungkan setelahnya. Ugh.. wasting time. Cara yang lain yang ‘mungkin’ lebih efektif adalah memparallel semua sensor. Jadi sensor di trigger bersamaan, dan mcu akan mempolling setiap sensor untuk mengecek data yang duluan datang. Ada yang punya ide lebih baik?? Please let me know guys. Lalu dengan keterbatasan arena yang ‘baru 1/4′nya dan jauh dari realnya, bagaimana mau mensampling data sensor??

Intellient Control System belum diterapkan dalam robot. Terus terang, gw masih ngeblank abis di masalah Artificial Neural Network, Expert System dan Fuzzy Logic. Gw tipikal orang yang masih ngoprek-ngoprek dari *source code* yang ada, menganalisa lalu memodifikasi sesuai kebutuhan. Jadi sebenarnya ‘cepat lambatnya’ gw mengerjakan sebuah program adalah referensi *source code* yang berhubungan dengan objek yang sedang dikerjakan. Mungkin ini saatnya gw mulai mempelajari lagi konsep-konsep sistem kontrol cerdas. Mulai lagi deh nyari jurnal-jurnal dan e-book.

Terus bagaimana robotnya?? Ya.. kalau menghindari dinding sih dah bisa. Tapi sebenarnya di laporan kemajuan, robot sudah harus dapat menemukan dan mematikan lilin. Sensor UVTron sebenarnya sudah punya, namun belum ada waktu untuk nyobain. Ya.. gw gak berharap banyak bakal bisa diterima di tahap ke-2 ini, karena memang masih jauh dari kriteria yang diminta. Tetapi ‘kayaknya’ lolos ataupun gak lolos gw bakal ngerjain nih robot buat skripsi gw sendiri.
