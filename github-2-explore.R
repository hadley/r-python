library(ggplot2)
library(dplyr)

all <- ungroup(readRDS("github.rds"))
all$query <- NULL
all$date <- as.Date(ISOdate(all$year, all$month, 1))
all$lang <- as.character(all$lang)

# For github repos, both R and python growing exponential, but python
# is a long way ahead
qplot(date, count, data = all, geom = "line", colour = lang)
ggsave("images/github-raw.png", width = 8, height = 6)

qplot(date, count, data = all, geom = "line", colour = lang) + scale_y_log10()

all_rel <- all %.% group_by(date) %.% 
  mutate(rel = count / max(count))

# Again R is catching up, but it's a lot further behind
qplot(date, rel, data = all_rel %.% filter(lang == "r"), geom = "line", colour = lang) + 
  ylab("R repos relative to python repos")
ggsave("images/github-rel.png", width = 8, height = 6)
