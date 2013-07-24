---
title: Harshad Number in Multiple Languages
author: gedex
layout: post
---

[Harshad Number](http://en.wikipedia.org/wiki/Harshad_number) was a Thursday Code Puzzler from [DZone](http://java.dzone.com/articles/thursday-code-puzzler-harshad).

> A Harshad or Niven number is a number that is divisible by the sum of its digits. 201 is a Harshad number because it is divisible by 3 (the sum of its digits.)

Belows are one-liners of Harshad in different languages.

Here's a Ruby version written by Rafael Naufal (given on comment):

{%highlight ruby %}
(1..99999).select { |n| n % n.to_s.chars.map(&:to_i).reduce(:+) == 0 }
{%endhighlight ruby %}

My Python version:

{%highlight python %}
[x for x in range(1,99999) if x % sum([int(y) for y in list(str(x))]) == 0]
{%endhighlight python %}

My PHP version:

{%highlight php %}
array_filter( range( 1, 99999 ), function($n) { return $n % array_sum( str_split($n) ) === 0; } );
{%endhighlight php %}

Do you have any for one-liners?
