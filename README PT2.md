Project 3 - BeReal Clone

Submitted by: Nishan Narain

BeReal Clone is a social media app that allows users to take or upload photos, share them with friends, and view others’ posts. The app mimics core BeReal functionality by requiring users to post before unlocking the feed. Posts include time and location data, and users can interact through comments.

Time spent: ~12–16 hours spent in total

Required Features

The following required functionality is completed:

[x] User can launch camera to take photo instead of photo library
[x] Users without iPhones can upload unique photos from the simulator’s Photos app
[x] Users can interact with posts via comments, including username display
[x] Posts include time and location (with photo metadata support)
[x] Users cannot view other users’ posts until they upload their own post

Optional Features

The following optional functionality is implemented:

[ ] User receives notification when it is time to post

Additional Features

[x] Photo metadata location using real GPS data from images
[x] Fallback to device location if photo has no metadata


Video Walkthrough

(https://www.loom.com/share/ccb4fd18a2c44ffb9ec94c4735f791c6)

Notes

Challenges encountered while building the app:

Handling Parse pointer relationships between posts and comments
Ensuring comments persist correctly after refresh
Implementing feed lock logic based on user activity within 24 hours
Working with photo metadata (PHAsset) to retrieve real image location
Managing asynchronous updates for UI consistency after uploads

License

Copyright 2026 Nishan Narain

Licensed under the Apache License, Version 2.0 (the “License”)
you may not use this file except in compliance with the License
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an “AS IS” BASIS
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
