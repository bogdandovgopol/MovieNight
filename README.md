<p align="center"><img src="https://dovgopol.dev/apps/movienight/images/nowplaying.png" width="200" title="MovieNight">     <img src="https://dovgopol.dev/apps/movienight/images/upcoming.png" width="200" title="MovieNight">     <img src="https://dovgopol.dev/apps/movienight/images/detail.png" width="200" title="MovieNight"></p>

# MovieNight
MovieNight is a Swift iOS app showing currently playing and upcoming movies using data from themoviedb.org's REST api.

If you'd like to try this project you'll need your own tmdb's API_KEY. To get a key, please follow the directions at TMDB's website [authentication page](https://developers.themoviedb.org/3/getting-started/authentication).

After you get the key go to MovieNight/Utils/Constants.swift and add this line insise ``struct TMDB {...}``:<br/>
``
static let API_KEY = "YOUR_API_KEY"
``

## Dependencies
Kingfisher
