library(ggplot2)
library(dplyr)

# http://data.stackexchange.com/stackoverflow/query/150296/r-and-python-questions
so <- read.csv("http://data.stackexchange.com/stackoverflow/csv/186078")
names(so) <- c("month", "tag", "count")
so$month <- as.Date(so$month)

# Explosive growth of both python and R tags
qplot(month, count, data = so2, geom = "line", colour = tag)
ggsave("images/so-raw.png", width = 8, height = 6)

# Explore on log scale
library(MASS)
qplot(month, count, data = so2, geom = "line", colour = tag) + scale_y_log10() 
# Growth pretty close to exponential for both
recent <- filter(so2, month > as.Date("2010-01-01"))
ggplot(recent, aes(month, count, group = tag)) + 
  geom_smooth(method = rlm, se = F, colour = "grey50") +
  geom_line(aes(colour = tag)) +
  scale_y_log10()

# If we standardise python to 1, we see that R is growing relative to python
# over time.
so2 <- so %.% group_by(month) %.% 
  mutate(rel = count / max(count))
qplot(month, rel, data = so2, geom = "line", colour = tag) + 
  ylab("R questions as proportion of python questions")
ggsave("images/so-rel.png", width = 8, height = 6)
