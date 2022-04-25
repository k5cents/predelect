This repository is an effort to save hourly electoral prediction data from the 
information markets at [PredictIt.org][pi]. 

We can quantify odds over time by scraping the [market's API][api] every day
and creating a database of hourly prices.

[pi]: https://www.predictit.org/
[api]:https://www.predictit.org/api/marketdata/all/

# 2022

During 2022, the 24-hour price history of various markets was saved each day 
after 11:00 PM ET.

The JSON file returned for each request was saved to a separate file.

# 2020

During 2020, the 24-hour price history of various markets was saved each day 
after 11:00 PM ET.

[rlang]: https://www.r-project.org/
[predictr]: https://github.com/kiernann/predictr

As of July 4th 2020, there were **89** individual race markets being tracked.

Each day's prices were appeneded to a comma-separated text file, with 1 row 
_per contract_ per hour. The markets tracked were from three categories:

### Presidential

1. [2721]: Which party will win the U.S. presidential election?
2. [6653]: What will be the Electoral College margin? 
3. [6663]: What will be the popular vote margin?
4. [5544]: Individual markets for every state (e.g, Florida)

[2721]: https://www.predictit.org/markets/detail/2721/
[6653]: https://www.predictit.org/markets/detail/6653/
[6663]: https://www.predictit.org/markets/detail/6663/
[5544]: https://www.predictit.org/markets/detail/5544

### Senate

1. [4366]: Which party will control the Senate after the election?
2. [6670]: What will be the net change in seats, by party?
3. [6737]: Which race will be won by the smallest margin?
4. [5811]: Individual markets for most races (e.g., Maine class II)

[4366]: https://www.predictit.org/markets/detail/4366/
[6670]: https://www.predictit.org/markets/detail/6670/
[6737]: https://www.predictit.org/markets/detail/6737/
[5811]: https://www.predictit.org/markets/detail/5811/

### House

1. [4365]: Which party will control the House after 2020 election?
2. [6669]: How many seats will Democrats win?
3. [6753]: Individual markets for some races (e.g., South Carolina 1st)

[4365]: https://www.predictit.org/markets/detail/4365/
[6669]: https://www.predictit.org/markets/detail/6669/
[6753]: https://www.predictit.org/markets/detail/6753/

# 2018

Historical daily price data for the 2018 midterm elections was provided by
PredictIt as part of an academic research agreement. A list of **120** 
congressional election markets was submitted on November 4, 2018 and data was 
returned on December 17, 2018. 

Each of the markets in 2018 focused on a single House or Senate election:

1. [2918]: Will Elizabeth Warren be re-elected?
2. [3450]: Will Pelosi be re-elected?

[2918]: https://www.predictit.org/markets/detail/2918/
[3450]: https://www.predictit.org/markets/detail/3450/

# 2016

Historical data for elections in 2016 were similarly provided. A list of **34** 
markets was submitted on October 17, 2018 and data was returned on November 3, 
2018.

Markets in 2016 focused on either party control or a single election:

1. [1250]: Will the GOP control both Congress and the White House after 2016?
2. [2157]: Individual markets for some races (e.g., Louisiana senate race)

[1250]: https://www.predictit.org/markets/detail/1250/
[2157]: https://www.predictit.org/markets/detail/2157/

Suplementary 90-day price history for Presidental markets was saved in 2022.
