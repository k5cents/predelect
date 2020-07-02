# About

This repository is an effort to track the 2020 general election via the
prediction market at [PredictIt.org][pi]. By scraping the [market's API][api],
and creating a historical database of market prices, we can quantify the odds
of various outcomes over time.

[pi]: https://www.predictit.org/
[api]:https://www.predictit.org/api/marketdata/all/

We are tracking individual and top line _election_ markets in three categories:

### Presidential

1. [2721]: Which party will win the U.S. presidential election?
2. [6653]: What will be the Electoral College margin in the presidential election? 
3. [6663]: What will be the popular vote margin in the presidential election?

[2721]: https://www.predictit.org/markets/detail/2721/
[6653]: https://www.predictit.org/markets/detail/6653/
[6663]: https://www.predictit.org/markets/detail/6663/

### Senate

1. [4366]: Which party will control the Senate after the election?
2. [6670]: What will be the net change in Senate seats, by party?
3. [6737]: Which U.S. Senate race will be won by the smallest margin?
4. [5811]: Individual markets for Senate races (e.g., Maine)

[4366]: https://www.predictit.org/markets/detail/4366/
[6670]: https://www.predictit.org/markets/detail/6670/
[6737]: https://www.predictit.org/markets/detail/6737/
[5811]: https://www.predictit.org/markets/detail/5811/

### House

1. [4365]: Which party will control the House after 2020 election?
2. [6669]: How many House seats will Democrats win in the 2020 election?
3. [6753]: Individual markets for House races (e.g., Soutch Carolina 1st)

[4365]: https://www.predictit.org/markets/detail/4365/
[6669]: https://www.predictit.org/markets/detail/6669/
[6753]: https://www.predictit.org/markets/detail/6753/

# Code

Scraping is done with the [R language][rlang] and [predictr] package.

[rlang]: https://www.r-project.org/
[predictr]: https://github.com/kiernann/predictr

# Data

The 24 hour history of each of these markets is scraped every day at noon EST.

Historical data is not hosted on GitHub but will be made availabe upon request.
