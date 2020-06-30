# About

This repository is an effort to track the 2020 general election via the
prediction market at [PredictIt.org][pi]. By scraping the [market's API][api],
and creating a historical database of market prices, we can quantify the odds
of various outcomes over time.

[pi]: https://www.predictit.org/
[api]:https://www.predictit.org/api/marketdata/all/

There are three markets regarding the Presidential election:

1. Which party will win the U.S. presidential election? ([2721])
2. What will be the Electoral College margin in the presidential election? ([6653])
4. What will be the popular vote margin in the presidential election? ([6663])

[2721]: https://www.predictit.org/markets/detail/2721/
[6653]: https://www.predictit.org/markets/detail/6653/
[6663]: https://www.predictit.org/markets/detail/6663/

There are many markets tracking the various Senate races:

1. Which party will control the Senate after the election? ([4366])
2. What will be the net change in Senate seats, by party? ([6670])
3. Which U.S. Senate race will be won by the smallest margin? ([6737])
4. Individual markets for Senate races (e.g., Maine ([5811]))

[4366]: https://www.predictit.org/markets/detail/4366/
[6670]: https://www.predictit.org/markets/detail/6670/
[6737]: https://www.predictit.org/markets/detail/6737/
[5811]: https://www.predictit.org/markets/detail/5811/
[5808]: https://www.predictit.org/markets/detail/5808/

There are less markets regarding the generally uncompetitive House races:

1. Which party will control the House after 2020 election? ([4365])
2. How many House seats will Democrats win in the 2020 election? ([6669])
3. Individual markets for House races (e.g., Soutch Carolina 1st ([6753]))

[4365]: https://www.predictit.org/markets/detail/4365/
[6669]: https://www.predictit.org/markets/detail/6669/
[6753]: https://www.predictit.org/markets/detail/6753/

# Code

Scraping is done with the [R language][rlang] and [predictr] package.

[rlang]: https://www.r-project.org/
[predictr]: https://github.com/kiernann/predictr

# Data

The 24 hour history of each of these markets is scraped every day at noon EST.
Data is not hosted on GitHub but will be made availabe upon request.
