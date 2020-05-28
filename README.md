# Rails Model Visualizer
Visualize a rails project by entering it's github URL. 

For example, here is the output when visualizing one of my other apps:


![Image of The Scientific Meal Planner's model relationships](https://raw.githubusercontent.com/Dan-Burnette/Rails-Model-Visualizer/553903522b951a19525091e992b8bc8a64239fc6/example_output.svg)


It's intended to be a quick way to get your head around the structure of a new project. 

It uses the github API to pull the content of all your model files and database schema. From there it parses out the associations between the models and generates a graph. 

You can authenticate via github to enable visualizations of your private repositories.

There may be issues with certain repositories, but it seems to work properly on many of them. I might not have accounted for everything just yet. 

The initial version of this project was done as my coding bootcamp graduation project in 2014 and was instrumental in landing my first job. In this 2020 version I redid everything, utilizing the github API instead of web scraping the data, and accounting for more edge cases when parsing the repositories.

I'm an independent/freelance full stack web developer and I'm currently seeking new opportunities. Check out my main project <a href="https://scientificmealplanner.com">The Scientific Meal Planner<a>, as well as my <a href="http://dan-burnette.com">personal site</a> to get in touch.

