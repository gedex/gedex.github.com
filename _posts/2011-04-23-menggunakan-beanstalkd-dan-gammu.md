---
title: Menggunakan Beanstalkd dan Gammu
author: gedex
layout: post
pvc_views:
  - 682
categories:
  - coding
  - python
tags:
  - beanstalkd
  - gammu
  - pybeanstalk
---

Gammu menyediakan SMS Daemon, `gammu-smsd`, yang akan men-*scan* sms yang diterima (inbox) dan menempatkan pengiriman sms ke dalam antrian. `gammu-smsd` menggunakan *storage* (baik files maupun database) untuk menyimpan pesan di inbox ataupun antrian outbox. Jika menggunakan SMS daemon untuk mengirim sms kita tidak perlu khawatir akan kondisi *concurrent*, karena pesan sms akan di-*enqueue* dulu di storage. Jika kita hanya menggunakan perintah `gammu` saja, yaitu misal dengan : `gammu --sendsms TEXT 081315528932 -text "test"`, maka jika ada dua proses yang waktunya hampir bersamaan, salah satu proses akan mendapatkan *device* dalam keadaan *busy*, dan gagal pengiriman sms untuk proses yang telat waktu bacanya.

Menggunakan SMS Daemon sudah cukup jika dalam sistem dibutuhkan suatu antrian, dan kondisi balapan antar proses tidak begitu besar. Tapi sayangnya SMS Daemon menggunakan *storage* untuk antrian pesan, dan lagi terlalu memakan *cost* CPU dan *storage* jika pesan sms digunakan hanya untuk konfirmasi. Jika diinginkan sistem antrian yang lebih cepat, menggunakan memory, maka kita dapat menggunakan utility `gammu` saja dan mengimplementasikan proses queue sendiri yang hanya menggunakan memory. Beruntung ada [Beanstalkd][1] yang merupakan queue sederhana. Instalasi beanstalkd cukup mudah, silahkan baca berkas README-nya. Beanstalkd memiliki banyak [pustaka client][2], kali ini saya akan menggunakan [pybeanstalk][3]. Gammu menyediakan python-gammu API, cukup memudahkan untuk menggunakan fitur-fitur Gammu dalam Python. Sebagai ilustrasi penggunaan, saya akan membuat dua buah berkas, yaitu `producer_send_sms_job.py` dan `consumer_to_send_sms_job.py`. Berkas `producer_send_sms_job.py` adalah *producer* yang akan terus-menerus mengirimkan job ke beanstalkd. Job yang dibuat berisi string “nomor tujuan||pesan sms”. Data string dari producer akan di split oleh *consumer* sehingga didapatkan pesan sms yang akan dikirim serta nomor tujuannya.

 [1]: http://kr.github.com/beanstalkd/
 [2]: https://github.com/kr/beanstalkd/wiki/Client-Libraries
 [3]: http://code.google.com/p/pybeanstalk/

Isi berkas `producer_send_sms_job.py` :

{%highlight python %}
# stdlib imports
import sys
import time

# pybeanstalk imports
from beanstalk import serverconn
from beanstalk import job

def producer_main(connection):
    i = 0
    number = '0813155289xx' # nomor tujuan
    msg = 'Test'

    while True:
        data = '%s||%s' % (number,msg)
        print data
        data = job.Job(data=data, conn=connection)
        data.Queue()
        time.sleep(1)

def main():
    try:
        print 'handling args'
        server = sys.argv[1]
        try:
            port = int(sys.argv[2])
        except:
            port = 11300

        print 'setting up connection'
        connection = serverconn.ServerConn(server, port)
        connection.job = job.Job
        producer_main(connection)
    except Exception, e:
        print "usage: example.py server [port]"
        raise
        sys.exit(1)

if __name__ == '__main__':
    main()
{%endhighlight python %}

Isi berkas `consumer_to_send_sms_job.py` :

{%highlight python %}
# stdlib imports
import sys
import time

# pybeanstalk imports
from beanstalk import serverconn
from beanstalk import job

# gammu
import gammu

def consumer_main(connection):
    print 'Init phone...'
    sm = gammu.StateMachine()
    sm.ReadConfig(Filename = '/root/.gammurc')
    sm.Init()

    i = 0
    while True:
        j = connection.reserve()
        data = j.data.split('||')
        number = data[0]
        msg = data[1]
        print 'got job! number is: %s, message is: %s' % (number, msg)
        smsinfo = {
            'Class': 1,
            'Unicode': False,
            'Entries': [{
                'ID': 'ConcatenatedTextLong',
                'Buffer': 'Pesan SMS : "'   msg   '", urutan ke-'   str(i)
            }]
        }
        encoded = gammu.EncodeSMS(smsinfo)
        for message in encoded:
            message['SMSC'] = {'Location': 1}
            message['Number'] = number
            sm.SendSMS(message)

        j.Finish()
        print 'Succesfully send sms..'
        i  = 1

def main():
    try:
        print 'handling args'
        server = sys.argv[1]
        try:
            port = int(sys.argv[2])
        except:
            port = 11300

        print 'setting up connection'
        connection = serverconn.ServerConn(server, port)
        connection.job = job.Job
        consumer_main(connection)
    except Exception, e:
        print "usage: example.py server [port]"
        raise
        sys.exit(1)

if __name__ == '__main__':
    main()

{%endhighlight python %}

Untuk menguji program di atas maka jalankan terlebih dahulu beanstalkd dengan : `beanstalkd -d -p 11300`. Dimana `-p` adalah parameter port, Anda dapat menggantinya. Lalu jalankan `producer_send_sms_job.py` dengan `python producer_send_sms_job.py localhost 11300` (pastikan port yang digunakan sama dengan beanstalkd yang digunakan). Lalu mulai jalankan `consumer_to_send_sms_job.py` dengan `python consumer_to_send_sms_job.py localhost 11300`.
