---
title: go-instagram 0.4 released
author: gedex
layout: post
---

Changelog:

- Handle HTTP 500 with plain message "Oops, an error occurred.".
- Added MediaLocation to MediaService.
- Removed Location.CreatedTime as it doesn't exist.

The first two was added because of Instagram's API response inconsistencies.
