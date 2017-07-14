# The Bay - A free music player for iOS
The Bay is a free music player for iOS that uses YouTube as a backend. 

## Features
The Bay comes with a few cool features. 

* Search for songs
* One swipe to add songs to playlists
* Download videos for offline play 
* Music player controls to play, pause and shuffle 
* Play songs in the background
* Song artwork

![](https://i.imgur.com/0yLgYwN.jpg)

## WARNING
This project is against [YouTubes terms and service](https://developers.google.com/youtube/terms/api-services-terms-of-service). It is purely for educational purposes only. Use at your own risk. 

## Installtion 

1. Download or clone the project. 
2. Obtain your YouTube API Key. [See here](https://www.youtube.com/watch?v=Im69kzhpR3I) for more details. 
3. Open the Xcode project and navigate to the 'YouTubeAPI.swift' file. Replace the 'apiKey' constant with your api key in the search function:

![](https://i.imgur.com/M22oavY.png)

## Customization
The Bay was also built with support for customization in mind. Navigate to the 'Global.swift' file and you will see some values you can tweak:

![](https://i.imgur.com/9jvPAgg.png)

In addition, The Bay also has built in support for ads using AdMob in three easy steps. 

1. [Sign up for AdMob](https://www.google.com/admob/) and retrieve your [Ad Unit ID](https://support.google.com/admob/answer/3016009?hl=en).

2. Navigate to 'TabBarController.swift' and in the `viewDidLoad` function replace your `adUnitID` parameter for the `bannerView` and uncomment these three lines of code.

![](https://i.imgur.com/QHWxBNS.png)

3. Go to 'Global.swift' and set the `ad_offset_constant` to `50` like so:

![](https://i.imgur.com/ZzZHEFS.png)

Boom! Ads should be showing :)


### Note

The Bay is not a finished project. There are may be bugs and I do not intend to fix them anytime soon. Thank you for understanding. 


