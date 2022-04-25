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

Each day's prices were appended to a comma-separated text file, with 1 row 
_per contract_ per hour. The markets tracked were from three categories:

### Presidential

1. Which party will win the U.S. presidential election? ([2721])
2. What will be the Electoral College margin?  ([6653])
3. What will be the popular vote margin? ([6663])
4. Individual markets for every state (e.g, Florida) ([5544])

[2721]: https://www.predictit.org/markets/detail/2721/
[6653]: https://www.predictit.org/markets/detail/6653/
[6663]: https://www.predictit.org/markets/detail/6663/
[5544]: https://www.predictit.org/markets/detail/5544

### Senate

1. Which party will control the Senate after the election? ([4366])
2. What will be the net change in seats, by party? ([6670])
3. Which race will be won by the smallest margin? ([6737])
4. Individual markets for most races (e.g., Maine class II) ([5811])

[4366]: https://www.predictit.org/markets/detail/4366/
[6670]: https://www.predictit.org/markets/detail/6670/
[6737]: https://www.predictit.org/markets/detail/6737/
[5811]: https://www.predictit.org/markets/detail/5811/

### House

1. Which party will control the House after 2020 election? ([4365])
2. How many seats will Democrats win? ([6669])
3. Individual markets for some races (e.g., South Carolina 1st) ([6753])

[4365]: https://www.predictit.org/markets/detail/4365/
[6669]: https://www.predictit.org/markets/detail/6669/
[6753]: https://www.predictit.org/markets/detail/6753/

# 2018

Historical daily price data for the 2018 midterm elections was provided by
PredictIt as part of an academic research agreement. A list of **120** 
congressional election markets was submitted on November 4, 2018 and data was 
returned on December 17, 2018. 

Each of the markets in 2018 focused on a single House or Senate election:

1. Will Elizabeth Warren be re-elected? ([2918])
2. Will Pelosi be re-elected? ([3450])

[2918]: https://www.predictit.org/markets/detail/2918/
[3450]: https://www.predictit.org/markets/detail/3450/

# 2016

Historical data for elections in 2016 were similarly provided. A list of **34** 
markets was submitted on October 17, 2018 and data was returned on November 3, 
2018.

Markets in 2016 focused on either party control or a single election:

1. Will the GOP control both Congress and the White House after 2016? ([1250])
2. Individual markets for some races (e.g., Louisiana senate race) ([2157])

[1250]: https://www.predictit.org/markets/detail/1250/
[2157]: https://www.predictit.org/markets/detail/2157/

Supplementary 90-day price history for Presidential markets was save in 2022.
