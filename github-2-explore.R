library(ggplot2)
library(dplyr)

gh <- readRDS("github.rds")
gh$query <- NULL

# For github repos, both R and python growing exponentially, but python
# is a long way ahead. Big spike in R repo creation in early 2014 
# probably due to JHU coursera course.
ggplot(gh, aes(start, count)) + 
  geom_line(aes(colour = lang)) +
  scale_y_log10()
ggsave("images/github-raw.png", width = 8, height = 6, dpi = 96)

rel <- gh %>% 
  group_by(start) %>% 
  mutate(rel = count / max(count)) %>%
  filter(lang == "r")

# Steadily decline in relative usage since post 2014
ggplot(rel, aes(start, rel)) + 
  geom_line()
ggsave("images/github-rel.png", width = 8, height = 6) 
